defmodule Secretwords.WordSlot do
  @moduledoc false

  defstruct word: "",
            used: false,
            # :red, :blue, :neutral, :killer,
            type: :neutral
end
