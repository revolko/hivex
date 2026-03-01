defmodule Hivex.Accounts.Guardian do
  @moduledoc """
  Guardian implementation module for JWT.
  """
  use Guardian, otp_app: :hivex

  alias Hivex.Accounts

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = Accounts.get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
