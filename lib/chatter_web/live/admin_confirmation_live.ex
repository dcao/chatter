defmodule ChatterWeb.AdminConfirmationLive do
  use ChatterWeb, :live_view

  alias Chatter.Orgs

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <.header>Confirm Account</.header>

    <.simple_form :let={f} for={:admin} id="confirmation_form" phx-submit="confirm_account">
      <.input field={{f, :token}} type="hidden" value={@token} />
      <:actions>
        <.button phx-disable-with="Confirming...">Confirm my account</.button>
      </:actions>
    </.simple_form>

    <p>
      <.link href={~p"/admins/register"}>Register</.link>
      |
      <.link href={~p"/admins/log_in"}>Log in</.link>
    </p>
    """
  end

  def mount(params, _session, socket) do
    {:ok, assign(socket, token: params["token"]), temporary_assigns: [token: nil]}
  end

  # Do not log in the admin after confirmation to avoid a
  # leaked token giving the admin access to the account.
  def handle_event("confirm_account", %{"admin" => %{"token" => token}}, socket) do
    case Orgs.confirm_admin(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Admin confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current admin and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the admin themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_admin: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "Admin confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end
