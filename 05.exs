defmodule Puzzle do
  def count_steps(data, mode \\ :default) do
    instructions =
      data
        |> String.split
        |> Enum.map(&String.to_integer/1)

    cache = build_cache(instructions)

    all_steps(cache, 0, 0, mode)
  end

  defp build_cache(instructions) do
    idxs = 0..(length(instructions) - 1)

    idxs |> Enum.zip(instructions) |> Map.new
  end

  defp all_steps(cache, position, steps, mode) do
    {move, updated_cache} =
      Map.get_and_update(cache, position, fn mv ->
        if mode == :weird && mv >= 3 do
          {mv, mv - 1}
        else
          {mv, mv + 1}
        end
      end)

    next_position = position + move

    if rem(steps, 100_000) == 0, do: IO.puts "Steps: #{steps}"

    if next_position < 0 || next_position >= map_size(cache) do
      steps + 1
    else
      all_steps(updated_cache, next_position, steps + 1, mode)
    end
  end
end

mode = List.first(System.argv)

if mode == "test" do
  ExUnit.start()

  defmodule PuzzleTest do
    use ExUnit.Case

    describe "count_steps(data, :default)" do
      setup [:with_default_mode]

      test "when data = [0 3 0 1 -3]", context do
        data = "0\n3\n0\n1\n-3"
        steps = Puzzle.count_steps(data, context[:mode])
        assert steps == 5
      end
    end

    describe "count_steps(data, :weird)" do
      setup [:with_weird_mode]

      test "when data = [0 3 0 1 -3]", context do
        data = "0\n3\n0\n1\n-3"
        steps = Puzzle.count_steps(data, context[:mode])
        assert steps == 10
      end
    end

    defp with_default_mode(_context) do
      [mode: :default]
    end

    defp with_weird_mode(_context) do
      [mode: :weird]
    end
  end
else
  data = "05.txt" |> File.read! |> String.trim_trailing

  {time1, steps} = :timer.tc(fn -> Puzzle.count_steps(data) end)
  time1_seconds = time1 / 1_000_000

  IO.puts "The number of steps: #{steps} (in #{time1_seconds}s)"

  {time2, steps_weird} = :timer.tc(fn -> Puzzle.count_steps(data, :weird) end)
  time2_seconds = time2 / 1_000_000

  IO.puts "The number of steps (weird): #{steps_weird} (in #{time2_seconds}s)"
end
