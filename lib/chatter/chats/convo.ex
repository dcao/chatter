defmodule Chatter.Chats.Convo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "convos" do
    field :room_name, :string
    belongs_to :org, Chatter.Orgs.Org
    has_many :messages, Chatter.Chats.Message

    timestamps()
  end

  @doc false
  def changeset(convo, attrs) do
    convo
    |> cast(attrs, [:room_name])
    |> validate_required([:room_name])
    |> unique_constraint(:room_name)
  end
end
