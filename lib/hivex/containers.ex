defmodule Hivex.Containers do
  @moduledoc """
  The Containers context
  """

  import Ecto.Query, warn: false
  alias Hivex.Repo

  alias Hivex.Containers.Container

  @doc """
  Return the list of containers

  ## Examples

      iex> list_containers()
      [%Container{}, ...]
  """
  def list_containers do
    Repo.all(Container)
  end

  @doc """
  Gets a single container

  ## Examples

      iex> get_container(123)
      %Container{}

      iex> get_container(456)
      nill
  """
  def get_container(id), do: Repo.get(Container, id)

  @doc """
  Gets a single container

  Raises `Ecto.NoResultsError` if the Container does not exist.

  ## Examples

      iex> get_container!(123)
      %Container{}

      iex> get_container!(456)
      ** (Ecto.NoResultsError)
  """
  def get_container!(id), do: Repo.get!(Container, id)

  @doc """
  Creates a container.

  ## Examples

      iex> create_container(%{
        name: "name",
        image_name: "image",
        host_port: "8080/tcp",
        container_port: "8080/tcp",
        proxy_port: "7080"
      })
      {:ok, %Container{}}

      iex> create_container(%{name: "name"})
      {:error, %Ecto.Changeset{}}
  """
  def create_container(attrs) do
    %Container{} |> Container.changeset(attrs) |> Repo.insert()
  end

  @doc """
  Update a container.

  ## Examples

      iex> update_container(container, %{name: "new_name"})
      {:ok, %Container{}}

      iex> update_container(container, %{name: 1})
      {:error, %Ecto.Changeset{}}
  """
  def update_container(%Container{} = container, attrs) do
    container |> Container.changeset(attrs) |> Repo.update()
  end

  @doc """
  Deletes container.

  ## Examples

      iex> delete_container(container)
      {:ok, %Container{}}

      iex> delete_container(container)
      {:error, %Ecto.Changeset{}}
  """
  def delete_container(%Container{} = container) do
    Repo.delete(container)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service changes.

  ## Examples

      iex> change_container(container)
      %Ecto.Changeset{data: %Container{}}
  """
  def change_container(%Container{} = container, attrs \\ %{}) do
    Container.changeset(container, attrs)
  end
end
