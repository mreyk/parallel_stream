defmodule ParallelStream.FilterTest do
  use ExUnit.Case, async: true

  setup do
    # :observer.start

    :ok
  end

  test ".filter filters a stream of variable length" do
    result = 1..5
              |> ParallelStream.filter(fn i -> i |> rem(2) == 0 end)
              |> Enum.into([])

    assert result == [2, 4]
  end

  test ".filter filters a stream of zero length" do
    result = []
              |> ParallelStream.filter(fn i -> i |> rem(2) == 0 end)
              |> Enum.into([])

    assert result == []
  end

  test ".filter does propagate errors via links" do
    trap = Process.flag(:trap_exit, true)
    pid = spawn_link fn ->
      [1,2]
        |> ParallelStream.filter(fn i -> 
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

  test ".filter parallelizes the filter function" do
    { microseconds, :ok } = :timer.tc fn ->
      1..5
      |> ParallelStream.filter(fn _ -> :timer.sleep(10) end)
      |> Stream.run
    end

    assert microseconds < 50000
  end

  test ".filter parallelizes the filter function with the number of parallel streams defined" do
    { microseconds, :ok } = :timer.tc fn ->
      1..12
      |> ParallelStream.filter(fn _ -> :timer.sleep(10) end, num_pipes: 12)
      |> Stream.run
    end

    assert microseconds < 120000
  end

end