defmodule FuelCalculator.FlightPaths do
  @moduledoc """
  Module for building flight path steps based on the current state.
  """

  alias FuelCalculator.FlightPaths.Step

  @doc """
  Generates new flight path steps based on the selected planet and current steps.

  ## Logic:
  1. If no steps exist, add "launch from planet"
  2. If last step was a launch, add "land on new planet"
  3. If last step was a land, add "launch from that same planet" + "land on new planet"

  ## Examples

      iex> FuelCalculator.FlightPaths.build_steps([], :earth)
      [%FuelCalculator.FlightPaths.Step{action: :launch, planet: :earth}]

      iex> FuelCalculator.FlightPaths.build_steps([%FuelCalculator.FlightPaths.Step{action: :launch, planet: :earth}], :moon)
      [%FuelCalculator.FlightPaths.Step{action: :land, planet: :moon}]

      iex> FuelCalculator.FlightPaths.build_steps([%FuelCalculator.FlightPaths.Step{action: :land, planet: :earth}], :moon)
      [%FuelCalculator.FlightPaths.Step{action: :launch, planet: :earth}, %FuelCalculator.FlightPaths.Step{action: :land, planet: :moon}]
  """
  def build_steps(current_steps, planet) when is_atom(planet) do
    case List.last(current_steps) do
      nil ->
        [new_step(:launch, planet)]

      %{action: :launch} ->
        [new_step(:land, planet)]

      %{action: :land, planet: last_planet} ->
        [
          new_step(:launch, last_planet),
          new_step(:land, planet)
        ]
    end
  end

  defp new_step(action, planet) do
    %Step{
      action: action,
      planet: planet,
      temp_id: Step.generate_temp_id()
    }
  end
end
