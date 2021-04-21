defmodule Secretwords.User do
  @moduledoc false

  alias Secretwords.UserStore

  defstruct id: "",
            name: ""

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t()
        }

  def name(user_id) do
    case UserStore.get(user_id) do
      nil -> nil
      user -> user.name
    end
  end
end
