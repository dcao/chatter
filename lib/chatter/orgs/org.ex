defmodule Chatter.Orgs.Org do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orgs" do
    field :description, :string
    field :name, :string
    has_many :convos, Chatter.Chats.Convo

    many_to_many :admins, Chatter.Orgs.Admin, join_through: "orgs_admins"

    timestamps()
  end

  @doc false
  def changeset(org, attrs) do
    org
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
