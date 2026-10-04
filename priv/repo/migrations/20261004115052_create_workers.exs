defmodule Hivex.Repo.Migrations.CreateWorkers do
  use Ecto.Migration

  def change do
    create table(:workers) do
      add :name, :string
      add :access_key_hash, :binary
      add :owner_id, references(:users, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:workers, [:user_id])

    create index(:workers, [:owner_id])
  end
end
