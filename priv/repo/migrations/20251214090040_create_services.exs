defmodule Hivex.Repo.Migrations.CreateServices do
  use Ecto.Migration

  def change do
    create table(:services) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
