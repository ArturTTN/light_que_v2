defmodule LightQuev2.Repo.Migrations.CreateJobTable do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :task, :text, null: false
      add :status, :integer, default: 0
      add :priority, :utc_datetime, null: false
    end

    create index(:jobs, [:priority])
  end
end
