defmodule Hivex.WorkersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hivex.Workers` context.
  """

  @doc """
  Generate a worker.
  """
  def worker_fixture(scope, access_key, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        access_key_hash: "some access_key_hash",
        name: "some name"
      })

    {:ok, worker} = Hivex.Workers.create_worker(scope, attrs, access_key)
    worker
  end
end
