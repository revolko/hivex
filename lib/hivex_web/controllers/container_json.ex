defmodule HivexWeb.ContainerJSON do
  alias Hivex.Containers.Container

  @doc """
  Renders a list of containers.
  """
  def index(%{containers: containers}) do
    %{data: for(container <- containers, do: data(container))}
  end

  @doc """
  Renders a single container.
  """
  def show(%{container: container}) do
    %{data: data(container)}
  end

  defp data(%Container{} = container) do
    %{
      id: container.id,
      name: container.name,
      image_name: container.image_name,
      host_port: container.host_port,
      container_port: container.container_port,
      proxy_port: container.proxy_port
    }
  end

  defp data(container, simple \\ false) do
    if simple do
      %{
        "Id" => container["Id"],
        "Names" => container["Names"]
      }
    else
      container
    end
  end
end
