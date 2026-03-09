defmodule Hivex.Repo.Migrations.AddConstraintsContainers do
  use Ecto.Migration

  def change do
    create unique_index(:containers, [:name])
    create unique_index(:containers, [:host_port])
    create unique_index(:containers, [:proxy_port])
  end
end
