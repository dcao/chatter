defmodule Chatter.Repo.Migrations.CreateOrgsAdmins do
  use Ecto.Migration

  def change do
    create table(:orgs_admins) do
      add :org_id, references(:orgs, on_delete: :delete_all, type: :binary_id), null: false
      add :admin_id, references(:admins, on_delete: :delete_all, type: :binary_id), null: false
    end

    create unique_index(:orgs_admins, [:org_id, :admin_id])
  end
end
