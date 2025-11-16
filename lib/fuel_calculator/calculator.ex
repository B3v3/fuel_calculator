defmodule FuelCalculator.Calculator do
  @moduledoc """
  Calculates the required fuel for interplanetary travel based on mass, gravity, and action type.
  Calculates the required fuel based on the provided formulas:

  - **Launch:** `mass * gravity * 0.042 - 33` (rounded down)
  - **Landing:** `mass * gravity * 0.033 - 42` (rounded down)
  """

  @planets_gravity %{
    earth: 9.807,
    moon: 1.62,
    mars: 3.711
  }

  @doc """
  Returns all available planets with their gravity constants as map
  """
  def planets_gravity do
    @planets_gravity
  end

  @doc """
  Gets the gravity constant for a given planet.

  ## Parameters
    - planet: Atom representing the planet (:earth, :moon, or :mars)
  """
  def get_gravity(planet) when is_atom(planet) do
    Map.get(@planets_gravity, planet)
  end

  def get_gravity(_unsupported_planet) do
    raise ArgumentError,
          "unsupported planet. Must be one of: #{Enum.join(Map.keys(@planets_gravity), ", ")}"
  end

  @doc """
  Calculates total fuel required for a complete flight path.

  ## Parameters
    - mass: The spacecraft mass (in kg)
    - flight_path: A list of steps, where each step is a map with :action and :planet keys

  ## Returns
    The total fuel required in kg (integer)

  ## Examples

      iex> FuelCalculator.Calculator.calculate_total_fuel(28801, [
      ...>   %{action: :launch, planet: :earth},
      ...>   %{action: :land, planet: :moon},
      ...>   %{action: :launch, planet: :moon},
      ...>   %{action: :land, planet: :earth}
      ...> ])
      51898

      iex> FuelCalculator.Calculator.calculate_total_fuel(14606, [
      ...>   %{action: :launch, planet: :earth},
      ...>   %{action: :land, planet: :mars},
      ...>   %{action: :launch, planet: :mars},
      ...>   %{action: :land, planet: :earth}
      ...> ])
      33388
  """
  def calculate_total_fuel(mass, flight_path) when is_integer(mass) and mass > 0 do
    total_fuel =
      flight_path
      |> Enum.reverse()
      |> Enum.reduce(mass, fn step, current_mass ->
        gravity = get_gravity(step.planet)
        fuel_needed = calculate_fuel_for_step(current_mass, gravity, step.action)
        current_mass + fuel_needed
      end)

    total_fuel - mass
  end

  def calculate_total_fuel(_invalid_mass, _flight_path), do: 0

  @doc """
  Calculates fuel required for a single step (launch or land) including the fuel for the fuel itself.

  ## Parameters
    - mass: The mass to move (including any accumulated fuel)
    - gravity: The gravity constant for the planet
    - action: :launch, :land

  ## Returns
    The total fuel required for this step in kg (integer)

  ## Examples

      iex> FuelCalculator.Calculator.calculate_fuel_for_step(28801, 9.807, :land)
      13447

      iex> FuelCalculator.Calculator.calculate_fuel_for_step(1000, 9.807, :launch)
      517
  """
  def calculate_fuel_for_step(mass, gravity, action) when action in [:launch, :land] do
    base_fuel = calculate_base_fuel(mass, gravity, action)
    calculate_fuel_recursively(base_fuel, gravity, action, 0)
  end

  def calculate_fuel_for_step(_mass, _gravity, action) do
    raise ArgumentError, "unsupported action: #{inspect(action)}. Must be :launch or :land"
  end

  defp calculate_fuel_recursively(fuel, _gravity, _action, accumulated) when fuel <= 0 do
    accumulated
  end

  defp calculate_fuel_recursively(fuel, gravity, action, accumulated) do
    additional_fuel = calculate_base_fuel(fuel, gravity, action)
    calculate_fuel_recursively(additional_fuel, gravity, action, accumulated + fuel)
  end

  defp calculate_base_fuel(mass, gravity, :launch) do
    (mass * gravity * 0.042 - 33)
    |> Float.floor()
    |> trunc()
    |> max(0)
  end

  defp calculate_base_fuel(mass, gravity, :land) do
    (mass * gravity * 0.033 - 42)
    |> Float.floor()
    |> trunc()
    |> max(0)
  end
end
