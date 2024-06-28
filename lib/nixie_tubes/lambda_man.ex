defmodule LambdaMan do
  defstruct position: nil, paths: nil, pills: nil, commands: []

  def solve(grid) do
    grid
    |> build_graph()
    |> find_paths()
    |> Map.fetch!(:commands)
    |> Enum.reverse()
    |> Enum.join()
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

    %__MODULE__{paths: paths, pills: pills, position: position}
  end

  def find_paths(struct) do
    # remove origin / edges
    :digraph.out_neighbours(struct.pills, struct.position)
    |> Enum.each(fn connection ->
      :digraph.del_edge(struct.pills, {struct.position, connection})
      :digraph.del_edge(struct.pills, {connection, struct.position})
    end)

    :digraph.del_vertex(struct.pills, struct.position)

    # find possible paths
    choices = :digraph_utils.strong_components(struct.pills)

    # figure out cost for each path
    next_steps =
      choices
      |> Enum.map(fn choice ->
        choice
        |> Enum.map(fn vertex ->
          :digraph.get_short_path(struct.paths, struct.position, vertex)
        end)
        |> Enum.min_by(fn path -> length(path) end)
      end)

    new_struct =
      choices
      |> Enum.zip(next_steps)
      |> Enum.min_by(fn {choice, step} ->
        length(choice) + length(step) - 1
      end)
      |> elem(1)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(struct, fn [{from_x, from_y}, {to_x, to_y}], acc ->
        cond do
          from_y + 1 == to_y ->
            %__MODULE__{acc | position: {to_x, to_y}, commands: ["D" | acc.commands]}

          from_y - 1 == to_y ->
            %__MODULE__{acc | position: {to_x, to_y}, commands: ["U" | acc.commands]}

          from_x - 1 == to_x ->
            %__MODULE__{acc | position: {to_x, to_y}, commands: ["L" | acc.commands]}

          from_x + 1 == to_x ->
            %__MODULE__{acc | position: {to_x, to_y}, commands: ["R" | acc.commands]}
        end
      end)

    if :digraph.no_vertices(struct.pills) == 1 do
      new_struct
    else
      find_paths(new_struct)
    end
  end
end
