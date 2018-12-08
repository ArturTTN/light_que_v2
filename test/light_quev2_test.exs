defmodule LightQuev2Test do
  use ExUnit.Case
  doctest LightQuev2

  alias LightQuev2.{Repo, Persistence}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    {:ok, pid} = LightQuev2.start_link()
    {:ok, [pid: pid]}
  end

  describe "add/1" do
    test "should return the tuple {:ok, enqueued}" do
      assert LightQuev2.add("task1") == {:ok, :enqueued}
    end

    test "should validate input param" do
      assert LightQuev2.add() == {:error, :job_is_empty}
    end

    test "humanize changeset errors" do
      assert LightQuev2.add(7) == %{task: ["is invalid"]}
    end
  end

  describe "get/1" do
    test "add/get should be first in / first out" do
      LightQuev2.add("task1")
      LightQuev2.add("task2")

      task1 = LightQuev2.get()
      task2 = LightQuev2.get()

      assert "task1" == task1.task
      assert "task2" == task2.task
    end

    test "check empty queue" do
      assert LightQuev2.get() == {:ok, :queue_empty}
    end
  end

  describe "reject/1" do
    test "should push in the end of queue" do
      LightQuev2.add("task1")
      LightQuev2.add("task2")
      task1 = LightQuev2.get()

      LightQuev2.reject(task1.id)

      task2 = LightQuev2.get()

      task1 = LightQuev2.get()

      assert "task1" == task1.task
      assert "task2" == task2.task
    end

    test "should change status in persitence" do
      LightQuev2.add("task1")
      task = LightQuev2.get()
      :ok = LightQuev2.reject(task.id)

      assert Persistence.get(task.id).status == :reject
    end

    test "Que reject invalid task id error" do
      assert LightQuev2.reject(0) == {:error, :task_not_found}
    end
  end

  describe "ack/1" do
    test "should remove from persitence job" do
      task_list = Persistence.get_task_list()

      LightQuev2.add("task1")
      task1 = LightQuev2.get()

      LightQuev2.ack(task1.id)

      assert Persistence.get_task_list() == task_list
    end

    test "should change status in persistence" do
      LightQuev2.add("task1")
      task = LightQuev2.get()
      LightQuev2.ack(task.id)

      assert Persistence.get(task.id).status == :ack
    end

    test "should remove job from que" do
      LightQuev2.add("task1")
      task = LightQuev2.get()
      LightQuev2.ack(task.id)

      assert LightQuev2.get() == {:ok, :queue_empty}
    end
  end

  describe "Que Genserver" do
    test "check async insert should be ordered in que FIFO" do
      range = 1..10

      expected_result =
        Enum.into(
          range
          |> Enum.map(&Integer.to_string/1),
          []
        )

      # sleep to be sure processes will start in right order, but async due to Task.async
      for item <- range do
        Task.async(fn ->
          LightQuev2.add("#{item}")
        end)

        :timer.sleep(1)
      end

      assert expected_result == Enum.into(range, [], fn _ -> LightQuev2.get().task end)
    end

    test "recover state after crash", %{pid: pid} do
      LightQuev2.add("task1")
      task = LightQuev2.get()
      LightQuev2.reject(task.id)

      GenServer.stop(pid)
      LightQuev2.start_link()

      after_restart_task = LightQuev2.get()

      assert after_restart_task.id == task.id
    end
  end
end
