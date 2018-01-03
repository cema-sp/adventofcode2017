defmodule Puzzle do
  defmodule Group do
    defstruct [:type, :level, content: ""]
  end

  def total_score(data) do
    stats = stream_stats(data)
    # stats |> IO.inspect(label: "Stats")

    stats.groups
    |> Enum.filter(&(&1.type == :plain))
    |> Enum.map(&(&1.level))
    |> Enum.sum
  end

  def garbage_chars(data) do
    stats = stream_stats(data)
    # stats |> IO.inspect(label: "Stats")

    stats.groups
    |> Enum.filter(&(&1.type == :garbage))
    |> Enum.map(&(byte_size(&1.content)))
    |> Enum.sum
  end

  @initial_stats %{stack: [], ignore: false, groups: []}

  defp stream_stats(stream, stats \\ @initial_stats)
  defp stream_stats("", stats), do: stats

  defp stream_stats("!" <> rest, %{ignore: false} = stats) do
    # IO.puts "Char: !"
    stream_stats(rest, %{stats | ignore: true})
  end

  defp stream_stats(<<_char::utf8>> <> rest, %{ignore: true} = stats) do
    # IO.puts "Ignoring char: #{<<char::utf8>>}"
    stream_stats(rest, %{stats | ignore: false})
  end

  defp stream_stats(<<char::utf8>> <> rest, stats) do
    # IO.puts "Char: #{<<char::utf8>>}"

    {current, stack} = List.pop_at(stats.stack, 0)

    stats =
      if current && current.type == :garbage do
        case char do
          ?> ->
            # IO.puts "\tClosing garbage group!"
            %{stats | stack: stack, groups: [current | stats.groups]}

          _ ->
            # IO.puts "\tContent: #{<<char::utf8>>}"
            current = %{current | content: current.content <> <<char::utf8>>}
            %{stats | stack: [current | stack]}
        end
      else
        case char do
          ?{ ->
            # IO.puts "\tNew group!"
            group = %Group{type: :plain, level: next_level(current)}
            %{stats | stack: [group | [current | stack]]}

          ?} ->
            # IO.puts "\tClosing group!"
            %{stats | stack: stack, groups: [current | stats.groups]}

          ?< ->
            # IO.puts "\tNew garbage group!"
            group = %Group{type: :garbage, level: next_level(current)}
            %{stats | stack: [group | [current | stack]]}

          _ ->
            # IO.puts "\tContent: #{<<char::utf8>>}"
            current = %{current | content: current.content <> <<char::utf8>>}
            %{stats | stack: [current | stack]}
        end
      end

    stream_stats(rest, stats)
  end

  defp next_level(nil), do: 1
  defp next_level(current_group) do
    current_group.level + 1
  end
end

mode = List.first(System.argv)

if mode == "test" do
  ExUnit.start()

  defmodule PuzzleTest do
    use ExUnit.Case

    describe "total_score(data) for 1 group" do
      test "returns expected" do
        data = "{}"
        score = Puzzle.total_score(data)
        assert score == 1
      end
    end

    describe "total_score(data) for 3 groups" do
      test "returns expected" do
        data = "{{{}}}"
        score = Puzzle.total_score(data)
        assert score == 6
      end
    end

    describe "total_score(data) for 6 groups" do
      test "returns expected" do
        data = "{{{},{},{{}}}}"
        score = Puzzle.total_score(data)
        assert score == 16
      end
    end

    describe "total_score(data) for 5 groups" do
      test "returns expected" do
        data = "{{<ab>},{<ab>},{<ab>},{<ab>}}"
        score = Puzzle.total_score(data)
        assert score == 9
      end
    end

    describe "total_score(data) for 5 groups with !!" do
      test "returns expected" do
        data = "{{<!!>},{<!!>},{<!!>},{<!!>}}"
        score = Puzzle.total_score(data)
        assert score == 9
      end
    end

    describe "total_score(data) for 2 groups" do
      test "returns expected" do
        data = "{{<a!>},{<a!>},{<a!>},{<ab>}}"
        score = Puzzle.total_score(data)
        assert score == 3
      end
    end

    describe "garbage_chars(data) for 1 group" do
      test "returns expected" do
        data = "<>"
        chars = Puzzle.garbage_chars(data)
        assert chars == 0
      end
    end

    describe "garbage_chars(data) for 1 < group" do
      test "returns expected" do
        data = "<<<<>"
        chars = Puzzle.garbage_chars(data)
        assert chars == 3
      end
    end

    describe "garbage_chars(data) for 1 mixed group" do
      test "returns expected" do
        data = "<{o\"i!a,<{i<a>"
        chars = Puzzle.garbage_chars(data)
        assert chars == 10
      end
    end

    describe "garbage_chars(data) for 1 big group" do
      test "returns expected" do
        data = "{{<a!>},{<a!>},{<a!>},{<ab>}}"
        chars = Puzzle.garbage_chars(data)
        assert chars == 17
      end
    end
  end
else
  data = "09.txt" |> File.read! |> String.trim_trailing
  score = Puzzle.total_score(data)
  IO.puts "The total score is: #{score}"

  chars = Puzzle.garbage_chars(data)
  IO.puts "The number of garbage chars is: #{chars}"
end
