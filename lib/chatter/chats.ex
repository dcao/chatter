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
end
