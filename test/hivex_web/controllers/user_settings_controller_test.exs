defmodule HivexWeb.UserSettingsControllerTest do
  use HivexWeb.ConnCase, async: true

  alias Hivex.Accounts
  import Hivex.AccountsFixtures

  setup :register_and_log_in_user

  describe "PUT /users/settings (change password form)" do
    test "updates the user password and resets tokens", %{conn: conn, user: user} do
      new_password_conn =
        put(conn, ~p"/api/v1/users/settings", %{
          "action" => "update_password",
          "user" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert response(new_password_conn, :no_content)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      expected_errors = %{
        "password" => ["should be at least 12 character(s)"],
        "password_confirmation" => ["does not match password"]
      }

      old_password_conn =
        put(conn, ~p"/api/v1/users/settings", %{
          "action" => "update_password",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      actual_response = json_response(old_password_conn, :bad_request)
      assert actual_response["errors"]
      assert actual_response["errors"] === expected_errors
    end
  end

  describe "PUT /users/settings (change email form)" do
    test "updates the user email", %{conn: conn, user: user} do
      conn =
        put(conn, ~p"/api/v1/users/settings", %{
          "action" => "update_email",
          "user" => %{"email" => unique_user_email()}
        })

      assert response(conn, :no_content)
      assert Accounts.get_user_by_email(user.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      expected_errors = %{"email" => ["must have the @ sign and no spaces"]}

      conn =
        put(conn, ~p"/api/v1/users/settings", %{
          "action" => "update_email",
          "user" => %{"email" => "with spaces"}
        })

      actual_response = json_response(conn, :bad_request)
      assert actual_response["errors"]
      assert actual_response["errors"] === expected_errors
    end
  end

  describe "GET /users/settings/confirm-email/:token" do
    setup %{user: user} do
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      first_conn = get(conn, ~p"/api/v1/users/settings/confirm-email/#{token}")
      assert response(first_conn, :ok)

      refute Accounts.get_user_by_email(user.email)
      assert Accounts.get_user_by_email(email)

      conn = get(conn, ~p"/api/v1/users/settings/confirm-email/#{token}")

      actual_response = json_response(conn, :bad_request)
      assert actual_response["errors"]

      assert actual_response["errors"] === %{
               "token" => "Email change link is invalid or it has expired"
             }
    end

    test "does not update email with invalid token", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/users/settings/confirm-email/oops")

      actual_response = json_response(conn, :bad_request)
      assert actual_response["errors"]

      assert actual_response["errors"] === %{
               "token" => "Email change link is invalid or it has expired"
             }
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, ~p"/api/v1/users/settings/confirm-email/#{token}")
      assert response(conn, :unauthorized)
    end
  end
end
