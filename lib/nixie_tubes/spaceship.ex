defmodule Spaceship do
  require Integer

  defstruct xy: {0, 0}, goals: nil, buttons: []

  def solve(input) do
    input
    |> parse()
    |> move()
  end

  def parse(input) do
    goals =
      input
      |> String.trim()
      |> String.split()
      |> Enum.chunk_every(2)
      |> Enum.map(fn [x, y] -> {String.to_integer(x), String.to_integer(y)} end)
      |> Enum.uniq()

    %__MODULE__{goals: goals}
  end

  def move(state) do
    # 1 find the nearest goal
    # 2 plot a course to that goal ending at velocity 0
    # 3 rinse  repeat until out of goals

    state
    |> Stream.iterate(fn s ->
      {x, y} = s.xy

      nearest =
        Enum.min_by(s.goals, fn {gx, gy} ->
          abs(gx - x) + abs(gy - y)
        end)

      {nx, ny} = nearest

      x_dir =
        cond do
          nx == x -> 0
          nx > x -> 1
          nx < x -> -1
        end

      y_dir =
        cond do
          ny == y -> 0
          ny > y -> 1
          ny < y -> -1
        end

      x_distance = abs(nx - x)
      y_distance = abs(ny - y)

      vxs = x_distance |> velocity_from_distance() |> velocity_into_vector(x_dir)
      vys = y_distance |> velocity_from_distance() |> velocity_into_vector(y_dir)

      total_distance = max(length(vxs), length(vys))

      buttons =
        (vxs ++ List.duplicate(0, total_distance - length(vxs)))
        |> Enum.zip((vys ++ List.duplicate(0, total_distance - length(vys))))
        |> Enum.reduce(s.buttons, fn vxy, acc ->
          case vxy do
            {-1, 1} -> [7 | acc]
            {0, 1} -> [8 | acc]
            {1, 1} -> [9 | acc]
            {1, 0} -> [6 | acc]
            {0, 0} -> [5 | acc]
            {-1, 0} -> [4 | acc]
            {-1, -1} -> [1 | acc]
            {0, -1} -> [2 | acc]
            {1, -1} -> [3 | acc]
          end
        end)

      %__MODULE__{s | xy: nearest, goals: List.delete(s.goals, nearest), buttons: buttons}
    end)
    |> Enum.find(fn s -> s.goals == [] end)
    |> Map.fetch!(:buttons)
    |> Enum.reverse()
    |> Enum.join()
  end

  def velocity_into_vector(velocities, _direction) when map_size(velocities) == 0 do
    []
  end

  def velocity_into_vector(velocities, direction) do
    max_v = velocities |> Map.keys() |> Enum.max()

    accel =
    velocities
    |> Enum.sort()
    |> Enum.flat_map(fn {v, c} ->
      [direction] ++ List.duplicate(0, if(v == max_v, do: c - 1, else: c - 2))
    end)

    accel ++ List.duplicate(-direction, map_size(velocities))
  end

  def velocity_from_distance(0) do
    Map.new()
  end

  def velocity_from_distance(distance) do
    max_velocity = floor(:math.sqrt(distance))

    velocities =
      Enum.reduce(
        (max_velocity - 1)..1//-1,
        %{max_velocity => 1},
        fn v, acc ->
          Map.put(acc, v, 2)
        end
      )

    remaining =
      Enum.reduce(velocities, distance, fn {v, c}, acc -> acc - v * c end)

    velocities
    |> Enum.sort_by(fn {v, _c} -> -v end)
    |> Enum.reduce_while({velocities, remaining}, fn {v, c}, {vs, rm} ->
      pauses = div(rm, v)
      new_rm = rm - v * pauses

      if new_rm == 0 do
        {:halt, {Map.put(vs, v, c + pauses), 0}}
      else
        {:cont, {Map.put(vs, v, c + pauses), new_rm}}
      end
    end)
    |> elem(0)
  end
end
