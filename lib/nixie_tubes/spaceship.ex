defmodule Spaceship do
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
        |> IO.inspect()

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

      vxs_mid = ceil(abs(nx - x) / 2)
      vys_mid = ceil(abs(ny - y) / 2)
      total = max(vxs_mid, vys_mid) + 1

      vxs =
        List.duplicate(x_dir, vxs_mid) ++
          List.duplicate(0, total - vxs_mid * 2) ++
          List.duplicate(-x_dir, vxs_mid)

      vys =
        List.duplicate(y_dir, vys_mid) ++
          List.duplicate(0, total - vys_mid * 2) ++
          List.duplicate(-y_dir, vys_mid)

      buttons =
        vxs
        |> Enum.zip(vys)
        |> Enum.reduce(s.buttons, fn vxy, acc ->
          case vxy do
            {-1, 1} -> [7 | acc]
            {0, 1} -> [8 | acc]
            {1, 1} -> [9 | acc]
            {-1, 0} -> [6 | acc]
            {0, 0} -> [5 | acc]
            {1, 0} -> [4 | acc]
            {-1, -1} -> [1 | acc]
            {0, -1} -> [2 | acc]
            {1, -1} -> [3 | acc]
          end
        end)
    end)
    |> Stream.drop(1)
    |> Enum.take(1)
    |> IO.inspect()
  end
end
