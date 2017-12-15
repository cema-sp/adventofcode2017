defmodule Puzzle do
  defmodule Tower do
    defstruct [bottom: nil, pool: %{}]

    @spec new(List.t) :: Map.t
    def new(programs \\ [])

    def new([]), do: %Tower{}
    def new(programs) do
      pool =
        programs
          |> Enum.map(&({&1.name, &1}))
          |> Map.new

      tower = %Tower{pool: pool}

      tower |> connect |> init_bottom
    end

    def connect(tower) do
      program_names = Map.keys(tower.pool)

      Enum.reduce(program_names, tower, fn (name, twr) ->
        program = connect_program(twr, name)
        replace_program(twr, name, program)
      end)
    end

    defp init_bottom(tower) do
      bottom =
        tower.pool
          |> Map.values
          |> Enum.max_by(&(&1.tower_power))

      %{tower | bottom: bottom}
    end

    def disbalance(program) do
      if Enum.empty?(program.deps) do
        {nil, 0}
      else
        case analyze_weights(program.deps) do
          {nil, nil} ->
            {nil, 0}
          {outliner, goal} ->
            outliner_program = hd(elem(outliner, 1))
            delta = elem(goal, 0) - elem(outliner, 0)
            goal_weight = outliner_program.weight + delta

            case disbalance(outliner_program) do
              {nil, 0} ->
                {outliner_program, goal_weight}
              other ->
                other
            end
        end
      end
    end

    defp weight_stats(deps) do
      Enum.reduce(deps, %{}, fn (dep, acc) ->
        Map.update(acc, dep.tower_weight, [dep], fn programs ->
          [dep | programs]
        end)
      end)
    end

    defp analyze_weights(deps) do
      {outliner, goal} =
        deps
          |> weight_stats
          |> Enum.min_max_by(fn {_weight, programs} -> length(programs) end)

      if outliner == goal do
        {nil, nil}
      else
        {outliner, goal}
      end
    end

    def lengths(tower) do
      tower.pool
        |> Map.values
        |> Enum.map(&({&1.name, &1.tower_power}))
    end

    def weight(program) do
      deps_weights =
        program.deps
          |> Enum.map(&(weight(&1)))
          |> Enum.sum

      deps_weights + program.weight
    end

    @doc """
    Recursive aproach

    def lengths(tower) do
      tower.pool
        |> Map.keys
        |> Enum.map(&({&1, tower_power(tower.pool, &1)}))
    end

    def tower_power(pool, program_name) do
      program = pool[program_name]
      deps = program.deps

      if deps == [] do
        1
      else
        deps_power =
          deps
            |> Enum.map(&(&1.name))
            |> Enum.map(&(tower_power(pool, &1)))
            |> Enum.sum

        deps_power + 1
      end
    end
    """

    defp connect_program(tower, program_name) do
      program = tower.pool[program_name]

      deps =
        Enum.map(program.deps, fn dep ->
          if is_atom(dep) do
            connect_program(tower, dep)
          else
            dep
          end
        end)

      dep_powers = Enum.map(deps, &(&1.tower_power))
      dep_weights = Enum.map(deps, &(&1.tower_weight))

      %{program | deps:          deps,
                  tower_power:   Enum.sum([1 | dep_powers]),
                  tower_weight:  Enum.sum([program.weight | dep_weights])}
    end

    defp replace_program(tower, name, program) do
      Map.update(tower, :pool, %{}, fn pool ->
        %{pool | name => program}
      end)
    end
  end

  defmodule Program do
    @line_regex ~r/([a-z]+)\s\((\d+)\)(\s->\s)?(.+)?/
    defstruct [:name, :weight, tower_power: 1, tower_weight: 0, deps: []]

    def new(line) do
      case Regex.run(@line_regex, line) do
        [_all, name, weight, _, deps_str] ->
          deps =
            deps_str
              |> String.split(", ", trim: true)
              |> Enum.map(&String.to_atom/1)

          %Program{
            name:    String.to_atom(name),
            weight:  String.to_integer(weight),
            deps:    deps
          }

        [_all, name, weight] ->
          %Program{
            name:    String.to_atom(name),
            weight:  String.to_integer(weight)
          }

        _ -> raise "Couldn't parse line: #{inspect(line)}"
      end
    end
  end

  def bottom_name(data) do
    tower = build_tower(data)

    case tower.bottom do
      %Program{name: name} -> name
      _ -> nil
    end
  end

  def weight_goal(data) do
    tower = build_tower(data)
    {_program, goal} = Tower.disbalance(tower.bottom)
    goal
  end

  defp build_tower(data) do
    data
      |> String.split("\n", trim: true)
      |> Enum.map(&Program.new/1)
      |> Tower.new
  end
end

mode = List.first(System.argv)

if mode == "test" do
  ExUnit.start()

  defmodule PuzzleTest do
    use ExUnit.Case

    describe "bottom_name(data) with small data" do
      setup [:with_small_data]

      test "returns expected", context do
        bottom_name = Puzzle.bottom_name(context[:data])
        assert bottom_name == :xhth
      end
    end

    describe "bottom_name(data) with chain data" do
      setup [:with_chain_data]

      test "returns expected", context do
        bottom_name = Puzzle.bottom_name(context[:data])
        assert bottom_name == :ebii
      end
    end

    describe "bottom_name(data) with example data" do
      setup [:with_example_data]

      test "returns expected", context do
        bottom_name = Puzzle.bottom_name(context[:data])
        assert bottom_name == :tknk
      end
    end

    describe "weight_goal(data) with small data" do
      setup [:with_small_data]

      test "returns expected", context do
        weight_goal = Puzzle.weight_goal(context[:data])
        assert weight_goal == 61
      end
    end

    describe "weight_goal(data) with balanced data" do
      setup [:with_balanced_data]

      test "returns expected", context do
        weight_goal = Puzzle.weight_goal(context[:data])
        assert weight_goal == 0
      end
    end

    describe "weight_goal(data) with example data" do
      setup [:with_example_data]

      test "returns expected", context do
        weight_goal = Puzzle.weight_goal(context[:data])
        assert weight_goal == 60
      end
    end

    defp with_small_data(_context) do
      data = """
      pbga (66)
      xhth (57) -> pbga, ebii, hgll
      ebii (61)
      hgll (61)
      """

      [data: data]
    end

    defp with_chain_data(_context) do
      data = """
      pbga (66)
      xhth (57) -> pbga
      ebii (61) -> xhth
      """

      [data: data]
    end

    defp with_balanced_data(_context) do
      data = """
      pbga (66)
      xhth (57) -> pbga, ebii
      ebii (66)
      """

      [data: data]
    end

    defp with_example_data(_context) do
      data = """
      pbga (66)
      xhth (57)
      ebii (61)
      havc (66)
      ktlj (57)
      fwft (72) -> ktlj, cntj, xhth
      qoyq (66)
      padx (45) -> pbga, havc, qoyq
      tknk (41) -> ugml, padx, fwft
      jptl (61)
      ugml (68) -> gyxo, ebii, jptl
      gyxo (61)
      cntj (57)
      """

      [data: data]
    end
  end
else
  data = "07.txt" |> File.read! |> String.trim_trailing
  bottom = Puzzle.bottom_name(data)
  IO.puts "The bottom program name: #{bottom}"

  goal = Puzzle.weight_goal(data)
  IO.puts "The balance goal is: #{goal}"
end
