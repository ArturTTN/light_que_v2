defmodule LightQuev2.Persistence.Schema do
  use Ecto.Schema

  import EctoEnum

  defenum(StatusEnum, new: 0, pending: 1, ack: 2, reject: 3)

  schema "jobs" do
    field(:status, StatusEnum, default: 0)
    field(:priority, :naive_datetime)
    field(:task, :string)
  end

  def changeset(task, params \\ %{}) do
    task
    |> Ecto.Changeset.cast(params, [:status, :priority, :task])
    |> Ecto.Changeset.validate_required([:status, :priority, :task])
  end
end
