defmodule Puzzle do
  def sum(string, delta \\ 1)

  def sum("", _), do: 0
  def sum(<<_ :: utf8 >>, _), do: 0
  def sum(string, 0), do: string

  def sum(string, delta) do
    shifted = rotate(string, delta)

    sum_(string, shifted)
  end

  def sum_mid(string) do
    delta = div byte_size(string), 2
    sum(string, delta)
  end

  defp sum_("", ""), do: 0
  defp sum_(string, shifted) do
    { a, rest_string } = String.next_grapheme(string)
    { b, rest_shifted } = String.next_grapheme(shifted)

    inc = if a == b, do: String.to_integer(a), else: 0
    inc + sum_(rest_string, rest_shifted)
  end

  defp rotate("", _), do: ""
  defp rotate(string, 0), do: string

  defp rotate(<<head :: utf8>>, _), do: <<head :: utf8>>

  defp rotate(<<head :: utf8, rest :: binary >>, shift) do
    rotate(<< rest :: binary, head >>, shift - 1)
  end
end

mode = List.first(System.argv)

if mode == "test" do
  ExUnit.start()

  defmodule PuzzleTest do
    use ExUnit.Case

    describe "sum(string)" do
      test "empty string" do
        sum = Puzzle.sum("")
        assert sum == 0
      end

      test "22" do
        sum = Puzzle.sum("22")
        assert sum == 4
      end

      test "23" do
        sum = Puzzle.sum("23")
        assert sum == 0
      end

      test "1122" do
        sum = Puzzle.sum("1122")
        assert sum == 3
      end

      test "1111" do
        sum = Puzzle.sum("1111")
        assert sum == 4
      end

      test "1234" do
        sum = Puzzle.sum("1234")
        assert sum == 0
      end

      test "91212129" do
        sum = Puzzle.sum("91212129")
        assert sum == 9
      end
    end

    describe "sum_mid(string)" do
      test "empty string" do
        sum = Puzzle.sum_mid("")
        assert sum == 0
      end

      test "22" do
        sum = Puzzle.sum_mid("22")
        assert sum == 4
      end

      test "23" do
        sum = Puzzle.sum_mid("23")
        assert sum == 0
      end

      test "1122" do
        sum = Puzzle.sum_mid("1122")
        assert sum == 0
      end

      test "1212" do
        sum = Puzzle.sum_mid("1212")
        assert sum == 6
      end

      test "1221" do
        sum = Puzzle.sum_mid("1221")
        assert sum == 0
      end

      test "123425" do
        sum = Puzzle.sum_mid("123425")
        assert sum == 4
      end

      test "123123" do
        sum = Puzzle.sum_mid("123123")
        assert sum == 12
      end

      test "12131415" do
        sum = Puzzle.sum_mid("12131415")
        assert sum == 4
      end
    end
  end
else
  data = File.read!("01.txt") |> String.trim_trailing
  sum = Puzzle.sum(data)
  sum_mid = Puzzle.sum_mid(data)
  IO.puts "The sum is: #{sum}"
  IO.puts "The sum mid is: #{sum_mid}"
end
