defmodule Hivex.Workers do
  @moduledoc """
  The Workers context.
  """

  import Ecto.Query, warn: false
  alias Hivex.Repo

  alias Hivex.Workers.Worker
  alias Hivex.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any worker changes.

  The broadcasted messages match the pattern:

    * {:created, %Worker{}}
    * {:updated, %Worker{}}
    * {:deleted, %Worker{}}

  """
  def subscribe_workers(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Hivex.PubSub, "user:#{key}:workers")
  end

  defp broadcast_worker(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Hivex.PubSub, "user:#{key}:workers", message)
  end

  @doc """
  Returns the list of workers.

  ## Examples

      iex> list_workers(scope)
      [%Worker{}, ...]

  """
  def list_workers(%Scope{} = scope) do
    Repo.all_by(Worker, user_id: scope.user.id)
  end

  @doc """
  Gets a single worker.

  Raises `Ecto.NoResultsError` if the Worker does not exist.

  ## Examples

      iex> get_worker!(scope, 123)
      %Worker{}

      iex> get_worker!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_worker!(%Scope{} = scope, id) do
    Repo.get_by!(Worker, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a worker.

  ## Examples

      iex> create_worker(scope, %{field: value}, "key")
      {:ok, %Worker{}}

      iex> create_worker(scope, %{field: bad_value}, "key")
      {:error, %Ecto.Changeset{}}

  """
  def create_worker(%Scope{} = scope, attrs, access_key) do
    access_key_hash = hash_access_key(access_key)

    with {:ok, worker = %Worker{}} <-
           %Worker{}
           |> Worker.changeset(attrs, scope, access_key_hash)
           |> Repo.insert() do
      broadcast_worker(scope, {:created, worker})
      {:ok, worker}
    end
  end

  @doc """
  Updates a worker.

  ## Examples

      iex> update_worker(scope, worker, %{field: new_value})
      {:ok, %Worker{}}

      iex> update_worker(scope, worker, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_worker(%Scope{} = scope, %Worker{} = worker, attrs) do
    true = worker.user_id == scope.user.id

    with {:ok, worker = %Worker{}} <-
           worker
           |> Worker.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_worker(scope, {:updated, worker})
      {:ok, worker}
    end
  end

  @doc """
  Deletes a worker.

  ## Examples

      iex> delete_worker(scope, worker)
      {:ok, %Worker{}}

      iex> delete_worker(scope, worker)
      {:error, %Ecto.Changeset{}}

  """
  def delete_worker(%Scope{} = scope, %Worker{} = worker) do
    true = worker.user_id == scope.user.id

    with {:ok, worker = %Worker{}} <-
           Repo.delete(worker) do
      broadcast_worker(scope, {:deleted, worker})
      {:ok, worker}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking worker changes.

  ## Examples

      iex> change_worker(scope, worker)
      %Ecto.Changeset{data: %Worker{}}

  """
  def change_worker(%Scope{} = scope, %Worker{} = worker, attrs \\ %{}) do
    true = worker.user_id == scope.user.id

    Worker.changeset(worker, attrs, scope)
  end

  defp hash_access_key(access_key) do
    :crypto.hash(:sha256, access_key)
  end
end
