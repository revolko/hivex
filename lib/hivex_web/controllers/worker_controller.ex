defmodule HivexWeb.WorkerController do
  use HivexWeb, :controller

  alias Hivex.Workers
  alias Hivex.Workers.Worker

  @access_key_lenght 256

  action_fallback HivexWeb.FallbackController

  def index(conn, _params) do
    workers = Workers.list_workers(conn.assigns.current_scope)
    render(conn, :index, workers: workers)
  end

  def create(conn, %{"worker" => worker_params}) do
    access_key = :crypto.strong_rand_bytes(@access_key_lenght) |> Base.encode64()

    with {:ok, %Worker{} = worker} <-
           Workers.create_worker(conn.assigns.current_scope, worker_params, access_key) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/workers/#{worker}")
      |> render(:show, worker: worker, access_key: access_key)
    end
  end

  def show(conn, %{"id" => id}) do
    worker = Workers.get_worker!(conn.assigns.current_scope, id)
    render(conn, :show, worker: worker)
  end

  # def update(conn, %{"id" => id, "worker" => worker_params}) do
  #   worker = Workers.get_worker!(conn.assigns.current_scope, id)
  #
  #   with {:ok, %Worker{} = worker} <-
  #          Workers.update_worker(conn.assigns.current_scope, worker, worker_params) do
  #     render(conn, :show, worker: worker)
  #   end
  # end

  def delete(conn, %{"id" => id}) do
    worker = Workers.get_worker!(conn.assigns.current_scope, id)

    with {:ok, %Worker{}} <- Workers.delete_worker(conn.assigns.current_scope, worker) do
      send_resp(conn, :no_content, "")
    end
  end
end
