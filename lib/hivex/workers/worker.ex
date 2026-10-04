defmodule Hivex.Workers.Worker do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workers" do
    field :name, :string
    field :access_key_hash, :binary
    field :owner_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(worker, attrs, user_scope, access_key_hash) do
    worker
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_change(:user_id, user_scope.user.id)
    |> put_change(:access_key_hash, access_key_hash)
  end

  @doc false
  def changeset(worker, attrs, user_scope) do
    worker
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_change(:user_id, user_scope.user.id)
  end
end
