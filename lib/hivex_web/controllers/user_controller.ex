defmodule HivexWeb.UserController do
  use HivexWeb, :controller
  use PhoenixSwagger

  alias Hivex.Users
  alias Hivex.Users.User

  action_fallback HivexWeb.FallbackController

  def swagger_definitions do
    %{
      User:
        swagger_schema do
          title("User")
          description("A user of the application")

          properties do
            name(:string, "Users name", required: true)
            email(:string, "Users email", required: true)
          end

          example(%{
            name: "Joe",
            email: "joe@random.com"
          })
        end,
      Users:
        swagger_schema do
          title("Users")
          description("A collection of Users")

          properties do
            data(
              Schema.new do
                type(:array)
                items(Schema.ref(:User))
              end
            )
          end
        end
    }
  end

  swagger_path "index" do
    get("/api/v1/users")
    description("List all users")
    response(200, "Success", Schema.ref(:Users))
  end

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
