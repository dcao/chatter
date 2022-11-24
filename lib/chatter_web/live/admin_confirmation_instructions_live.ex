defmodule ChatterWeb.AdminConfirmationInstructionsLive do
  use ChatterWeb, :live_view

  alias Chatter.Orgs

  def render(assigns) do
    ~H"""
    <.header>Resend confirmation instructions</.header>

    <.simple_form :let={f} for={:admin} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input field={{f, :email}} type="email" label="Email" required />
      <:actions>
        <.button phx-disable-with="Sending...">Resend confirmation instructions</.button>
      </:actions>
    </.simple_form>

    <p>
      <.link href={~p"/admins/register"}>Register</.link>
      |
      <.link href={~p"/admins/log_in"}>Log in</.link>
    </p>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("send_instructions", %{"admin" => %{"email" => email}}, socket) do
    if admin = Orgs.get_admin_by_email(email) do
      Orgs.deliver_admin_confirmation_instructions(
        admin,
        &url(~p"/admins/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
