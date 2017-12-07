defmodule Puzzle do
  defmodule Spiral do
    defstruct [:base, :level, :range]

    def distance(spiral, square) do
      side_centers = Enum.map(0..3, fn x ->
        spiral.range.last -
          div(spiral.base, 2) -
            (spiral.base - 1) * x
      end)

      min_center_dist =
        side_centers
          |> Enum.map(fn x -> abs(x - square) end)
          |> Enum.min

      min_center_dist
    end
  end

  require Integer

  def stress_test_value(0), do: 1
  def stress_test_value(n) do
    prev_value = stress_test_value(n - 1)
    diagonal_value = 0

    prev_value + diagonal_value
  end

  def adjacent(memory, n) do
    []
  end

  def coords(memory, 1), do: {0, 0}
  def coords(memory, n) do
    {0, 0}
  end

  def distance(1), do: 0
  def distance(square) do
    spiral = square |> spiral_base |> build_spiral

    spiral.level + Spiral.distance(spiral, square)
  end

  def build_spiral(1), do: %Spiral{level: 0, base: 1, range: 1..1}
  def build_spiral(base) do
    level = div((base - 1), 2)
    prev_base = base - 2
    range = (prev_base * prev_base + 1)..(base * base)
    %Spiral{level: level, base: base, range: range}
  end

  def spiral_base(square) do
    square
    |> :math.sqrt
    |> Float.ceil
    |> round_to_odd
  end

  defp round_to_odd(n) do
    int_n = round(n)

    if Integer.is_odd(int_n) do
      int_n
    else
      int_n + 1
    end
  end
end

mode = List.first(System.argv)

if mode == "test" do
  ExUnit.start()

  defmodule PuzzleTest do
    use ExUnit.Case

    describe "distance(square)" do
      test "square = 1" do
        dist = Puzzle.distance(1)
        assert dist == 0
      end

      test "square = 12" do
        dist = Puzzle.distance(12)
        assert dist == 3
      end

      test "square = 23" do
        dist = Puzzle.distance(23)
        assert dist == 2
      end

      test "square = 1024" do
        dist = Puzzle.distance(1024)
        assert dist == 31
      end
    end

    describe "spiral_base(square)" do
      test "square = 1" do
        n = Puzzle.spiral_base(1)
        assert n == 1
      end

      test "square = 2" do
        n = Puzzle.spiral_base(2)
        assert n == 3
      end

      test "square = 9" do
        n = Puzzle.spiral_base(9)
        assert n == 3
      end

      test "square = 27" do
        n = Puzzle.spiral_base(27)
        assert n == 7
      end
    end

    describe "build_spiral(base)" do
      test "base = 1" do
        spiral = Puzzle.build_spiral(1)
        assert(
          spiral == %Puzzle.Spiral{level: 0, base: 1, range: 1..1}
        )
      end

      test "base = 5" do
        spiral = Puzzle.build_spiral(5)
        assert(
          spiral == %Puzzle.Spiral{level: 2, base: 5, range: 10..25}
        )
      end

      test "base = 11" do
        spiral = Puzzle.build_spiral(11)
        assert(
          spiral == %Puzzle.Spiral{level: 5, base: 11, range: 82..121}
        )
      end
    end

    describe "stress_test_value(n)" do
      test "when n == 1" do
        value = Puzzle.stress_test_value(1)
        assert value == 1
      end

      test "when n == 2" do
        value = Puzzle.stress_test_value(2)
        assert value == 1
      end

      test "when n == 6" do
        value = Puzzle.stress_test_value(6)
        assert value == 10
      end

      test "when n == 13" do
        value = Puzzle.stress_test_value(13)
        assert value == 59
      end

      test "when n == 14" do
        value = Puzzle.stress_test_value(14)
        assert value == 122
      end

      test "when n == 15" do
        value = Puzzle.stress_test_value(15)
        assert value == 133
      end
    end

    # describe "adjacent(memory, n)" do
    #   setup [:build_3x3_memory]
    #
    #   test "when n = 1", context do
    #     adjacent = Puzzle.adjacent(context[:memory], 1)
    #
    #     diff = List.myers_difference(
    #       adjacent,
    #       [5, 4, 2, 10, 1, 11, 23, 25]
    #     )
    #
    #     refute diff[:del]
    #     refute diff[:ins]
    #   end
    #
    #   test "when n = 3", context do
    #     adjacent = Puzzle.adjacent(context[:memory], 3)
    #
    #     diff = List.myers_difference(
    #       adjacent,
    #       [1, 1, 4]
    #     )
    #
    #     refute diff[:del]
    #     refute diff[:ins]
    #   end
    #
    #   test "when n = 6", context do
    #     adjacent = Puzzle.adjacent(context[:memory], 6)
    #
    #     diff = List.myers_difference(
    #       adjacent,
    #       [5, 11, 4, 1, 23]
    #     )
    #
    #     refute diff[:del]
    #     refute diff[:ins]
    #   end
    # end
    #
    # describe "coords(memory, n)" do
    #   test "when n = 1", context do
    #     coords = Puzzle.coords(context[:memory], 1)
    #     assert coords == {0, 0}
    #   end
    #
    #   test "when n = 3", context do
    #     coords = Puzzle.coords(context[:memory], 3)
    #     assert coords == {1, -1}
    #   end
    #
    #   test "when n = 4", context do
    #     coords = Puzzle.coords(context[:memory], 4)
    #     assert coords == {0, -1}
    #   end
    #
    #   test "when n = 7", context do
    #     coords = Puzzle.coords(context[:memory], 7)
    #     assert coords == {-1, -1}
    #   end
    # end
    #
    # defp build_3x3_memory(context) do
    #   memory = [
    #     [5, 10, 11],
    #     [4, 1,  23],
    #     [2, 1,  25]
    #   ]
    #
    #   [memory: memory]
    # end
  end
else
  data = 361_527
  distance = Puzzle.distance(data)
  IO.inspect(distance, label: "The distance is:")
  # data = "03.txt" |> File.read! |> String.trim_trailing
  # checksum = Puzzle.checksum(data)
  # IO.puts "The checksum is: #{checksum}"
end
