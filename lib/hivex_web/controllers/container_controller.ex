defmodule HivexWeb.ContainerController do
  use HivexWeb, :controller
  require Logger

  alias DockerEx.Containers
  alias Hivex.Nginx
  alias Hivex.Containers, as: DbContainers
  alias Hivex.Containers.Container, as: DbContainer

  action_fallback HivexWeb.FallbackController

  @hivex_config Application.compile_env!(:hivex, Hivex)

  def index(conn, _params) do
    containers = DbContainers.list_containers()
    render(conn, :index, containers: containers)
  end

  def create(conn, %{"container" => container_params}) do
    nginx_network = @hivex_config[:docker_network]
    # TODO: better error handling
    with {:ok, %DbContainer{} = container} <- DbContainers.create_container(container_params),
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
               Env: container_params["env"]
             },
             name: container.name
           ),
         {:ok, _} <- Containers.start_container(container_id),
         :ok <- Nginx.update_nginx_config(),
         do: render(conn, :show, container: container)
  end

  def show(conn, %{"id" => id}) do
    container = DbContainers.get_container!(id)
    render(conn, :show, container: container)
  end

  def delete(conn, %{"id" => id} = params) do
    force = Map.get(params, "force", "false")

    with %DbContainer{} = container <- DbContainers.get_container(id),
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
