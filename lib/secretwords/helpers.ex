defmodule Secretwords.Helpers do
  @moduledoc """
  Helper functions, which I don't know where else to stick.
  """

  def random_string(length \\ 8) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
    |> String.downcase()
  end
end
