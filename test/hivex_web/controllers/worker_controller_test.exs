defmodule HivexWeb.WorkerControllerTest do
  use HivexWeb.ConnCase

  import Hivex.WorkersFixtures
  alias Hivex.Workers.Worker

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil, access_key_hash: nil}
  @access_key_hash <<1, 2, 3>>

  setup :register_and_log_in_user

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workers", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/workers")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create worker" do
    test "renders worker when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/workers", worker: @create_attrs)
      response = json_response(conn, 201)
      # Assert the response contains access_key and it's non-empty
      assert %{"id" => id, "access_key" => access_key} = response["data"]
      assert access_key
      assert is_binary(access_key)
      assert String.length(access_key) > 0

      # Optionally verify it's Base64 encoded
      assert String.match?(access_key, ~r/^[A-Za-z0-9\+\/]+={0,2}$/)

      # Or verify exact length: 256 bytes = 344 base64 chars (256 * 4 / 3 rounded up)
      assert String.length(access_key) == 344

      conn = get(conn, ~p"/api/v1/workers/#{id}")

      assert %{
               "id" => ^id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/workers", worker: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  # describe "update worker" do
  #   setup [:create_worker]
  #
  #   test "renders worker when data is valid", %{conn: conn, worker: %Worker{id: id} = worker} do
  #     conn = put(conn, ~p"/api/v1/workers/#{worker}", worker: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]
  #
  #     conn = get(conn, ~p"/api/v1/workers/#{id}")
  #
  #     assert %{
  #              "id" => ^id,
  #              "access_key_hash" => "some updated access_key_hash",
  #              "name" => "some updated name"
  #            } = json_response(conn, 200)["data"]
  #   end
  #
  #   test "renders errors when data is invalid", %{conn: conn, worker: worker} do
  #     conn = put(conn, ~p"/api/v1/workers/#{worker}", worker: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  describe "delete worker" do
    setup [:create_worker]

    test "deletes chosen worker", %{conn: conn, worker: worker} do
      conn = delete(conn, ~p"/api/v1/workers/#{worker}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/workers/#{worker}")
      end
    end
  end

  defp create_worker(%{scope: scope}) do
    worker = worker_fixture(scope, @access_key_hash)

    %{worker: worker}
  end
end
