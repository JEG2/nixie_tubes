defmodule Submitomatic do
  @url "https://boundvariable.space/communicate"
  @token :nixie_tubes
         |> :code.priv_dir()
         |> Path.join("security/token.txt")
         |> File.read!()
         |> String.trim()

  def communicate(message) do
    Req.post!(@url, headers: %{authorization: "Bearer #{@token}"}, body: message).body
  end
end
