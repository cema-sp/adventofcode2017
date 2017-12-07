defmodule Puzzle do
  def count_valid(lines) do
    lines
      |> String.split("\n")
      |> Enum.count(&valid?/1)
  end

  def count_valid_anagrams(lines) do
    lines
      |> String.split("\n")
      |> Enum.count(&valid_anagrams?/1)
  end

  def valid?(""), do: false
  def valid?(passphrase) do
    words = String.split(passphrase)
    _valid?(words)
  end

  def valid_anagrams?(""), do: false
  def valid_anagrams?(passphrase) do
    passphrase
      |> String.split
      |> _valid_anagrams?
  end

  defp _valid?(words, cache \\ %{})
  defp _valid?([], _cache), do: true
  defp _valid?([word | words], cache) do
    if cache[word] do
      false
    else
      new_cache = Map.put(cache, word, 1)
      _valid?(words, new_cache)
    end
  end

  defp _valid_anagrams?(words, cache \\ %{})
  defp _valid_anagrams?([], _cache), do: true
  defp _valid_anagrams?([word | words], cache) do
    normalized_word =
      word
        |> String.split("", trim: true)
        |> Enum.sort
        |> Enum.join

    if cache[normalized_word] do
      false
    else
      new_cache = Map.put(cache, normalized_word, 1)
      _valid_anagrams?(words, new_cache)
    end
  end
end

mode = List.first(System.argv)

if mode == "test" do
  ExUnit.start()

  defmodule PuzzleTest do
    use ExUnit.Case

    describe "valid?(passphrase)" do
      test "when passphrase = 'aa bb cc dd ee'" do
        valid = Puzzle.valid?("aa bb cc dd ee")
        assert valid
      end

      test "when passphrase = 'aa bb cc dd aa'" do
        valid = Puzzle.valid?("aa bb cc dd aa")
        refute valid
      end

      test "when passphrase = 'aa bb cc dd aaa'" do
        valid = Puzzle.valid?("aa bb cc dd aaa")
        assert valid
      end
    end

    describe "valid_anagrams?(passphrase)" do
      test "when passphrase = 'abcde fghij'" do
        valid = Puzzle.valid_anagrams?("abcde fghij")
        assert valid
      end

      test "when passphrase = 'abcde xyz ecdab'" do
        valid = Puzzle.valid_anagrams?("abcde xyz ecdab")
        refute valid
      end

      test "when passphrase = 'a ab abc abd abf abj'" do
        valid = Puzzle.valid_anagrams?("a ab abc abd abf abj")
        assert valid
      end

      test "when passphrase = 'iiii oiii ooii oooi oooo'" do
        valid = Puzzle.valid_anagrams?("iiii oiii ooii oooi oooo")
        assert valid
      end

      test "when passphrase = 'oiii ioii iioi iiio'" do
        valid = Puzzle.valid_anagrams?("oiii ioii iioi iiio")
        refute valid
      end
    end
  end
else
  data = "04.txt" |> File.read! |> String.trim_trailing
  valid = Puzzle.count_valid(data)
  valid_anagrams = Puzzle.count_valid_anagrams(data)

  IO.puts "The number of valid passphrases: #{valid}"
  IO.puts "The number of valid anagram passphrases: #{valid_anagrams}"
end
