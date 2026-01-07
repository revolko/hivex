defmodule HivexWeb.ContainerControllerTest do
  use HivexWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all containers", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/containers")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "delete container" do
    setup [:create_container]

    test "deletes chosen container", %{conn: conn, container: container} do
      conn = delete(conn, ~p"/api/v1/containers/#{container}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/containers/#{container}")
      end
    end
  end

  defp create_container(_) do
    # TODO create dummy container
    %{container: %{}}
  end
end
