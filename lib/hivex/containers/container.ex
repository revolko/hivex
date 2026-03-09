defmodule Hivex.Containers.Container do
  use Ecto.Schema
  import Ecto.Changeset

  schema "containers" do
    field :name, :string
    field :image_name, :string
    field :host_port, :string
    field :container_port, :string
    field :proxy_port, :string

    belongs_to :user, Hivex.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(container, attrs, user) do
    container
    |> cast(attrs, [:name, :image_name, :host_port, :container_port, :proxy_port])
    |> validate_required([:name, :image_name, :host_port, :container_port, :proxy_port])
    |> unique_constraint(:name)
    |> unique_constraint(:host_port)
    |> unique_constraint(:proxy_port)
    |> put_change(:user_id, user.id)
    |> assoc_constraint(:user)
  end
end
