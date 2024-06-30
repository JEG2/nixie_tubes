defmodule LambdaMan do
  defstruct position: nil,
            paths: nil,
            pills: nil,
            commands: [],
            entrances: MapSet.new(),
            max_x: nil,
            max_y: nil

  def solve(grid) do
    grid
    |> build_graph()
    |> find_paths()
    |> Map.fetch!(:commands)
    |> Enum.reverse()
    |> Enum.join()
  end

  def manual_solve(number) do
    File.read!(Path.join(:code.priv_dir(:nixie_tubes), "lambdaman/#{number}.txt"))
    |> build_graph()
    |> move_and_show(number)
  end

  def interactive(number) do
    solution_file =
      File.open!(
        Path.join(:code.priv_dir(:nixie_tubes), "lambdaman/#{number}_solution.txt"),
        [:write]
      )

    File.read!(Path.join(:code.priv_dir(:nixie_tubes), "lambdaman/#{number}.txt"))
    |> build_graph()
    |> record_moves(solution_file)
  end

  def build_graph(grid) do
    parsed =
      grid
      |> String.trim()
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {cell, x} ->
          {{x, y}, cell}
        end)
      end)
      |> Enum.reject(fn {_, cell} -> cell == "#" end)
      |> Map.new()

    {position, _} = Enum.find(parsed, fn {_position, cell} -> cell == "L" end)

    pills = :digraph.new()
    paths = :digraph.new()

    parsed
    |> Enum.each(fn {x_y, _} ->
      :digraph.add_vertex(pills, x_y)
      :digraph.add_vertex(paths, x_y)
    end)

    parsed
    |> Enum.each(fn {{x, y}, cell} ->
      [{0, 1}, {0, -1}, {-1, 0}, {1, 0}]
      |> Enum.each(fn {x_offset, y_offset} ->
        neighbor = {x + x_offset, y + y_offset}

        if Map.has_key?(parsed, neighbor) do
          :digraph.add_edge(paths, {{x, y}, neighbor}, {x, y}, neighbor, cell)
          :digraph.add_edge(pills, {{x, y}, neighbor}, {x, y}, neighbor, cell)
        end
      end)
    end)

    vertices = :digraph.vertices(paths)
    max_x = vertices |> Enum.map(fn {x, _y} -> x end) |> Enum.max()
    max_y = vertices |> Enum.map(fn {_x, y} -> y end) |> Enum.max()

    %__MODULE__{paths: paths, pills: pills, position: position, max_x: max_x, max_y: max_y}
  end

  def find_paths(struct) do
    show_grid(struct)
    # remove origin / edges
    neighbours = collect_pill(struct)

    entrances =
      MapSet.delete(struct.entrances, struct.position) |> MapSet.union(MapSet.new(neighbours))

    new_struct =
      if length(neighbours) == 1 do
        move_to(%__MODULE__{struct | entrances: entrances}, struct.position, neighbours |> hd)
      else
        # find possible paths
        choices = :digraph_utils.strong_components(struct.pills)

        # figure out cost for each path
        next_steps =
          choices
          |> Enum.map(fn choice ->
            cost =
              choice
              |> MapSet.new()
              |> MapSet.intersection(entrances)
              |> Enum.map(fn vertex ->
                :digraph.get_short_path(struct.paths, struct.position, vertex)
              end)
              |> Enum.map(fn path -> {length(path), path} end)

            minimum_cost =
              cost |> Enum.map(fn {cost, _} -> cost end) |> Enum.min()

            minimums =
              cost
              |> Enum.filter(fn {cost, _path} -> cost == minimum_cost end)

            minimums
            |> Enum.find(fn {_cost, path} ->
              struct.commands != [] &&
                struct.commands |> hd |> carry_on(struct.position) |> Kernel.==(Enum.at(path, 1))
            end)
            |> Kernel.||(hd(minimums))
            |> elem(1)
          end)

        choices
        |> Enum.zip(next_steps)
        |> Enum.min_by(fn {choice, step} ->
          length(choice) + length(step) - 1
        end)
        |> elem(1)
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.reduce(%__MODULE__{struct | entrances: entrances}, fn [from, to], acc ->
          move_to(acc, from, to)
        end)
      end

    if :digraph.no_vertices(struct.pills) == 1 do
      new_struct
    else
      find_paths(new_struct)
    end
  end

  def move_to(struct, {from_x, from_y}, {to_x, to_y}) do
    cond do
      from_y + 1 == to_y ->
        %__MODULE__{struct | position: {to_x, to_y}, commands: ["D" | struct.commands]}

      from_y - 1 == to_y ->
        %__MODULE__{struct | position: {to_x, to_y}, commands: ["U" | struct.commands]}

      from_x - 1 == to_x ->
        %__MODULE__{struct | position: {to_x, to_y}, commands: ["L" | struct.commands]}

      from_x + 1 == to_x ->
        %__MODULE__{struct | position: {to_x, to_y}, commands: ["R" | struct.commands]}
    end
  end

  def show_grid(struct) do
    IO.write("\r\n")
    IO.write(IO.ANSI.clear())

    Enum.reduce(0..struct.max_y, "", fn y, acc ->
      row =
        Enum.reduce(0..struct.max_x, acc, fn x, acc ->
          cell =
            cond do
              {x, y} == struct.position -> "L"
              :digraph.vertex(struct.pills, {x, y}) -> "."
              :digraph.vertex(struct.paths, {x, y}) -> " "
              true -> "#"
            end

          acc <> cell
        end)

      row <> "\r\n"
    end)
    |> IO.write()

    IO.write("\r\n")

    # IO.gets("Push Key to continue")
  end

  def carry_on(direction, {x, y}) do
    case direction do
      "U" -> {x, y - 1}
      "D" -> {x, y + 1}
      "L" -> {x - 1, y}
      "R" -> {x + 1, y}
    end
  end

  def move_and_show(struct, number) do
    File.stream!(Path.join(:code.priv_dir(:nixie_tubes), "lambdaman/#{number}_solution.txt"))
    |> Stream.flat_map(fn line ->
      [count, direction] = line |> String.trim() |> String.split(":")

      List.duplicate(direction, String.to_integer(count))
    end)
    |> Enum.reduce(struct, fn move, acc ->
      to = carry_on(move, acc.position)

      unless :digraph.vertex(acc.pills, to) do
        raise "invalid move from: #{inspect(acc.position)}, to: #{inspect(to)}"
      end

      collect_pill(acc)

      move_to(acc, acc.position, to)
    end)
    |> show_grid()
  end

  def collect_pill(struct) do
    neighbours = :digraph.out_neighbours(struct.pills, struct.position)

    neighbours
    |> Enum.each(fn connection ->
      :digraph.del_edge(struct.pills, {struct.position, connection})
      :digraph.del_edge(struct.pills, {connection, struct.position})
    end)

    :digraph.del_vertex(struct.pills, struct.position)

    neighbours
  end

  def record_moves(struct, solution_file) do
    show_grid(struct)
    input = IO.getn("", 1)

    move =
      case input do
        "0" -> System.halt()
        "w" -> "U"
        "a" -> "L"
        "s" -> "D"
        "d" -> "R"
        _ -> nil
      end

    if move do
      to = carry_on(move, struct.position)

      if :digraph.vertex(struct.paths, to) do
        collect_pill(struct)
        IO.write(solution_file, move)

        move_to(struct, struct.position, to) |> record_moves(solution_file)
      else
        record_moves(struct, solution_file)
      end
    else
      record_moves(struct, solution_file)
    end
  end
end
