defmodule LightQuev2Test do
  use ExUnit.Case
  doctest LightQuev2

  alias LightQuev2.{Repo, Persistence}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    {:ok, pid} = LightQuev2.start_link()
    {:ok, [pid: pid]}
  end

  describe "add/1" do

      test "Que add should return the tuple {:ok, enqueued}" do
        new_job = "job free text"
        assert LightQuev2.add(new_job) == {:ok, :enqueued}
      end
  end

  describe "get/1" do

    test "Que add/get should be first in / first out" do

      LightQuev2.add("task1")
      LightQuev2.add("task2")

      task1 = LightQuev2.get()
      task2 = LightQuev2.get()

      assert "task1" == task1.task
      assert "task2" == task2.task
    end
  end

  describe "reject/1" do

    test "Que reject should push in the end of queue" do

      LightQuev2.add("task1")
      LightQuev2.add("task2")
      task1 = LightQuev2.get()

      LightQuev2.reject(task1.id)

      task2 = LightQuev2.get()
      task1 = LightQuev2.get()

      assert "task1" == task1.task
      assert "task2" == task2.task
    end

    test "Que reject should change status in persitence" do


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

    test "Que ack should remove from persitence job" do

      LightQuev2.add("task1")
      task1 = LightQuev2.get()

      LightQuev2.ack(task1.id)

      assert Persistence.get_task_list() == []
    end
  end
end
