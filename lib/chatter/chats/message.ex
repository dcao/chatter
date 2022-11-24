defmodule Chatter.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :content, :string
    belongs_to :admin, Chatter.Orgs.Admin
    belongs_to :convo, Chatter.Chats.Convo

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
