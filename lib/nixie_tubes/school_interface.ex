defmodule SchoolInterface do
  def get(section) do
    "get #{section}"
    |> UniversalTranslator.encode()
    |> Submitomatic.communicate()
    |> UniversalTranslator.decode()
  end

  def solve(game, solution) do
    "solve #{game} #{solution}"
    |> UniversalTranslator.encode()
    |> Submitomatic.communicate()
    |> UniversalTranslator.decode()
  end

  def echo(input) do
    "echo #{input}"
    |> UniversalTranslator.encode()
    |> Submitomatic.communicate()
    |> UniversalTranslator.decode()
  end
end
