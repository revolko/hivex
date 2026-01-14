defmodule HivexWeb.ContainerController do
  use HivexWeb, :controller
  require Logger

  alias DockerEx.Containers

  action_fallback HivexWeb.FallbackController

  def index(conn, params) do
    {:ok, containers} =
      Containers.list_containers(
        Enum.map(params, fn {key, value} -> {String.to_existing_atom(key), value} end)
      )

    render(conn, :index, containers: containers)
  end

  def create(conn, %{"container" => container_params}) do
    with {:ok, %{"Id" => container_id}} <-
           Containers.create_container(
             %Containers.CreateContainer{Image: container_params["image"]},
             name: container_params["name"]
           ),
         {:ok, _} <- Containers.start_container(container_id),
         {:ok, container} <- Containers.inspect_container(container_id) do
      render(conn, :show, container: container)
    end
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
