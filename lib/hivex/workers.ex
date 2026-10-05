defmodule Hivex.Workers do
  @moduledoc """
  The Workers context.
  """

  import Ecto.Query, warn: false
  alias Hivex.Repo

  alias Hivex.Workers.Worker
  alias Hivex.Accounts.Scope

  defp send_worker_message(worker_id, event, message \\ %{}) do
    HivexWeb.Endpoint.broadcast("workers:#{worker_id}", event, message)
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
      send_worker_message(worker.id, "disconnect")
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

  @doc """
  Validates the workers access key

  ## Examples

      iex> is_valid_access_key?(1, "correct")
      true
      iex> is_valid_access_key?(1, "invalid")
      false
  """
  def is_valid_access_key?(worker_id, access_key) do
    access_key_hash = :crypto.hash(:sha256, access_key)

    case Repo.get_by(Worker, id: worker_id, access_key_hash: access_key_hash) do
      nil -> false
      _ -> true
    end
  end

  defp hash_access_key(access_key) do
    :crypto.hash(:sha256, access_key)
  end
end
