defmodule Chatter.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text
      add :admin_id, references(:admins, on_delete: :nothing, type: :binary_id)
      add :convo_id, references(:convos, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:messages, [:admin_id])
    create index(:messages, [:convo_id])
  end
end
