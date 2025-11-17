defmodule FuelCalculator.FlightPathsTest do
  use ExUnit.Case, async: true

  alias FuelCalculator.FlightPaths
  alias FuelCalculator.FlightPaths.Step

  describe "build_steps/2" do
    test "first step: adds launch from selected planet" do
      steps = FlightPaths.build_steps([], :earth)

      assert [%Step{action: :launch, planet: :earth, temp_id: temp_id}] = steps
      assert is_binary(temp_id)
    end

    test "after launch: adds land on new planet" do
      existing_steps = [%Step{action: :launch, planet: :earth, temp_id: "ABC123"}]

      steps = FlightPaths.build_steps(existing_steps, :moon)

      assert [%Step{action: :land, planet: :moon, temp_id: temp_id}] = steps
      assert is_binary(temp_id)
    end

    test "after land: adds launch from current planet and land on new planet" do
      existing_steps = [%Step{action: :land, planet: :earth, temp_id: "ABC123"}]

      steps = FlightPaths.build_steps(existing_steps, :mars)

      assert [
               %Step{action: :launch, planet: :earth, temp_id: temp_id1},
               %Step{action: :land, planet: :mars, temp_id: temp_id2}
             ] = steps

      assert is_binary(temp_id1)
      assert is_binary(temp_id2)
      assert temp_id1 != temp_id2
    end

    test "complete journey: earth -> moon -> mars" do
      steps1 = FlightPaths.build_steps([], :earth)
      assert [%Step{action: :launch, planet: :earth}] = steps1

      all_steps = steps1
      steps2 = FlightPaths.build_steps(all_steps, :moon)
      assert [%Step{action: :land, planet: :moon}] = steps2

      all_steps = all_steps ++ steps2
      steps3 = FlightPaths.build_steps(all_steps, :mars)

      assert [
               %Step{action: :launch, planet: :moon},
               %Step{action: :land, planet: :mars}
             ] = steps3
    end

    test "generates unique temp_id for each step" do
      steps = FlightPaths.build_steps([], :earth)
      [%{temp_id: id1}] = steps

      steps = FlightPaths.build_steps([%Step{action: :land, planet: :earth}], :moon)
      [%{temp_id: id2}, %{temp_id: id3}] = steps

      assert id1 != id2
      assert id1 != id3
      assert id2 != id3
    end
  end
end
