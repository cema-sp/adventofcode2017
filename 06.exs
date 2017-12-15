defmodule Puzzle do
  def cycles_to_loop(""), do: 0
  def cycles_to_loop(data) do
    initial_banks = init_banks(data)
    cycles_to_loop_(initial_banks)
  end

  def loop_size(""), do: 0
  def loop_size(data) do
    initial_banks = init_banks(data)
    loop_size_(initial_banks)
  end

  def reallocate(banks) do
    {blocks, idx, banks} = pop_max(banks)

    distribute(banks, blocks, idx + 1)
  end

  defp init_banks(data) do
    data
      |> String.split(~r{\s}, trim: true)
      |> Enum.map(&String.to_integer/1)
  end

  defp cycles_to_loop_(banks, cache \\ MapSet.new) do
    if MapSet.member?(cache, banks) do
      0
    else
      updated_banks = reallocate(banks)
      updated_cache = MapSet.put(cache, banks)

      1 + cycles_to_loop_(updated_banks, updated_cache)
    end
  end

  defp loop_size_(banks, step \\ 0, cache \\ Map.new) do
    join_step = Map.get(cache, banks)

    if join_step do
      step - join_step
    else
      updated_banks = reallocate(banks)
      updated_cache = Map.put(cache, banks, step)

      loop_size_(updated_banks, step + 1, updated_cache)
    end
  end

  @spec pop_max(List.t) :: {number, number, List.t}
  defp pop_max(banks) do
    {blocks, idx} =
      banks
        |> Enum.with_index
        |> Enum.max_by(fn {b, _} -> b end)

    updated_banks = List.replace_at(banks, idx, 0)

    {blocks, idx, updated_banks}
  end

  @spec distribute(List.t, number, number) :: List.t
  defp distribute(banks, 0, _), do: banks
  defp distribute(banks, blocks, cursor) do
    cursor = if cursor >= length(banks), do: 0, else: cursor

    updated_banks = List.update_at(banks, cursor, &(&1 + 1))

    distribute(updated_banks, blocks - 1, cursor + 1)
  end
end

mode = List.first(System.argv)

if mode == "test" do
  ExUnit.start()

  defmodule PuzzleTest do
    use ExUnit.Case

    describe "cycles_to_loop(data)" do
      test "returns 5" do
        data = "0 2 7 0"
        cycles = Puzzle.cycles_to_loop(data)
        assert cycles == 5
      end
    end

    describe "loop_size(data)" do
      test "returns 4" do
        data = "0 2 7 0"
        cycles = Puzzle.loop_size(data)
        assert cycles == 4
      end
    end

    describe "reallocate(banks)" do
      test "works" do
        banks = [0, 2, 7, 0]
        next_banks = Puzzle.reallocate(banks)
        assert next_banks == [2, 4, 1, 2]
      end
    end
  end
else
  data = "06.txt" |> File.read! |> String.trim_trailing
  cycles = Puzzle.cycles_to_loop(data)
  IO.puts "The number of cycles: #{cycles}"

  loop = Puzzle.loop_size(data)
  IO.puts "The size of the loop: #{loop}"
end
