defmodule HivexWeb.UserRegistrationController do
  use HivexWeb, :controller

  alias Hivex.Accounts
  alias Hivex.Helpers

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_login_instructions(
            user,
            &url(~p"/api/v1/users/log-in/#{&1}")
          )

        conn
        |> put_status(:created)
        |> json(%{"user" => user_params})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{"errors" => Helpers.format_changeset_errors(changeset)})
    end
  end
end
