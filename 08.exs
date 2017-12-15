defmodule Puzzle do
  defmodule Instruction do
    defstruct [:register, :modifier, :cond_register, :condition]

    @default_register_value 0
    @operations ~w(inc dec)
    @conditions ~w(> < >= <= == !=)

    def new(string) do
      operations = Enum.join(@operations, "|")
      conditions = Enum.join(@conditions, "|")

      regex =
        ~r/(\w+) (#{operations}) (-?\d+) if (\w+) (#{conditions}) (-?\d+)/

      [_, reg, operation, arg, cond_reg, condt, cond_arg] =
        Regex.run(regex, string)

      register      = String.to_atom(reg)
      cond_register = String.to_atom(cond_reg)
      argument      = String.to_integer(arg)
      cond_argument = String.to_integer(cond_arg)

      %Instruction{
        register:       register,
        modifier:       build_modifier(operation, argument),
        cond_register:  cond_register,
        condition:      build_condition(condt, cond_argument),
      }
    end

    @spec execute(Map.t, List.t) :: integer
    def execute(instruction, registers) do
      register_value =
        Map.get(registers, instruction.register, @default_register_value)

      condition_value =
        Map.get(registers, instruction.cond_register, @default_register_value)

      if instruction.condition.(condition_value) do
        instruction.modifier.(register_value)
      else
        register_value
      end
    end

    defp build_modifier(operator, arg) do
      case operator do
        "dec" ->
          &(&1 - arg)
        "inc" ->
          &(&1 + arg)
      end
    end

    defp build_condition(condition, arg) do
      case condition do
        ">" ->
          &(&1 > arg)
        "<" ->
          &(&1 < arg)
        ">=" ->
          &(&1 >= arg)
        "<=" ->
          &(&1 <= arg)
        "==" ->
          &(&1 == arg)
        "!=" ->
          &(&1 != arg)
      end
    end
  end

  def max_register(data) do
    instructions = build_instructions(data)
    registers = apply_instructions(%{}, instructions)

    registers
      |> Enum.max_by(fn {_register, value} -> value end)
      |> elem(1)
  end

  def max_allocate(data) do
    instructions = build_instructions(data)
    {_registers, max} = apply_instructions_allocate(%{}, instructions)
    max
  end

  def apply_instructions(registers, []), do: registers
  def apply_instructions(registers, [instruction | instructions]) do
    updated_value = Instruction.execute(instruction, registers)

    registers
      |> Map.put(instruction.register, updated_value)
      |> apply_instructions(instructions)
  end

  def apply_instructions_allocate(registers, insts, max \\ nil)
  def apply_instructions_allocate(registers, [], max), do: {registers, max}
  def apply_instructions_allocate(registers, [inst | insts], max) do
    updated_value = Instruction.execute(inst, registers)

    max =
      cond do
        is_nil(max) -> updated_value
        updated_value > max -> updated_value
        true -> max
      end

    registers
      |> Map.put(inst.register, updated_value)
      |> apply_instructions_allocate(insts, max)
  end

  @spec build_instructions(String.t) :: List.t
  defp build_instructions(data) do
    data
      |> String.split("\n", trim: true)
      |> Enum.map(&Instruction.new/1)
  end
end

mode = List.first(System.argv)

if mode == "test" do
  ExUnit.start()

  defmodule PuzzleTest do
    use ExUnit.Case

    describe "max_register(data) with example data" do
      setup [:with_example_data]

      test "returns expected", context do
        max = Puzzle.max_register(context[:data])
        assert max == 1
      end
    end

    describe "max_allocate(data) with example data" do
      setup [:with_example_data]

      test "returns expected", context do
        max = Puzzle.max_allocate(context[:data])
        assert max == 10
      end
    end

    defp with_example_data(_context) do
      data = """
      b inc 5 if a > 1
      a inc 1 if b < 5
      c dec -10 if a >= 1
      c inc -20 if c == 10
      """

      [data: data]
    end
  end
else
  data = "08.txt" |> File.read! |> String.trim_trailing
  max = Puzzle.max_register(data)
  IO.puts "The maximum value is: #{max}"

  max = Puzzle.max_allocate(data)
  IO.puts "The maximum allocation is: #{max}"
end
