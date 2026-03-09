defmodule Hivex.Containers do
  @moduledoc """
  The Containers context
  """

  import Ecto.Query, warn: false
  alias Hivex.Nginx
  alias DockerEx.Containers
  alias Hivex.Repo

  alias Hivex.Containers.Container
  alias Hivex.Accounts.User

  @hivex_config Application.compile_env!(:hivex, Hivex)

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

      iex> get_container(123, %User{})
      %Container{}

      iex> get_container(456, %User{})
      nill
  """
  def get_container(id, %User{} = user),
    do: Repo.get_by(Container, id: id, user_id: user.id)

  @doc """
  Gets a single container

  Raises `Ecto.NoResultsError` if the Container does not exist.

  ## Examples

      iex> get_container!(123, %User{})
      %Container{}

      iex> get_container!(456, %User{})
      ** (Ecto.NoResultsError)
  """
  def get_container!(id, %User{} = user),
    do: Repo.get_by!(Container, id: id, user_id: user.id)

  @doc """
  Creates a container.

  ## Examples

      iex> create_container(%{
        name: "name",
        image_name: "image",
        host_port: "8080/tcp",
        container_port: "8080/tcp",
        proxy_port: "7080"
      }, %User{})
      {:ok, %Container{}}

      iex> create_container(%{name: "name"})
      {:error, %Ecto.Changeset{}}
  """
  def create_container(attrs, %User{} = user) do
    nginx_network = @hivex_config[:docker_network]

    Repo.transact(fn ->
      with {:ok, container} <-
             %Container{} |> Container.changeset(attrs, user) |> Repo.insert(),
           {:ok, %{"Id" => container_id}} <-
             Containers.create_container(
               %Containers.CreateContainer{
                 Image: container.image_name,
                 NetworkingConfig: %{"EndpointsConfig" => %{nginx_network => %{}}},
                 HostConfig: %{
                   "PortBindings" => %{
                     container.container_port => [
                       %{"HostIp" => "127.0.0.1", "HostPort" => container.host_port}
                     ]
                   }
                 },
                 Env: attrs["env"]
               },
               name: container.name
             ),
           {:ok, _} <- Containers.start_container(container_id),
           :ok <- Nginx.update_nginx_config() do
        {:ok, container}
      else
        error -> error
      end
    end)
  end

  @doc """
  Update a container.

  ## Examples

      iex> update_container(container, %{name: "new_name"}, %User{})
      {:ok, %Container{}}

      iex> update_container(container, %{name: 1}, %User{})
      {:error, %Ecto.Changeset{}}
  """
  def update_container(%Container{} = container, attrs, %User{} = user) do
    container |> Container.changeset(attrs, user) |> Repo.update()
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
  def change_container(%Container{} = container, attrs \\ %{}, %User{} = user) do
    Container.changeset(container, attrs, user)
  end
end
