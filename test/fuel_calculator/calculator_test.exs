defmodule FuelCalculator.CalculatorTest do
  use ExUnit.Case, async: true

  alias FuelCalculator.Calculator

  doctest FuelCalculator.Calculator

  describe "calculate_base_fuel/3" do
    test "calculates launch fuel from Earth correctly" do
      assert Calculator.calculate_fuel_for_step(28801, 9.807, :launch) > 0
    end

    test "calculates landing fuel on Earth correctly" do
      base_fuel = trunc(Float.floor(28801 * 9.807 * 0.033 - 42))
      step_fuel = Calculator.calculate_fuel_for_step(28801, 9.807, :land)
      assert step_fuel >= base_fuel
    end
  end

  describe "calculate_fuel_for_step/3" do
    test "landing Apollo 11 CSM on Earth requires 13447 kg" do
      assert Calculator.calculate_fuel_for_step(28801, 9.807, :land) == 13447
    end

    test "handles zero or negative base fuel" do
      assert Calculator.calculate_fuel_for_step(1, 1.62, :land) == 0
    end

    test "raises error for unsupported action" do
      assert_raise ArgumentError, "unsupported action: :orbit. Must be :launch or :land", fn ->
        Calculator.calculate_fuel_for_step(1000, 9.807, :orbit)
      end
    end
  end

  describe "calculate_total_fuel/2" do
    test "Apollo 11 Mission: launch Earth, land Moon, launch Moon, land Earth" do
      flight_path = [
        %{action: :launch, planet: :earth},
        %{action: :land, planet: :moon},
        %{action: :launch, planet: :moon},
        %{action: :land, planet: :earth}
      ]

      assert Calculator.calculate_total_fuel(28801, flight_path) == 51898
    end

    test "Mars Mission: launch Earth, land Mars, launch Mars, land Earth" do
      flight_path = [
        %{action: :launch, planet: :earth},
        %{action: :land, planet: :mars},
        %{action: :launch, planet: :mars},
        %{action: :land, planet: :earth}
      ]

      assert Calculator.calculate_total_fuel(14606, flight_path) == 33388
    end

    test "Passenger Ship Mission: launch Earth, land Moon, launch Moon, land Mars, launch Mars, land Earth" do
      flight_path = [
        %{action: :launch, planet: :earth},
        %{action: :land, planet: :moon},
        %{action: :launch, planet: :moon},
        %{action: :land, planet: :mars},
        %{action: :launch, planet: :mars},
        %{action: :land, planet: :earth}
      ]

      assert Calculator.calculate_total_fuel(75432, flight_path) == 212_161
    end

    test "single step flight path" do
      flight_path = [%{action: :launch, planet: :earth}]
      result = Calculator.calculate_total_fuel(1000, flight_path)
      assert result > 0
    end

    test "empty flight path requires no fuel" do
      assert Calculator.calculate_total_fuel(100_000_000, []) == 0
    end
  end

  describe "get_gravity/1" do
    test "returns correct gravity for Earth" do
      assert Calculator.get_gravity(:earth) == 9.807
    end

    test "returns correct gravity for Moon" do
      assert Calculator.get_gravity(:moon) == 1.62
    end

    test "returns correct gravity for Mars" do
      assert Calculator.get_gravity(:mars) == 3.711
    end
  end

  describe "planets_gravity/0" do
    test "returns map with all supported planets" do
      planets = Calculator.planets_gravity()

      assert Map.has_key?(planets, :earth)
      assert Map.has_key?(planets, :moon)
      assert Map.has_key?(planets, :mars)
      assert map_size(planets) == 3
    end
  end
end
