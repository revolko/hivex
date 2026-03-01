defmodule Hivex.Repo.Migrations.ContainerBelongsToUser do
  use Ecto.Migration

  def change do
    alter table(:containers) do
      add :user_id, references(:users, on_delete: :nothing), null: false
    end
  end
end
