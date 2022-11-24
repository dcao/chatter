defmodule Chatter.ChatsTest do
  use Chatter.DataCase

  alias Chatter.Chats

  describe "convos" do
    alias Chatter.Chats.Convo

    import Chatter.ChatsFixtures

    @invalid_attrs %{room_name: nil}

    test "list_convos/0 returns all convos" do
      convo = convo_fixture()
      assert Chats.list_convos() == [convo]
    end

    test "get_convo!/1 returns the convo with given id" do
      convo = convo_fixture()
      assert Chats.get_convo!(convo.id) == convo
    end

    test "create_convo/1 with valid data creates a convo" do
      valid_attrs = %{room_name: "some room_name"}

      assert {:ok, %Convo{} = convo} = Chats.create_convo(valid_attrs)
      assert convo.room_name == "some room_name"
    end

    test "create_convo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_convo(@invalid_attrs)
    end

    test "update_convo/2 with valid data updates the convo" do
      convo = convo_fixture()
      update_attrs = %{room_name: "some updated room_name"}

      assert {:ok, %Convo{} = convo} = Chats.update_convo(convo, update_attrs)
      assert convo.room_name == "some updated room_name"
    end

    test "update_convo/2 with invalid data returns error changeset" do
      convo = convo_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_convo(convo, @invalid_attrs)
      assert convo == Chats.get_convo!(convo.id)
    end

    test "delete_convo/1 deletes the convo" do
      convo = convo_fixture()
      assert {:ok, %Convo{}} = Chats.delete_convo(convo)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_convo!(convo.id) end
    end

    test "change_convo/1 returns a convo changeset" do
      convo = convo_fixture()
      assert %Ecto.Changeset{} = Chats.change_convo(convo)
    end
  end
end
