defmodule Puzzle do
  use Bitwise

  def checksum2(data, sz \\ 256) do
    list = Enum.to_list(0..sz - 1)

    lengths =
      data
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

    hash = hash(list, lengths)

    hash
    |> Enum.take(2)
    |> Enum.reduce(1, &(&1 * &2))
  end

  @suffix [17, 31, 73, 47, 23]

  def knot_hash(data, sz \\ 256) do
    list = Enum.to_list(0..sz - 1)

    lengths =
      data
      |> String.split("", trim: true)
      |> Enum.map(fn <<ascii::utf8, _::binary>> -> ascii end)

    lengths = lengths ++ @suffix

    list
    |> hash64(lengths)
    |> dense()
    |> Enum.map(&(Integer.to_string(&1, 16)))
    |> Enum.map(&(String.pad_leading(&1, 2, "0")))
    |> Enum.join()
    |> String.downcase()
  end

  def hash(list, lengths) do
    params = %{size: length(list), position: 0, skip: 0}

    {result, _} = do_hash(list, lengths, params)
    result
  end

  defp hash64(list, lengths) do
    params = %{size: length(list), position: 0, skip: 0}

    {result, _} =
      Enum.reduce(1..64, {list, params}, fn (_, {lst, pars}) ->
        do_hash(lst, lengths, pars)
      end)

    result
  end

  def dense(list) do
    list
    |> Enum.chunk_every(16)
    |> Enum.map(&(Enum.reduce(&1, fn (v, acc) -> v ^^^ acc end)))
  end

  defp do_hash(list, [], params), do: {list, params}

  defp do_hash(list, [lngth | lengths], %{size: sz} = params)
    when lngth > sz, do: do_hash(list, lengths, params)

  defp do_hash(list, [lngth | lengths], params) do
    %{position: position, size: sz, skip: skip} = params

    list = reverse(list, position, lngth)

    params =
      params
      |> Map.update!(:position, &(rem(&1 + lngth + skip, sz)))
      |> Map.update!(:skip, &(&1 + 1))

    do_hash(list, lengths, params)
  end

  defp reverse(list, position, lngth) do
    do_reverse(list, length(list), position, lngth)
  end

  defp do_reverse([], _, _, _), do: []
  defp do_reverse(list, _, _, 0), do: list

  defp do_reverse(list, sz, position, lngth)
    when position + lngth <= sz,
    do: Enum.reverse_slice(list, position, lngth)

  defp do_reverse(list, sz, position, lngth) do
    prefix_length = position + lngth - sz

    reversed_part =
      list
      |> Stream.cycle
      |> Enum.slice(position, lngth)
      |> Enum.reverse

    {suffix, prefix} = Enum.split(reversed_part, prefix_length * -1)

    rest = Enum.slice(list, prefix_length..position - 1)
    prefix ++ rest ++ suffix
  end
end

mode = List.first(System.argv)

if mode == "test" do
  ExUnit.start()

  defmodule PuzzleTest do
    use ExUnit.Case

    describe "checksum2(data, 5) for example data" do
      setup [:with_example_data]

      test "returns expected", context do
        checksum = Puzzle.checksum2(context[:data], 5)
        assert checksum == 12
      end
    end

    describe "hash(list, lengths)" do
      test "returns expected" do
        hash = Puzzle.hash([0, 1, 2, 3, 4], [3, 4, 1, 5])
        assert hash == [3, 4, 2, 1, 0]
      end
    end

    describe "dense(list) with example list" do
      test "returns expected" do
        list = [65, 27, 9, 1, 4, 3, 40, 50, 91, 7, 6, 0, 2, 5, 68, 22]
        dense_hash = Puzzle.dense(list)
        assert dense_hash == [64]
      end
    end

    describe "knot_hash(data) with empty string" do
      test "returns expected" do
        hash = Puzzle.knot_hash("")
        assert hash == "a2582a3a0e66e6e86e3812dcb672a272"
      end
    end

    describe "knot_hash(data) with 'AoC 2017'" do
      test "returns expected" do
        hash = Puzzle.knot_hash("AoC 2017")
        assert hash == "33efeb34ea91902bb2f59c9920caa6cd"
      end
    end

    describe "knot_hash(data) with '1,2,3'" do
      test "returns expected" do
        hash = Puzzle.knot_hash("1,2,3")
        assert hash == "3efbe78a8d82f29979031a4aa0b16a9d"
      end
    end

    describe "knot_hash(data) with '1,2,4'" do
      test "returns expected" do
        hash = Puzzle.knot_hash("1,2,4")
        assert hash == "63960835bcdc130f0b66d7ff4f6a5a8e"
      end
    end

    defp with_example_data(_context) do
      data = "3, 4, 1, 5"
      [data: data]
    end
  end
else
  data = "10.txt" |> File.read! |> String.trim_trailing
  checksum = Puzzle.checksum2(data)
  IO.puts "The checksum is: #{checksum}"

  knot_hash = Puzzle.knot_hash(data)
  IO.puts "The knot hash is: #{knot_hash}"
end
