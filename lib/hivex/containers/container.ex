defmodule Hivex.Containers.Container do
  use Ecto.Schema
  import Ecto.Changeset

  schema "containers" do
    field :name, :string
    field :image_name, :string
    field :host_port, :string
    field :container_port, :string
    field :proxy_port, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(container, attrs) do
    container
    |> cast(attrs, [:name, :image_name, :host_port, :container_port, :proxy_port])
    |> validate_required([:name, :image_name, :host_port, :container_port, :proxy_port])
  end
end
