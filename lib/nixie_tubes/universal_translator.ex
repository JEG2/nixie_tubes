defmodule UniversalTranslator do
  @character_lookup "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!\"#$%&'()*+,-./:;<=>?@[\\]^_`|~ \n"

  @reverse_lookup_or_whatever @character_lookup
                              |> String.graphemes()
                              |> Enum.with_index()
                              |> Map.new()

  def lookup(char) do
    @reverse_lookup_or_whatever[char]
  end

  def decode(input) do
    {tree, []} =
      input
      |> String.split(" ")
      |> Enum.map(&decode_token/1)
      |> build_ast()

    evaluate(tree, Map.new())
  end

  def decode_token("S" <> input) do
    input
    |> String.codepoints()
    |> Enum.map(fn <<codepoint::utf8>> -> String.at(@character_lookup, codepoint - ?!) end)
    |> Enum.join()
  end

  def decode_token("T") do
    true
  end

  def decode_token("F") do
    false
  end

  def decode_token("I" <> integer) do
    integer
    |> String.codepoints()
    |> Enum.map(fn <<number::utf8>> -> number - ?! end)
    |> Enum.reduce(0, fn digit, acc -> acc * 94 + digit end)
  end

  def decode_token("U" <> operator) do
    case operator do
      "-" -> :negate
      "!" -> :not
      "#" -> :str_to_int
      "$" -> :int_to_str
    end
  end

  def decode_token("B" <> operator) do
    case operator do
      "+" -> :add
      "-" -> :subtract
      "*" -> :multiply
      "/" -> :divide
      "%" -> :mod
      "<" -> :lt
      ">" -> :gt
      "=" -> :eq
      "|" -> :or
      "&" -> :and
      "." -> :concat
      "T" -> :take
      "D" -> :drop
      "$" -> :apply
    end
  end

  def decode_token("?") do
    :if
  end

  def decode_token("L" <> integer) do
    {:lambda, decode_token("I#{integer}")}
  end

  def decode_token("v" <> integer) do
    {:var, decode_token("I#{integer}")}
  end

  def decode_token(other) do
    other
  end

  def encode(string) do
    computed_string =
      string
      |> String.codepoints()
      |> Enum.map(fn codepoint -> @reverse_lookup_or_whatever[codepoint] + ?! end)
      |> to_string()

    "S" <> computed_string
  end

  def build_ast([:if | tokens]) do
    {test, rest} = build_ast(tokens)
    {if_true, rest} = build_ast(rest)
    {if_false, rest} = build_ast(rest)

    {{:if, test, if_true, if_false}, rest}
  end

  def build_ast([binary | tokens])
      when binary in [
             :add,
             :subtract,
             :multiply,
             :divide,
             :mod,
             :lt,
             :gt,
             :eq,
             :or,
             :and,
             :concat,
             :take,
             :drop,
             :apply
           ] do
    {x, rest} = build_ast(tokens)
    {y, rest} = build_ast(rest)

    {{binary, x, y}, rest}
  end

  def build_ast([unary | tokens]) when unary in [:negate, :not, :str_to_int, :int_to_str] do
    {value, rest} = build_ast(tokens)
    {{unary, value}, rest}
  end

  def build_ast([{:var, number} | tokens]) do
    {{:var, number}, tokens}
  end

  def build_ast([{:lambda, number} | tokens]) do
    {value, rest} = build_ast(tokens)

    {{:lambda, number, value}, rest}
  end

  def build_ast([true | tokens]) do
    {true, tokens}
  end

  def build_ast([false | tokens]) do
    {false, tokens}
  end

  def build_ast([integer | tokens]) when is_integer(integer) do
    {integer, tokens}
  end

  def build_ast([string | tokens]) when is_binary(string) do
    {string, tokens}
  end

  def evaluate({:add, v1, v2}, binding), do: evaluate(v1, binding) + evaluate(v2, binding)
  def evaluate({:subtract, v1, v2}, binding), do: evaluate(v1, binding) - evaluate(v2, binding)
  def evaluate({:multiply, v1, v2}, binding), do: evaluate(v1, binding) * evaluate(v2, binding)
  def evaluate({:divide, v1, v2}, binding), do: div(evaluate(v1, binding), evaluate(v2, binding))
  def evaluate({:mod, v1, v2}, binding), do: rem(evaluate(v1, binding), evaluate(v2, binding))
  def evaluate({:lt, v1, v2}, binding), do: evaluate(v1, binding) < evaluate(v2, binding)
  def evaluate({:gt, v1, v2}, binding), do: evaluate(v1, binding) > evaluate(v2, binding)
  def evaluate({:eq, v1, v2}, binding), do: evaluate(v1, binding) == evaluate(v2, binding)
  def evaluate({:or, v1, v2}, binding), do: evaluate(v1, binding) or evaluate(v2, binding)
  def evaluate({:and, v1, v2}, binding), do: evaluate(v1, binding) and evaluate(v2, binding)
  def evaluate({:concat, v1, v2}, binding), do: evaluate(v1, binding) <> evaluate(v2, binding)

  def evaluate({:take, v1, v2}, binding),
    do: String.slice(evaluate(v2, binding), 0, evaluate(v1, binding))

  def evaluate({:drop, v1, v2}, binding) do
    v2 = evaluate(v2, binding)
    String.slice(v2, evaluate(v1, binding), String.length(v2))
  end

  def evaluate({:lambda, number, body}, binding) do
    fn argument -> evaluate(body, Map.put(binding, number, argument)) end
  end

  def evaluate({:var, number}, binding) do
    evaluate(Map.fetch!(binding, number), binding)
  end

  def evaluate({:apply, function, argument}, binding) do
    evaluate(function, binding).(argument)
  end

  def evaluate({:if, test, if_true, if_false}, binding) do
    if evaluate(test, binding) do
      evaluate(if_true, binding)
    else
      evaluate(if_false, binding)
    end
  end

  def evaluate({:negate, x}, binding), do: evaluate(x, binding) * -1
  def evaluate({:not, x}, binding), do: not evaluate(x, binding)

  def evaluate({:str_to_int, x}, binding) do
    base_94_representation =
      evaluate(x, binding)
      |> String.codepoints()
      |> Enum.map(fn char -> lookup(char) + ?! end)
      |> to_string()

    decode_token("I#{base_94_representation}")
  end

  def evaluate({:int_to_str, x}, binding) do
    result = evaluate(x, binding)

    chunks =
      {result, result}
      |> Stream.iterate(fn {_n, acc} ->
        d = div(acc, 94)
        r = rem(acc, 94)

        if d > 0 do
          {r, d}
        else
          {r, 0}
        end
      end)
      |> Stream.drop(1)
      |> Enum.take_while(fn {_, acc} -> acc != 0 end)

    numbers =
      chunks
      |> Enum.map(fn {number, _remainder} -> number end)

    string_representation =
      (numbers ++ [chunks |> List.last() |> elem(1)])
      |> Enum.reverse()
      |> Enum.map(fn c -> c + ?! end)
      |> to_string

    decode_token("S#{string_representation}")
  end

  def evaluate(true, _binding) do
    true
  end

  def evaluate(false, _binding) do
    false
  end

  def evaluate(int, _binding) when is_integer(int) do
    int
  end

  def evaluate(string, _binding) when is_binary(string) do
    string
  end
end
