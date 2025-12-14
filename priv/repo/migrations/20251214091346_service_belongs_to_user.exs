defmodule Hivex.Repo.Migrations.ServiceBelongsToUser do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
  end
end
