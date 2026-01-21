defmodule HivexWeb.ContainerController do
  use HivexWeb, :controller
  require Logger

  alias DockerEx.Containers
  alias Hivex.Nginx

  action_fallback HivexWeb.FallbackController

  @hivex_config Application.compile_env!(:hivex, Hivex)

  def index(conn, params) do
    {:ok, containers} =
      Containers.list_containers(
        Enum.map(params, fn {key, value} -> {String.to_existing_atom(key), value} end)
      )

    render(conn, :index, containers: containers)
  end

  def create(conn, %{"container" => container_params, "nginx_conf" => nginx_conf}) do
    nginx_network = @hivex_config[:docker_network]

    # TODO: better error handling
    {:ok, container} =
      with {:ok, %{"Id" => container_id}} <-
             Containers.create_container(
               %Containers.CreateContainer{
                 Image: container_params["image"],
                 NetworkingConfig: %{"EndpointsConfig" => %{nginx_network => %{}}},
                 HostConfig: %{
                   "PortBindings" => %{
                     container_params["exposed_port"] => [
                       %{"HostIp" => "127.0.0.1", "HostPort" => container_params["host_port"]}
                     ]
                   }
                 },
                 Env: container_params["env"]
               },
               name: container_params["name"]
             ),
           {:ok, _} <- Containers.start_container(container_id),
           do: Containers.inspect_container(container_id)

    Nginx.add_server("_", nginx_conf["listen_port"], container_params["host_port"])
    Nginx.reload_server({:docker, "hivex-proxy-1"})
    render(conn, :show, container: container)
  end

  def show(conn, %{"id" => id}) do
    {:ok, container} = Containers.inspect_container(id)
    render(conn, :show, container: container)
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _} <- Containers.delete_container(id) do
      send_resp(conn, :no_content, "")
    else
      {:error, <<status_code::binary-size(3), " ", error_message::binary>>} ->
        send_resp(conn, String.to_integer(status_code), error_message)
    end
  end
end
