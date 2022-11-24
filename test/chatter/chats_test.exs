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

  describe "messages" do
    alias Chatter.Chats.Message

    import Chatter.ChatsFixtures

    @invalid_attrs %{content: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chats.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chats.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{content: "some content"}

      assert {:ok, %Message{} = message} = Chats.create_message(valid_attrs)
      assert message.content == "some content"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Message{} = message} = Chats.update_message(message, update_attrs)
      assert message.content == "some updated content"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_message(message, @invalid_attrs)
      assert message == Chats.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chats.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chats.change_message(message)
    end
  end
end
