defmodule Secretwords.WordSlot do
  @moduledoc false

  defstruct word: "",
            used: false,
            type: :neutral

  @type t :: %__MODULE__{
          word: String.t(),
          used: boolean,
          type: :red | :blue | :neutral | :killer
        }
end
