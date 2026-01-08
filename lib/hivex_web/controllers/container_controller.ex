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

  # def show(conn, %{"id" => id}) do
  #   container = Containers.get_container!(id)
  #   render(conn, :show, container: container)
  # end

  def delete(conn, %{"id" => id}) do
    with {:ok, _} <- Containers.delete_container(id) do
      send_resp(conn, :no_content, "")
    else
      {:error, <<status_code::binary-size(3), " ", error_message::binary>>} ->
        send_resp(conn, String.to_integer(status_code), error_message)
    end
  end
end
