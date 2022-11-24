defmodule Chatter.Repo.Migrations.CreateOrgs do
  use Ecto.Migration

  def change do
    create table(:orgs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text

      timestamps()
    end
  end
end
