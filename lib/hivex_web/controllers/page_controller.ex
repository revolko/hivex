defmodule HivexWeb.PageController do
  use HivexWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
