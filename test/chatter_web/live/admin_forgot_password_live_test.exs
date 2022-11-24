defmodule ChatterWeb.AdminForgotPasswordLiveTest do
  use ChatterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Chatter.OrgsFixtures

  alias Chatter.Orgs
  alias Chatter.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/admins/reset_password")

      assert html =~ "Forgot your password?"
      assert html =~ "Register</a>"
      assert html =~ "Log in</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_admin(admin_fixture())
        |> live(~p"/admins/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{admin: admin_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, admin: admin} do
      {:ok, lv, _html} = live(conn, ~p"/admins/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", admin: %{"email" => admin.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      assert Repo.get_by!(Orgs.AdminToken, admin_id: admin.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admins/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", admin: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Repo.all(Orgs.AdminToken) == []
    end
  end
end
