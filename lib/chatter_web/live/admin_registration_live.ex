defmodule ChatterWeb.AdminRegistrationLive do
  use ChatterWeb, :live_view

  alias Chatter.Orgs
  alias Chatter.Orgs.Admin

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/admins/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        :let={f}
        id="registration_form"
        for={@changeset}
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/admins/log_in?_action=registered"}
        method="post"
        as={:admin}
      >
        <.error :if={@changeset.action == :insert}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={{f, :email}} type="email" label="Email" required />
        <.input field={{f, :password}} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Orgs.change_admin_registration(%Admin{})
    socket = assign(socket, changeset: changeset, trigger_submit: false)
    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  def handle_event("save", %{"admin" => admin_params}, socket) do
    case Orgs.register_admin(admin_params) do
      {:ok, admin} ->
        {:ok, _} =
          Orgs.deliver_admin_confirmation_instructions(
            admin,
            &url(~p"/admins/confirm/#{&1}")
          )

        changeset = Orgs.change_admin_registration(admin)
        {:noreply, assign(socket, trigger_submit: true, changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("validate", %{"admin" => admin_params}, socket) do
    changeset = Orgs.change_admin_registration(%Admin{}, admin_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end
end
