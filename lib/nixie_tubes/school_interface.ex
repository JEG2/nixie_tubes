defmodule SchoolInterface do
  def get(section) do
    "get #{section}"
    |> UniversalTranslator.encode()
    |> Submitomatic.communicate()
    |> UniversalTranslator.decode()
  end

  def get_raw(section) do
    "get #{section}"
    |> UniversalTranslator.encode()
    |> Submitomatic.communicate()
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

  def execute_icfp(icfp) do
    "B. S%#(/} #{icfp}"
    |> Submitomatic.communicate()
    |> UniversalTranslator.decode()
    |> String.replace("\nYou scored some points for using the echo service!\n", "")
  end

  def test_3d(program, variables \\ []) do
    a = Keyword.get(variables, :a, 0)
    b = Keyword.get(variables, :b, 0)

    "test 3d #{a} #{b}\n#{program}"
    |> UniversalTranslator.encode()
    |> Submitomatic.communicate()
    |> execute_icfp()
  end

  def solve_3d(game, program) do
    "solve #{game}\n#{program}"
    |> UniversalTranslator.encode()
    |> Submitomatic.communicate()
    |> execute_icfp()
  end

  def test_prog do
    """
    . . . . . . > . . . . . . . . . .
    . . . . . ^ . v . . . . . . . . .
    . . . 1 . . . . . . . 1 . . . . .
    . . A - . ^ 4 @ 1 . A + . . . . .
    . . . . / . . 6 . . . . / . > . .
    . . . v . . . . . . . v . . . v .
    . . < . > . . . . . < . > . . . .
    . v . . 0 = . . 0 = . . . v . v .
    . . . . . . > . < . . . < . . . .
    . v . . . . . + S . . v . . 4 v 7
    . . . . . 0 ^ . . . . . . . . . .
    . v . . 1 + . . . . 1 @ 8 . 4 @ 9
    . . . . . . / . > . . 6 . . . 6 .
    -1 @ 10 . . v . . . v . . . . . . .
    . 6 . . < . . . . . . . . . . . .
    . . . v . . . . . v . . . . . . .
    . . . . > . . . . . . . . . . . .
    . . . . . v . . . v . . . . . . .
    . . . . . . . . . . . . . . 0 . .
    . . . . 1 @ 8 . 4 @ 9 . . A = S .
    . . . . . 6 . . . 6 . . . . . . .
    """
  end

  def test_2 do
    """
    . .  . . . 1 > . . . . . . . . . .
    . .  . . . ^ . v . . . . . . . . .
    . .  . . . . . . . . . . . . . . .
    . .  . - . ^ 4 @ 1 . . + . . . . .
    . .  . . / . . 2 . . . . / . > . .
    . .  . v 1 . . . . . . v 1 . . v .
    . .  < . > 1 . . . 3 < . > . . 1 .
    . v  . . 0 = . . 0 = . . . v . v .
    . 1  . . . . > . < . . . < 3 . . .
    . v  . . . . 1 + S . . v . . 4 v 7
    . .  . . . . ^ . . . . . . . . . .
    . v  . . . + . . . . 1 @ 8 . 4 @ 9
    . .  . . . . / . > . . 2 . . . 2 .
    -1 @ 10 . . v 1 . . v . . . . . . .
    . 2  . . < . . . . 1 . . . . . . .
    . .  . v . . . . . v . . . . . . .
    . .  . 1 > . . . . . . . . . . . .
    . .  . . . v . . . v . . . . . . .
    . .  . . . . . . . . . . . . . . .
    . .  . . 1 @ 8 . 4 @ 9 . . . . . .
    . .  . . . 2 . . . 2 . . . . . . .
    """
  end

  # def test_prog do
  #     """
  #     . . 1 . . . . . . .
  #     . 1 + . . . . . . .
  #     . . . > S . . . . .
  #     . . . . . . . . . .
  #     """
  # end
end
