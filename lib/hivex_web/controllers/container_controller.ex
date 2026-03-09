defmodule HivexWeb.ContainerController do
  use HivexWeb, :controller
  require Logger

  alias DockerEx.Containers
  alias Hivex.Nginx
  alias Hivex.Containers, as: DbContainers
  alias Hivex.Containers.Container, as: DbContainer
  alias Hivex.Helpers

  action_fallback HivexWeb.FallbackController

  def index(conn, _params) do
    containers = DbContainers.list_containers()
    render(conn, :index, containers: containers)
  end

  def create(conn, %{"container" => container_params}) do
    user = Guardian.Plug.current_resource(conn)
    # TODO: better error handling
    container_params = Map.put(container_params, "user_id", user.id)

    with {:ok, container} <- DbContainers.create_container(container_params, user) do
      render(conn, :show, container: container)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{"errors" => Helpers.format_changeset_errors(changeset)})

      {:error, reason} ->
        conn |> put_status(:internal_server_error) |> json(%{"errors" => [reason]})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    container = DbContainers.get_container!(id, user)
    render(conn, :show, container: container)
  end

  def delete(conn, %{"id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)
    force = Map.get(params, "force", "false")

    with %DbContainer{} = container <- DbContainers.get_container(id, user),
         {:ok, _} <- Containers.delete_container(container.name, force: force),
         {:ok, _} <- DbContainers.delete_container(container),
         :ok <- Nginx.update_nginx_config() do
      send_resp(conn, :no_content, "")
    else
      nil ->
        send_resp(conn, :not_found, "Container not found")

      {:error, error} ->
        send_resp(conn, :internal_server_error, error)
    end
  end
end
