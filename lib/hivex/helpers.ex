defmodule Hivex.Helpers do
  @moduledoc """
   Module for helper functions used throughout the Hivex.
  """

  @doc """
  Format changeset errors to JSON serializable list.
  """
  def format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
