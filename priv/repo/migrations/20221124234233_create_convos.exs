defmodule Chatter.Repo.Migrations.CreateConvos do
  use Ecto.Migration

  def change do
    create table(:convos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :room_name, :string, null: false
      add :org_id, references(:orgs, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create unique_index(:convos, [:room_name])
    create index(:convos, [:org_id])
  end
end
