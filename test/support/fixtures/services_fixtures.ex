defmodule Hivex.ServicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hivex.Services` context.
  """

  @doc """
  Generate a service.
  """
  def service_fixture(attrs \\ %{}) do
    {:ok, service} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Hivex.Services.create_service()

    service
  end
end
