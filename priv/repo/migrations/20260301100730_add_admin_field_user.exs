defmodule Hivex.Repo.Migrations.AddAdminFieldUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :super, :boolean, default: false, null: false
    end
  end
end
