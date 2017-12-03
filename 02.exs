defmodule Puzzle do
  def checksum(""), do: 0

  def checksum(spreadsheet) do
    spreadsheet
      |> String.split("\n", trim: true)
      |> Enum.map(&minmax/1)
      |> Enum.map(
           fn { nil, nil } -> 0
              { min, max } -> max - min
           end
         )
      |> Enum.sum
  end

  def checksum_div(""), do: 0

  def checksum_div(spreadsheet) do
    spreadsheet
      |> String.split("\n", trim: true)
      |> Enum.map(&divides/1)
      |> Enum.map(
           fn [{ nil, nil }] -> 0
              [{ divided, divider }] -> div(divided, divider)
           end
         )
      |> Enum.sum
  end

  defp minmax(""), do: { nil, nil }
  defp minmax(row) do
    row
      |> String.split
      |> Enum.map(&String.to_integer/1)
      |> Enum.reduce(
           { nil, nil },
           fn(digit, acc) ->
             cond do
               is_nil(elem(acc, 0)) ->
                 { digit, digit }
               digit < elem(acc, 0) ->
                 put_elem(acc, 0, digit)
               digit > elem(acc, 1) ->
                 put_elem(acc, 1, digit)
               true ->
                 acc
             end
           end
         )
  end

  defp divides(""), do: { nil, nil }
  defp divides(row) do
    ints = row |> String.split |> Enum.map(&String.to_integer/1)
    for a <- ints,
        b <- ints,
        a > b,
        rem(a, b) == 0,
        do: { a, b }
  end
end

mode = List.first(System.argv)

if mode == "test" do
  ExUnit.start()

  defmodule PuzzleTest do
    use ExUnit.Case

    describe "checksum(spreadsheet)" do
      test "for 3 lines" do
        spreadsheet = """
        5 1 9 5
        7 5 3
        2 4 6 8
        """

        checksum = Puzzle.checksum(spreadsheet)
        assert checksum == 18
      end

      test "for 2 lines with eq values" do
        spreadsheet = """
        5 5
        5 5
        """

        checksum = Puzzle.checksum(spreadsheet)
        assert checksum == 0
      end
    end

    describe "checksum_div(spreadsheet)" do
      test "for 3 lines" do
        spreadsheet = """
        5 9 2 8
        9 4 7 3
        3 8 6 5
        """

        checksum = Puzzle.checksum_div(spreadsheet)
        assert checksum == 9
      end
    end
  end
else
  data = File.read!("02.txt") |> String.trim_trailing
  checksum = Puzzle.checksum(data)
  checksum_div = Puzzle.checksum_div(data)
  IO.puts "The checksum is: #{checksum}"
  IO.puts "The checksum div is: #{checksum_div}"
end
