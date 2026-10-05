defmodule HivexWeb.WorkerSocket do
  use Phoenix.Socket

  alias Hivex.Workers

  require Logger

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels
  channel "hive:*", HivexWeb.HiveChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error` or `{:error, term}`. To control the
  # response the client receives in that case, [define an error handler in the
  # websocket
  # configuration](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#socket/3-websocket-configuration).
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"worker_id" => worker_id}, socket, %{auth_token: access_key}) do
    if Workers.is_valid_access_key?(worker_id, access_key) do
      {:ok, assign(socket, :worker_id, worker_id)}
    else
      {:error, :unauthorized}
    end
  end

  @impl true
  def connect(params, _socket, _connect_info) do
    Logger.debug(message: "Received broken worker socket connection", params: params)
    :error
  end

  # Socket IDs are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.HivexWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket), do: "workers:#{socket.assigns.worker_id}"
end
