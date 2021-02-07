defmodule Secretwords.User do
  @moduledoc false

  defstruct id: "", name: ""

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
  }
end
