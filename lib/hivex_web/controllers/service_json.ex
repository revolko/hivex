defmodule HivexWeb.ServiceJSON do
  alias Hivex.Services.Service

  @doc """
  Renders a list of services.
  """
  def index(%{services: services}) do
    %{data: for(service <- services, do: data(service))}
  end

  @doc """
  Renders a single service.
  """
  def show(%{service: service}) do
    %{data: data(service)}
  end

  defp data(%Service{} = service) do
    %{
      id: service.id,
      name: service.name,
      user: %{
        id: service.user.id,
        name: service.user.name
      }
    }
  end
end
