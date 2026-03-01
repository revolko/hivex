defmodule HivexWeb.UserSessionControllerTest do
  use HivexWeb.ConnCase, async: true

  import Hivex.AccountsFixtures
  alias Hivex.Accounts

  setup do
    %{unconfirmed_user: unconfirmed_user_fixture(), user: user_fixture()}
  end

  describe "POST /users/log-in - email and password" do
    test "logs the user in", %{conn: conn, user: user} do
      user = set_password(user)

      conn =
        post(conn, ~p"/api/v1/users/log-in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      actual_response = json_response(conn, :created)
      assert actual_response["token"]
    end

    test "emits error message with invalid credentials", %{conn: conn, user: user} do
      expected_errors = %{
        "login" => ["Invalid email or password"]
      }

      conn =
        post(conn, ~p"/api/v1/users/log-in", %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      actual_response = json_response(conn, :unauthorized)
      assert actual_response["errors"]
      assert actual_response["errors"] === expected_errors
    end
  end

  describe "POST /users/log-in - magic link" do
    test "sends magic link email when user exists", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/v1/users/log-in", %{
          "user" => %{"email" => user.email}
        })

      assert Hivex.Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "login"
      actual_response = json_response(conn, :created)
      assert actual_response === %{}
    end

    test "logs the user in", %{conn: conn, user: user} do
      {token, _hashed_token} = generate_user_magic_link_token(user)

      conn =
        post(conn, ~p"/api/v1/users/log-in", %{"token" => token})

      actual_response = json_response(conn, :created)
      assert actual_response["token"]
    end

    test "confirms unconfirmed user", %{conn: conn, unconfirmed_user: user} do
      {token, _hashed_token} = generate_user_magic_link_token(user)
      refute user.confirmed_at

      conn =
        post(conn, ~p"/api/v1/users/log-in", %{"token" => token})

      assert Accounts.get_user!(user.id).confirmed_at
      actual_response = json_response(conn, :created)
      assert actual_response["token"]
    end

    test "emits error message when magic link is invalid", %{conn: conn} do
      expected_errors = %{
        "login" => ["The link is invalid or it has expired"]
      }

      conn =
        post(conn, ~p"/api/v1/users/log-in", %{"token" => "invalid"})

      actual_response = json_response(conn, :unauthorized)
      assert actual_response["errors"]
      assert actual_response["errors"] === expected_errors
    end
  end

  describe "DELETE /users/log-out" do
  end
end
