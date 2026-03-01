defmodule HivexWeb.UserRegistrationControllerTest do
  use HivexWeb.ConnCase, async: true

  import Hivex.AccountsFixtures

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account but does not log in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, ~p"/api/v1/users/register", %{
          "user" => valid_user_attributes(email: email)
        })

      actual_response = json_response(conn, :created)
      assert actual_response["user"]
      assert actual_response["user"]["email"]
      assert actual_response["user"]["email"] === email
    end

    test "render errors for invalid data", %{conn: conn} do
      expected_errors = %{
        "email" => ["must have the @ sign and no spaces"]
      }

      conn =
        post(conn, ~p"/api/v1/users/register", %{
          "user" => %{"email" => "with spaces"}
        })

      actual_response = json_response(conn, :bad_request)
      assert actual_response["errors"]
      assert actual_response["errors"] === expected_errors
    end
  end
end
