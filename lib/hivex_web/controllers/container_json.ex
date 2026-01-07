defmodule HivexWeb.ContainerJSON do
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

  defp data(container) do
    %{
      "id" => container["Id"],
      "name" => container["Names"]
    }
  end
end
