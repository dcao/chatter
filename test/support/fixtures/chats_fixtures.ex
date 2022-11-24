defmodule Chatter.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chatter.Chats` context.
  """

  @doc """
  Generate a unique convo room_name.
  """
  def unique_convo_room_name, do: "some room_name#{System.unique_integer([:positive])}"

  @doc """
  Generate a convo.
  """
  def convo_fixture(attrs \\ %{}) do
    {:ok, convo} =
      attrs
      |> Enum.into(%{
        room_name: unique_convo_room_name()
      })
      |> Chatter.Chats.create_convo()

    convo
  end
end
