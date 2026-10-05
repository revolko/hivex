defmodule HivexWeb.HiveChannel do
  use HivexWeb, :channel

  @impl true
  def join("hive:" <> worker_id, _payload, socket) do
    if authorized?(worker_id, socket) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  defp authorized?(worker_id, socket) do
    worker_id == socket.assigns.worker_id
  end
end
