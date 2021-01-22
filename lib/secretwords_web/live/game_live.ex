defmodule SecretwordsWeb.GameLive do
  use SecretwordsWeb, :live_view

  alias Secretwords.{GameState, Helpers}

  def mount(%{"id" => game_id}, session, socket) do
    game = Helpers.get_or_create_game(game_id)
    IO.inspect("+++")
    IO.inspect(game)
    IO.inspect("+++")
    {:ok, assign(socket, [game: game, user_id: session["user_id"]])}
  end

  def handle_event("switch_teams", _value, socket) do
    game = Helpers.get_or_create_game(socket.assigns.game.id)
    |> GameState.switch_teams(socket.assigns["user_id"])
    |> Helpers.update_game()

    IO.inspect("+++")
    IO.inspect(game)
    IO.inspect(socket.assings["user_id"])
    IO.inspect("+++")

    {:noreply, assign(socket, :game, game)}
  end

  def render(assigns) do
    ~L"""
    <h2>Game: <%= @game.id %></h2>

    <table>
      <%= for row <- Enum.chunk_every(@game.word_slots, @game.grid_size) do %>
        <tr>
          <%= for ws <- row do %>
            <td class="word"><%= ws.word %></td>
          <% end %>
        </tr>
      <% end %>
    </table>

    <%= for {team, members} <- @game.teams do %>
      <h3><%= team |> Atom.to_string |> String.capitalize %>:</h3>
      <%= for member <- Enum.sort(members) do %>
        <p>
          <span <%= if @game.leaders[team] == member do %>class="team-leader"<% end %>><%= member %></span>
          <%= if member == @user_id do %>
            (you)
            <button phx-click="switch_teams">Switch teams</button>
          <% end %>
        </p>
      <% end %>
    <% end %>
    """
  end

end