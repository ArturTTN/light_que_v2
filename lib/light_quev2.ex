defmodule LightQuev2 do
  @moduledoc """
  Que V2 is a queue implemented as a GenServer.
  It does not have fixed maximum length.
  Producers and consumers may work separatly and async.
  Que state Persists in databases.

  ## Examples
      LightQuev2.add("task") #should return {:ok, enqueued}
      LightQuev2.get(pid) # should return %LightQuev2.Persistence{}
      LightQuev2.reject(id) # should put in the end of queue and return tuple {:ok, enqueued}
      LightQuev2.ack(id) # should delete from persistance and return tuple {:ok, :taks_removed}
  """
  use GenServer

  alias LightQuev2.Persistence

  # que to save jobs in state of GenServer
  @empty_que :queue.new

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, @empty_que, name: __MODULE__)

  # persists tasks to state during initialize
  def init(state) do

    state = Persistence.get_task_list()
    |> Enum.reduce(state, fn persistence, acc ->
        :queue.in(persistence, acc)
      end)
    {:ok, state}
  end

  # prepend new job to que
  # this is async call
  def handle_cast({:push, persistence}, queue) do
    {:noreply, :queue.in(persistence, queue)}
  end

  # prepend new job to que at the same time persists job to storage
  # this is sync call
  def handle_call({:push, job}, _, queue) do

    with {:ok, persistence} <- Persistence.add(job),
          new_queue         <- :queue.in(persistence, queue) do
      {:reply, {:ok, :enqueued}, new_queue}
    else
      error ->
      {:reply, humanazie_error(error), queue}
    end
  end

  # get the FIFO job from queue
  def handle_call(:pop, _, queue) do

    case :queue.out(queue) do
      {{:value, task}, new_queue} -> {:reply, task, new_queue}
      {:empty, new_queue}         -> {:reply, {:ok, :queue_empty}, new_queue}
    end
  end


  #
  # Adds a new job into the queue.
  # `job` is the value to be pushed into the queue
  # Before pushing to queue, we have to persists record to storage
  # It has to be a string.
  #
  @spec add(charlist) :: any
  def add(), do: {:error, :job_is_empty}
  def add(job) do
    GenServer.call(__MODULE__, {:push, job})
  end

  # Get the last added task from the queue.
  def get() do
    GenServer.call(__MODULE__, :pop)
  end


  # Reject task will put job in the end of queue.
  def reject(task_id) do

    case Persistence.update(task_id, %{status: :reject, priority: NaiveDateTime.utc_now()}) do
      {:ok, persistence}  -> GenServer.cast(__MODULE__, {:push, persistence})
      error               -> humanazie_error(error)
    end
  end


  # Ack mark job as done
  def ack(task_id) do
    Persistence.update(task_id, %{
      status: :ack,
      priority: NaiveDateTime.utc_now()}
    )
  end

  defp humanazie_error(nil), do: {:error, :task_not_found}

  defp humanazie_error({:error, %Ecto.Changeset{} = changeset}) do

    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
