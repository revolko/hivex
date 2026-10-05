defmodule HivexWeb.HiveChannelTest do
  use HivexWeb.ChannelCase

  alias Hivex.WorkersFixtures

  setup do
    {:ok, _, socket} =
      HivexWeb.WorkerSocket
      |> socket("hive:1", %{worker_id: "1"})
      |> subscribe_and_join(HivexWeb.HiveChannel, "hive:1")

    %{socket: socket}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
