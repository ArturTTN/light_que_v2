defmodule LightQuev2Test do
  use ExUnit.Case
  doctest LightQuev2

  test "Que add should return the tuple {:ok, enqueued}" do
    new_job = "job free text"
    {:ok, _pid} = LightQuev2.start_link()
    assert LightQuev2.add(new_job) == {:ok, :enqueued}
  end

  test "Que add/get should be first in / first out" do
    {:ok, _pid} = LightQuev2.start_link()
    LightQuev2.add("task1")
    LightQuev2.add("task2")
    task1 = LightQuev2.get()
    task2 = LightQuev2.get()
    assert "task1" == task1[:task]
    assert "task2" == task1[:task]
  end
end
