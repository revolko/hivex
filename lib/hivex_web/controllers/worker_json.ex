defmodule HivexWeb.WorkerJSON do
  alias Hivex.Workers.Worker

  @doc """
  Renders a list of workers.
  """
  def index(%{workers: workers}) do
    %{data: for(worker <- workers, do: data(worker))}
  end

  @doc """
  Renders a single worker.
  """
  def show(%{worker: worker, access_key: access_key}) do
    %{data: data(worker, access_key)}
  end

  def show(%{worker: worker}) do
    %{data: data(worker)}
  end

  defp data(%Worker{} = worker) do
    %{
      id: worker.id,
      name: worker.name
    }
  end

  defp data(%Worker{} = worker, access_key) do
    %{
      id: worker.id,
      name: worker.name,
      access_key: access_key
    }
  end
end
