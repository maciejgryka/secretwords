defmodule Secretwords.WordSlot do
  defstruct [
    word: "",
    used: false,
    type: :neutral # :red, :blue, :neutral, :killer,
  ]
end
