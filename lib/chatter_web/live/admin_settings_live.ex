defmodule ChatterWeb.AdminSettingsLive do
  use ChatterWeb, :live_view

  alias Chatter.Orgs

  def render(assigns) do
    ~H"""
    <.header>Change Email</.header>

    <.simple_form
      :let={f}
      id="email_form"
      for={@email_changeset}
      phx-submit="update_email"
      phx-change="validate_email"
    >
      <.error :if={@email_changeset.action == :insert}>
        Oops, something went wrong! Please check the errors below.
      </.error>

      <.input field={{f, :email}} type="email" label="Email" required />

      <.input
        field={{f, :current_password}}
        name="current_password"
        id="current_password_for_email"
        type="password"
        label="Current password"
        value={@email_form_current_password}
        required
      />
      <:actions>
        <.button phx-disable-with="Changing...">Change Email</.button>
      </:actions>
    </.simple_form>

    <.header>Change Password</.header>

    <.simple_form
      :let={f}
      id="password_form"
      for={@password_changeset}
      action={~p"/admins/log_in?_action=password_updated"}
      method="post"
      phx-change="validate_password"
      phx-submit="update_password"
      phx-trigger-action={@trigger_submit}
    >
      <.error :if={@password_changeset.action == :insert}>
        Oops, something went wrong! Please check the errors below.
      </.error>

      <.input field={{f, :email}} type="hidden" value={@current_email} />

      <.input field={{f, :password}} type="password" label="New password" required />
      <.input field={{f, :password_confirmation}} type="password" label="Confirm new password" />
      <.input
        field={{f, :current_password}}
        name="current_password"
        type="password"
        label="Current password"
        id="current_password_for_password"
        value={@current_password}
        required
      />
      <:actions>
        <.button phx-disable-with="Changing...">Change Password</.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Orgs.update_admin_email(socket.assigns.current_admin, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/admins/settings")}
  end

  def mount(_params, _session, socket) do
    admin = socket.assigns.current_admin

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, admin.email)
      |> assign(:email_changeset, Orgs.change_admin_email(admin))
      |> assign(:password_changeset, Orgs.change_admin_password(admin))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "admin" => admin_params} = params
    email_changeset = Orgs.change_admin_email(socket.assigns.current_admin, admin_params)

    socket =
      assign(socket,
        email_changeset: Map.put(email_changeset, :action, :validate),
        email_form_current_password: password
      )

    {:noreply, socket}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "admin" => admin_params} = params
    admin = socket.assigns.current_admin

    case Orgs.apply_admin_email(admin, password, admin_params) do
      {:ok, applied_admin} ->
        Orgs.deliver_admin_update_email_instructions(
          applied_admin,
          admin.email,
          &url(~p"/admins/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, put_flash(socket, :info, info)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_changeset, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "admin" => admin_params} = params
    password_changeset = Orgs.change_admin_password(socket.assigns.current_admin, admin_params)

    {:noreply,
     socket
     |> assign(:password_changeset, Map.put(password_changeset, :action, :validate))
     |> assign(:current_password, password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "admin" => admin_params} = params
    admin = socket.assigns.current_admin

    case Orgs.update_admin_password(admin, password, admin_params) do
      {:ok, admin} ->
        socket =
          socket
          |> assign(:trigger_submit, true)
          |> assign(:password_changeset, Orgs.change_admin_password(admin, admin_params))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :password_changeset, changeset)}
    end
  end
end
