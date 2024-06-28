defmodule Solver do
  def run(solver_module) do
    game_name = solver_module |> Module.split() |> hd |> String.downcase()

    game_name
    |> SchoolInterface.get()
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> String.starts_with?(line, "* [#{game_name}") end)
    |> Enum.map(fn string ->
      case Regex.scan(~r/\d+/, string) |> List.flatten() do
        [game_number, your_score, best_score] ->
          {game_number, String.to_integer(your_score), String.to_integer(best_score)}

        [game_number, best_score] ->
          {game_number, :infinity, String.to_integer(best_score)}

        [game_number] ->
          {game_number, :infinity, :unsolved}
      end
    end)
    |> Enum.filter(fn {_game_number, your_score, best_score} ->
      best_score == :unsolved || your_score > best_score
    end)
    |> Enum.each(fn {game_number, _, _} ->
      game_identifier = "#{game_name}#{game_number}"
      IO.puts("Solving #{game_identifier}")


      solution =
        game_identifier
        |> SchoolInterface.get()
        |> solver_module.solve()

      SchoolInterface.solve(game_identifier, solution)
      Process.sleep(3000)
    end)
  end
end
