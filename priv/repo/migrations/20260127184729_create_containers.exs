defmodule Hivex.Repo.Migrations.CreateContainers do
  use Ecto.Migration

  def change do
    create table(:containers) do
      add :name, :string
      add :image_name, :string
      add :host_port, :string
      add :container_port, :string
      add :proxy_port, :string

      timestamps(type: :utc_datetime)
    end
  end
end
