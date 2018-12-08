defmodule LightQuev2.Persistence do
  import Ecto.Query

  alias LightQuev2.Persistence.Schema, as: Job
  alias LightQuev2.Repo

  defdelegate changeset(struct, term), to: Job

  def add(task) do
    %Job{}
    |> changeset(%{task: task, priority: NaiveDateTime.utc_now()})
    |> Repo.insert()
  end

  def update(nil, _), do: nil

  def update(%Job{} = job, data) do
    job
    |> changeset(data)
    |> Repo.update()
  end

  def update(task_id, data) do
    get(task_id)
    |> LightQuev2.Persistence.update(data)
  end

  def get(task_id) do
    Repo.get_by(Job, id: task_id)
  end

  def get_task_list do
    from(job in Job,
      where: job.status in ["reject", "new"],
      order_by: [asc: job.priority]
    )
    |> Repo.all()
  end
end
