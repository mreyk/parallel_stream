defmodule ParallelStream.MapperTest do
  use ExUnit.Case, async: true

  setup do
    # :observer.start

    :ok
  end

  test ".map maps a stream of variable length" do
    result = 1..5
              |> ParallelStream.map(&Integer.to_string/1)
              |> Enum.into([])

    assert result == ~w(1 2 3 4 5)
  end

  test ".map maps a stream of zero length" do
    result = []
              |> ParallelStream.map(&Integer.to_string/1)
              |> Enum.into([])

    assert result == []
  end

  test ".map does propagate errors via links" do
    trap = Process.flag(:trap_exit, true)
    pid = spawn_link fn ->
      [1,2]
        |> ParallelStream.map(fn i -> 
          if i |> rem(2) == 0 do
            raise RuntimeError
          end
        end)
        |> Enum.into([])
    end

    assert_receive { :EXIT, ^pid, { %RuntimeError{}, _ } }

    Process.exit(pid, :kill)
    refute Process.alive?(pid)

    Process.flag(:trap_exit, trap)
  end

  test ".map parallelizes the mapping function" do
    { microseconds, :ok } = :timer.tc fn ->
      1..5
      |> ParallelStream.map(fn _ -> :timer.sleep(10) end)
      |> Stream.run
    end

    assert microseconds < 50000
  end

  test ".map parallelizes the mapping function with the number of parallel streams defined" do
    { microseconds, :ok } = :timer.tc fn ->
      1..12
      |> ParallelStream.map(fn _ -> :timer.sleep(10) end, num_pipes: 12)
      |> Stream.run
    end

    assert microseconds < 120000
  end

end