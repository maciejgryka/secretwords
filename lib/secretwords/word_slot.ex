defmodule Secretwords.WordSlot do
  defstruct word: "",
            used: false,
            # :red, :blue, :neutral, :killer,
            type: :neutral
end
