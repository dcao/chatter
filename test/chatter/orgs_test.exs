defmodule Chatter.OrgsTest do
  use Chatter.DataCase

  alias Chatter.Orgs

  import Chatter.OrgsFixtures
  alias Chatter.Orgs.{Admin, AdminToken}

  describe "get_admin_by_email/1" do
    test "does not return the admin if the email does not exist" do
      refute Orgs.get_admin_by_email("unknown@example.com")
    end

    test "returns the admin if the email exists" do
      %{id: id} = admin = admin_fixture()
      assert %Admin{id: ^id} = Orgs.get_admin_by_email(admin.email)
    end
  end

  describe "get_admin_by_email_and_password/2" do
    test "does not return the admin if the email does not exist" do
      refute Orgs.get_admin_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the admin if the password is not valid" do
      admin = admin_fixture()
      refute Orgs.get_admin_by_email_and_password(admin.email, "invalid")
    end

    test "returns the admin if the email and password are valid" do
      %{id: id} = admin = admin_fixture()

      assert %Admin{id: ^id} =
               Orgs.get_admin_by_email_and_password(admin.email, valid_admin_password())
    end
  end

  describe "get_admin!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Orgs.get_admin!("11111111-1111-1111-1111-111111111111")
      end
    end

    test "returns the admin with the given id" do
      %{id: id} = admin = admin_fixture()
      assert %Admin{id: ^id} = Orgs.get_admin!(admin.id)
    end
  end

  describe "register_admin/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Orgs.register_admin(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Orgs.register_admin(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Orgs.register_admin(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = admin_fixture()
      {:error, changeset} = Orgs.register_admin(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Orgs.register_admin(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers admins with a hashed password" do
      email = unique_admin_email()
      {:ok, admin} = Orgs.register_admin(valid_admin_attributes(email: email))
      assert admin.email == email
      assert is_binary(admin.hashed_password)
      assert is_nil(admin.confirmed_at)
      assert is_nil(admin.password)
    end
  end

  describe "change_admin_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Orgs.change_admin_registration(%Admin{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_admin_email()
      password = valid_admin_password()

      changeset =
        Orgs.change_admin_registration(
          %Admin{},
          valid_admin_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_admin_email/2" do
    test "returns a admin changeset" do
      assert %Ecto.Changeset{} = changeset = Orgs.change_admin_email(%Admin{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_admin_email/3" do
    setup do
      %{admin: admin_fixture()}
    end

    test "requires email to change", %{admin: admin} do
      {:error, changeset} = Orgs.apply_admin_email(admin, valid_admin_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{admin: admin} do
      {:error, changeset} =
        Orgs.apply_admin_email(admin, valid_admin_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{admin: admin} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Orgs.apply_admin_email(admin, valid_admin_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{admin: admin} do
      %{email: email} = admin_fixture()
      password = valid_admin_password()

      {:error, changeset} = Orgs.apply_admin_email(admin, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{admin: admin} do
      {:error, changeset} =
        Orgs.apply_admin_email(admin, "invalid", %{email: unique_admin_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{admin: admin} do
      email = unique_admin_email()
      {:ok, admin} = Orgs.apply_admin_email(admin, valid_admin_password(), %{email: email})
      assert admin.email == email
      assert Orgs.get_admin!(admin.id).email != email
    end
  end

  describe "deliver_admin_update_email_instructions/3" do
    setup do
      %{admin: admin_fixture()}
    end

    test "sends token through notification", %{admin: admin} do
      token =
        extract_admin_token(fn url ->
          Orgs.deliver_admin_update_email_instructions(admin, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert admin_token = Repo.get_by(AdminToken, token: :crypto.hash(:sha256, token))
      assert admin_token.admin_id == admin.id
      assert admin_token.sent_to == admin.email
      assert admin_token.context == "change:current@example.com"
    end
  end

  describe "update_admin_email/2" do
    setup do
      admin = admin_fixture()
      email = unique_admin_email()

      token =
        extract_admin_token(fn url ->
          Orgs.deliver_admin_update_email_instructions(%{admin | email: email}, admin.email, url)
        end)

      %{admin: admin, token: token, email: email}
    end

    test "updates the email with a valid token", %{admin: admin, token: token, email: email} do
      assert Orgs.update_admin_email(admin, token) == :ok
      changed_admin = Repo.get!(Admin, admin.id)
      assert changed_admin.email != admin.email
      assert changed_admin.email == email
      assert changed_admin.confirmed_at
      assert changed_admin.confirmed_at != admin.confirmed_at
      refute Repo.get_by(AdminToken, admin_id: admin.id)
    end

    test "does not update email with invalid token", %{admin: admin} do
      assert Orgs.update_admin_email(admin, "oops") == :error
      assert Repo.get!(Admin, admin.id).email == admin.email
      assert Repo.get_by(AdminToken, admin_id: admin.id)
    end

    test "does not update email if admin email changed", %{admin: admin, token: token} do
      assert Orgs.update_admin_email(%{admin | email: "current@example.com"}, token) == :error
      assert Repo.get!(Admin, admin.id).email == admin.email
      assert Repo.get_by(AdminToken, admin_id: admin.id)
    end

    test "does not update email if token expired", %{admin: admin, token: token} do
      {1, nil} = Repo.update_all(AdminToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Orgs.update_admin_email(admin, token) == :error
      assert Repo.get!(Admin, admin.id).email == admin.email
      assert Repo.get_by(AdminToken, admin_id: admin.id)
    end
  end

  describe "change_admin_password/2" do
    test "returns a admin changeset" do
      assert %Ecto.Changeset{} = changeset = Orgs.change_admin_password(%Admin{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Orgs.change_admin_password(%Admin{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_admin_password/3" do
    setup do
      %{admin: admin_fixture()}
    end

    test "validates password", %{admin: admin} do
      {:error, changeset} =
        Orgs.update_admin_password(admin, valid_admin_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{admin: admin} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Orgs.update_admin_password(admin, valid_admin_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{admin: admin} do
      {:error, changeset} =
        Orgs.update_admin_password(admin, "invalid", %{password: valid_admin_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{admin: admin} do
      {:ok, admin} =
        Orgs.update_admin_password(admin, valid_admin_password(), %{
          password: "new valid password"
        })

      assert is_nil(admin.password)
      assert Orgs.get_admin_by_email_and_password(admin.email, "new valid password")
    end

    test "deletes all tokens for the given admin", %{admin: admin} do
      _ = Orgs.generate_admin_session_token(admin)

      {:ok, _} =
        Orgs.update_admin_password(admin, valid_admin_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(AdminToken, admin_id: admin.id)
    end
  end

  describe "generate_admin_session_token/1" do
    setup do
      %{admin: admin_fixture()}
    end

    test "generates a token", %{admin: admin} do
      token = Orgs.generate_admin_session_token(admin)
      assert admin_token = Repo.get_by(AdminToken, token: token)
      assert admin_token.context == "session"

      # Creating the same token for another admin should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%AdminToken{
          token: admin_token.token,
          admin_id: admin_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_admin_by_session_token/1" do
    setup do
      admin = admin_fixture()
      token = Orgs.generate_admin_session_token(admin)
      %{admin: admin, token: token}
    end

    test "returns admin by token", %{admin: admin, token: token} do
      assert session_admin = Orgs.get_admin_by_session_token(token)
      assert session_admin.id == admin.id
    end

    test "does not return admin for invalid token" do
      refute Orgs.get_admin_by_session_token("oops")
    end

    test "does not return admin for expired token", %{token: token} do
      {1, nil} = Repo.update_all(AdminToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Orgs.get_admin_by_session_token(token)
    end
  end

  describe "delete_admin_session_token/1" do
    test "deletes the token" do
      admin = admin_fixture()
      token = Orgs.generate_admin_session_token(admin)
      assert Orgs.delete_admin_session_token(token) == :ok
      refute Orgs.get_admin_by_session_token(token)
    end
  end

  describe "deliver_admin_confirmation_instructions/2" do
    setup do
      %{admin: admin_fixture()}
    end

    test "sends token through notification", %{admin: admin} do
      token =
        extract_admin_token(fn url ->
          Orgs.deliver_admin_confirmation_instructions(admin, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert admin_token = Repo.get_by(AdminToken, token: :crypto.hash(:sha256, token))
      assert admin_token.admin_id == admin.id
      assert admin_token.sent_to == admin.email
      assert admin_token.context == "confirm"
    end
  end

  describe "confirm_admin/1" do
    setup do
      admin = admin_fixture()

      token =
        extract_admin_token(fn url ->
          Orgs.deliver_admin_confirmation_instructions(admin, url)
        end)

      %{admin: admin, token: token}
    end

    test "confirms the email with a valid token", %{admin: admin, token: token} do
      assert {:ok, confirmed_admin} = Orgs.confirm_admin(token)
      assert confirmed_admin.confirmed_at
      assert confirmed_admin.confirmed_at != admin.confirmed_at
      assert Repo.get!(Admin, admin.id).confirmed_at
      refute Repo.get_by(AdminToken, admin_id: admin.id)
    end

    test "does not confirm with invalid token", %{admin: admin} do
      assert Orgs.confirm_admin("oops") == :error
      refute Repo.get!(Admin, admin.id).confirmed_at
      assert Repo.get_by(AdminToken, admin_id: admin.id)
    end

    test "does not confirm email if token expired", %{admin: admin, token: token} do
      {1, nil} = Repo.update_all(AdminToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Orgs.confirm_admin(token) == :error
      refute Repo.get!(Admin, admin.id).confirmed_at
      assert Repo.get_by(AdminToken, admin_id: admin.id)
    end
  end

  describe "deliver_admin_reset_password_instructions/2" do
    setup do
      %{admin: admin_fixture()}
    end

    test "sends token through notification", %{admin: admin} do
      token =
        extract_admin_token(fn url ->
          Orgs.deliver_admin_reset_password_instructions(admin, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert admin_token = Repo.get_by(AdminToken, token: :crypto.hash(:sha256, token))
      assert admin_token.admin_id == admin.id
      assert admin_token.sent_to == admin.email
      assert admin_token.context == "reset_password"
    end
  end

  describe "get_admin_by_reset_password_token/1" do
    setup do
      admin = admin_fixture()

      token =
        extract_admin_token(fn url ->
          Orgs.deliver_admin_reset_password_instructions(admin, url)
        end)

      %{admin: admin, token: token}
    end

    test "returns the admin with valid token", %{admin: %{id: id}, token: token} do
      assert %Admin{id: ^id} = Orgs.get_admin_by_reset_password_token(token)
      assert Repo.get_by(AdminToken, admin_id: id)
    end

    test "does not return the admin with invalid token", %{admin: admin} do
      refute Orgs.get_admin_by_reset_password_token("oops")
      assert Repo.get_by(AdminToken, admin_id: admin.id)
    end

    test "does not return the admin if token expired", %{admin: admin, token: token} do
      {1, nil} = Repo.update_all(AdminToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Orgs.get_admin_by_reset_password_token(token)
      assert Repo.get_by(AdminToken, admin_id: admin.id)
    end
  end

  describe "reset_admin_password/2" do
    setup do
      %{admin: admin_fixture()}
    end

    test "validates password", %{admin: admin} do
      {:error, changeset} =
        Orgs.reset_admin_password(admin, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{admin: admin} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Orgs.reset_admin_password(admin, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{admin: admin} do
      {:ok, updated_admin} = Orgs.reset_admin_password(admin, %{password: "new valid password"})
      assert is_nil(updated_admin.password)
      assert Orgs.get_admin_by_email_and_password(admin.email, "new valid password")
    end

    test "deletes all tokens for the given admin", %{admin: admin} do
      _ = Orgs.generate_admin_session_token(admin)
      {:ok, _} = Orgs.reset_admin_password(admin, %{password: "new valid password"})
      refute Repo.get_by(AdminToken, admin_id: admin.id)
    end
  end

  describe "inspect/2 for the Admin module" do
    test "does not include password" do
      refute inspect(%Admin{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "orgs" do
    alias Chatter.Orgs.Org

    import Chatter.OrgsFixtures

    @invalid_attrs %{description: nil, name: nil}

    test "list_orgs/0 returns all orgs" do
      org = org_fixture()
      assert Orgs.list_orgs() == [org]
    end

    test "get_org!/1 returns the org with given id" do
      org = org_fixture()
      assert Orgs.get_org!(org.id) == org
    end

    test "create_org/1 with valid data creates a org" do
      valid_attrs = %{description: "some description", name: "some name"}

      assert {:ok, %Org{} = org} = Orgs.create_org(valid_attrs)
      assert org.description == "some description"
      assert org.name == "some name"
    end

    test "create_org/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orgs.create_org(@invalid_attrs)
    end

    test "update_org/2 with valid data updates the org" do
      org = org_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name"}

      assert {:ok, %Org{} = org} = Orgs.update_org(org, update_attrs)
      assert org.description == "some updated description"
      assert org.name == "some updated name"
    end

    test "update_org/2 with invalid data returns error changeset" do
      org = org_fixture()
      assert {:error, %Ecto.Changeset{}} = Orgs.update_org(org, @invalid_attrs)
      assert org == Orgs.get_org!(org.id)
    end

    test "delete_org/1 deletes the org" do
      org = org_fixture()
      assert {:ok, %Org{}} = Orgs.delete_org(org)
      assert_raise Ecto.NoResultsError, fn -> Orgs.get_org!(org.id) end
    end

    test "change_org/1 returns a org changeset" do
      org = org_fixture()
      assert %Ecto.Changeset{} = Orgs.change_org(org)
    end
  end
end
