defmodule FuelCalculator.FlightPaths.FlightPathTest do
  use ExUnit.Case, async: true

  alias FuelCalculator.FlightPaths.FlightPath

  describe "changeset/2" do
    test "valid changeset with mass and no steps" do
      changeset = FlightPath.changeset(%FlightPath{}, %{"mass" => 1000})

      assert changeset.valid?
      assert changeset.changes.mass == 1000
    end

    test "valid changeset with mass and steps" do
      attrs = %{
        "mass" => 2000,
        "steps" => [
          %{"action" => "launch", "planet" => "earth"},
          %{"action" => "land", "planet" => "moon"}
        ]
      }

      changeset = FlightPath.changeset(%FlightPath{}, attrs)

      assert changeset.valid?
      assert changeset.changes.mass == 2000
      assert length(changeset.changes.steps) == 2
    end

    test "invalid changeset when mass is missing" do
      changeset = FlightPath.changeset(%FlightPath{}, %{})

      refute changeset.valid?
      assert %{mass: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset when mass is zero" do
      changeset = FlightPath.changeset(%FlightPath{}, %{"mass" => 0})

      refute changeset.valid?
      assert %{mass: ["must be a positive number"]} = errors_on(changeset)
    end

    test "invalid changeset when mass is negative" do
      changeset = FlightPath.changeset(%FlightPath{}, %{"mass" => -100})

      refute changeset.valid?
      assert %{mass: ["must be a positive number"]} = errors_on(changeset)
    end

    test "invalid changeset when mass is not a number" do
      changeset = FlightPath.changeset(%FlightPath{}, %{"mass" => "abc"})

      refute changeset.valid?
      assert %{mass: ["is invalid"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid steps" do
      attrs = %{
        "mass" => 1000,
        "steps" => [
          %{"action" => "invalid", "planet" => "earth"}
        ]
      }

      changeset = FlightPath.changeset(%FlightPath{}, attrs)

      refute changeset.valid?
      assert %{steps: [%{action: ["is invalid"]}]} = errors_on(changeset)
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
