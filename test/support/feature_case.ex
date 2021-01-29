defmodule SecretwordsWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL
      alias SecretwordsWeb.Router.Helpers, as: Routes

      @endpoint SecretwordsWeb.Endpoint
    end
  end

  setup tags do
    {:ok, session} = Wallaby.start_session()
    {:ok, session: session}
  end
end
