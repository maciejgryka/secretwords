defmodule SecretwordsWeb.PageController do
  use SecretwordsWeb, :controller

  alias Secretwords.Helpers

  def index(conn, _params) do
    render(conn, "index.html", game_id: Helpers.random_string())
  end
end
