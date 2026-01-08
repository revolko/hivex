defmodule HivexWeb.ContainerJSON do
  @doc """
  Renders a list of containers.
  """
  def index(%{containers: containers}) do
    %{data: for(container <- containers, do: data(container, simple: true))}
  end

  @doc """
  Renders a single container.
  """
  def show(%{container: container}) do
    %{data: data(container)}
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
