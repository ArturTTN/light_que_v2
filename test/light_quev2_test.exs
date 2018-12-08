defmodule LightQuev2Test do
  use ExUnit.Case
  doctest LightQuev2

  test "Que add should return the tuple {:ok, enqueued}" do
    new_job = "job free text"
    {:ok, _pid} = LightQuev2.start_link()
    assert LightQuev2.add(new_job) == {:ok, :enqueued}
  end
end
