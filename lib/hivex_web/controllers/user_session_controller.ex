defmodule HivexWeb.UserSessionController do
  use HivexWeb, :controller

  alias Hivex.{Accounts, Accounts.Guardian}

  # magic link login
  def create(conn, %{"token" => token}) do
    with {:ok, {user, _expired_tokens}} <- Accounts.login_user_by_magic_link(token),
         {:ok, token, _full_claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> json(%{"token" => token})
    else
      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{"errors" => %{"login" => ["The link is invalid or it has expired"]}})
    end
  end

  # email + password login
  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    user = Accounts.get_user_by_email_and_password(email, password)

    if user do
      # TODO: handle?
      {:ok, token, _full_claims} = Guardian.encode_and_sign(user)

      conn
      |> put_status(:created)
      |> json(%{"token" => token})
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_status(:unauthorized)
      |> json(%{"errors" => %{"login" => ["Invalid email or password"]}})
    end
  end

  # magic link request
  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/api/v1/users/log-in/#{&1}")
      )
    end

    conn
    |> put_status(:created)
    |> json(%{})
  end

  def delete(conn, _params) do
    # does not do anything at this point
    # needs a callback definition to actually revoke the token
    # see: https://github.com/ueberauth/guardian_db
    # I am not going to implement it just yet (don't see the value)
    with token <- Guardian.Plug.current_token(conn),
         {:ok, _claims} <- Guardian.revoke(token) do
      conn
      |> put_status(:no_content)
      |> json(%{})
    else
      _ ->
        conn
        |> put_status(:internal_error)
        |> json(%{"errors" => ["Cannot log out user"]})
    end
  end
end
