defmodule Chatter.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias Chatter.Repo

  alias Chatter.Chats.Convo

  @doc """
  Returns the list of convos.

  ## Examples

      iex> list_convos()
      [%Convo{}, ...]

  """
  def list_convos do
    Repo.all(Convo)
  end

  @doc """
  Gets a single convo.

  Raises `Ecto.NoResultsError` if the Convo does not exist.

  ## Examples

      iex> get_convo!(123)
      %Convo{}

      iex> get_convo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_convo!(id), do: Repo.get!(Convo, id)

  @doc """
  Creates a convo.

  ## Examples

      iex> create_convo(%{field: value})
      {:ok, %Convo{}}

      iex> create_convo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_convo(attrs \\ %{}) do
    %Convo{}
    |> Convo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a convo.

  ## Examples

      iex> update_convo(convo, %{field: new_value})
      {:ok, %Convo{}}

      iex> update_convo(convo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_convo(%Convo{} = convo, attrs) do
    convo
    |> Convo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a convo.

  ## Examples

      iex> delete_convo(convo)
      {:ok, %Convo{}}

      iex> delete_convo(convo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_convo(%Convo{} = convo) do
    Repo.delete(convo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking convo changes.

  ## Examples

      iex> change_convo(convo)
      %Ecto.Changeset{data: %Convo{}}

  """
  def change_convo(%Convo{} = convo, attrs \\ %{}) do
    Convo.changeset(convo, attrs)
  end

  alias Chatter.Chats.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
