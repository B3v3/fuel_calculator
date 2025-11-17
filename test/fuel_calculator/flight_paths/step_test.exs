defmodule FuelCalculator.FlightPaths.StepTest do
  use ExUnit.Case, async: true

  alias FuelCalculator.FlightPaths.Step

  describe "changeset/2" do
    test "valid changeset with launch action" do
      changeset = Step.changeset(%Step{}, %{"action" => "launch", "planet" => "earth"})

      assert changeset.valid?
      assert changeset.changes.action == :launch
      assert changeset.changes.planet == :earth
    end

    test "valid changeset with land action" do
      changeset = Step.changeset(%Step{}, %{"action" => "land", "planet" => "mars"})

      assert changeset.valid?
      assert changeset.changes.action == :land
      assert changeset.changes.planet == :mars
    end

    test "valid changeset with temp_id" do
      changeset =
        Step.changeset(%Step{}, %{
          "action" => "launch",
          "planet" => "moon",
          "temp_id" => "ABC123"
        })

      assert changeset.valid?
      assert changeset.changes.temp_id == "ABC123"
    end

    test "invalid changeset when action is missing" do
      changeset = Step.changeset(%Step{}, %{"planet" => "earth"})

      refute changeset.valid?
      assert %{action: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset when planet is missing" do
      changeset = Step.changeset(%Step{}, %{"action" => "launch"})

      refute changeset.valid?
      assert %{planet: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset when action is invalid" do
      changeset = Step.changeset(%Step{}, %{"action" => "fly", "planet" => "earth"})

      refute changeset.valid?
      assert %{action: ["is invalid"]} = errors_on(changeset)
    end

    test "invalid changeset when planet is invalid" do
      changeset = Step.changeset(%Step{}, %{"action" => "launch", "planet" => "jupiter"})

      refute changeset.valid?
      assert %{planet: ["is invalid"]} = errors_on(changeset)
    end

    test "accepts all valid actions" do
      for action <- Step.actions() do
        changeset =
          Step.changeset(%Step{}, %{"action" => to_string(action), "planet" => "earth"})

        assert changeset.valid?, "Expected #{action} to be valid"
      end
    end

    test "accepts all valid planets" do
      for planet <- Step.planets() do
        changeset =
          Step.changeset(%Step{}, %{"action" => "launch", "planet" => to_string(planet)})

        assert changeset.valid?, "Expected #{planet} to be valid"
      end
    end
  end

  describe "generate_temp_id/0" do
    test "generates a unique ID" do
      id1 = Step.generate_temp_id()
      id2 = Step.generate_temp_id()

      assert is_binary(id1)
      assert is_binary(id2)
      assert id1 != id2
    end

    test "generates a 16-character hex string" do
      id = Step.generate_temp_id()

      assert String.length(id) == 16
      assert String.match?(id, ~r/^[0-9A-F]{16}$/)
    end
  end

  describe "actions/0 and planets/0" do
    test "returns list of valid actions" do
      assert Step.actions() == [:launch, :land]
    end

    test "returns list of valid planets" do
      assert Step.planets() == [:earth, :moon, :mars]
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
