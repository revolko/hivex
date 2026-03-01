defmodule HivexWeb.UserSettingsController do
  use HivexWeb, :controller

  require Logger

  alias Hivex.Accounts
  alias Hivex.Accounts.Guardian
  alias Hivex.Helpers

  def update(conn, %{"action" => "update_email"} = params) do
    %{"user" => user_params} = params
    user = Guardian.Plug.current_resource(conn)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/api/v1/users/settings/confirm-email/#{&1}")
        )

        conn
        |> put_status(:no_content)
        |> json(%{})

      changeset ->
        conn
        |> put_status(:bad_request)
        |> json(%{"errors" => Helpers.format_changeset_errors(changeset)})
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"user" => user_params} = params
    user = Guardian.Plug.current_resource(conn)

    case Accounts.update_user_password(user, user_params) do
      {:ok, _} ->
        conn
        |> send_resp(:no_content, "")

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{"errors" => Helpers.format_changeset_errors(changeset)})
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    user = Guardian.Plug.current_resource(conn)

    case Accounts.update_user_email(user, token) do
      {:ok, _user} ->
        conn
        |> put_status(:ok)
        |> json(%{})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{"errors" => %{"token" => "Email change link is invalid or it has expired"}})
    end
  end
end
