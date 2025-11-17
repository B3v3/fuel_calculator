defmodule FuelCalculatorWeb.FuelCalculatorLive do
  use FuelCalculatorWeb, :live_view

  alias FuelCalculator.{Calculator, FlightPaths}
  alias FuelCalculator.FlightPaths.FlightPath
  alias FuelCalculatorWeb.FuelCalculatorLive.Components

  @impl true
  def mount(_params, _session, socket) do
    flight_path = %FlightPath{}
    changeset = FlightPath.changeset(flight_path, %{})

    {:ok,
     socket
     |> assign(:flight_path, flight_path)
     |> assign(:form, to_form(changeset))
     |> assign(:total_fuel, nil)
     |> assign(:calculated_flight_path, nil)
     |> assign(:planets, Calculator.planets_gravity())}
  end

  @impl true
  def handle_event("validate", %{"flight_path" => params}, socket) do
    changeset =
      socket.assigns.flight_path
      |> FlightPath.changeset(params)
      |> Map.put(:action, :validate)

    flight_path =
      if changeset.valid? do
        Ecto.Changeset.apply_changes(changeset)
      else
        socket.assigns.flight_path
      end

    {:noreply,
     socket
     |> assign(:flight_path, flight_path)
     |> assign(:form, to_form(changeset))
     |> maybe_calculate_fuel(changeset)}
  end

  @impl true
  def handle_event("add_step", %{"planet" => planet}, socket) do
    planet_atom = String.to_existing_atom(planet)
    current_steps = socket.assigns.flight_path.steps

    new_steps = FlightPaths.build_steps(current_steps, planet_atom)
    updated_steps = current_steps ++ new_steps
    flight_path = %{socket.assigns.flight_path | steps: updated_steps}

    changeset = build_changeset(flight_path, socket.assigns.flight_path.mass)

    {:noreply,
     socket
     |> assign(:flight_path, flight_path)
     |> assign(:form, to_form(changeset))
     |> maybe_calculate_fuel(changeset)}
  end

  @impl true
  def handle_event("remove_step", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    updated_steps = List.delete_at(socket.assigns.flight_path.steps, index)
    flight_path = %{socket.assigns.flight_path | steps: updated_steps}

    changeset = build_changeset(flight_path, socket.assigns.flight_path.mass)

    {:noreply,
     socket
     |> assign(:flight_path, flight_path)
     |> assign(:form, to_form(changeset))
     |> maybe_calculate_fuel(changeset)}
  end

  defp build_changeset(flight_path, mass) do
    params = if mass, do: %{"mass" => mass}, else: %{}
    FlightPath.changeset(flight_path, params)
  end

  defp maybe_calculate_fuel(socket, changeset) do
    if changeset.valid? do
      flight_path_data = Ecto.Changeset.apply_changes(changeset)

      if flight_path_data.mass && length(flight_path_data.steps) > 0 do
        steps =
          Enum.map(flight_path_data.steps, fn step ->
            %{action: step.action, planet: step.planet}
          end)

        total_fuel = Calculator.calculate_total_fuel(flight_path_data.mass, steps)

        socket
        |> assign(:total_fuel, total_fuel)
        |> assign(:calculated_flight_path, flight_path_data)
      else
        assign_empty_result(socket)
      end
    else
      assign_empty_result(socket)
    end
  end

  defp assign_empty_result(socket) do
    socket
    |> assign(:total_fuel, nil)
    |> assign(:calculated_flight_path, nil)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen relative overflow-hidden">
      <Components.space_background />

      <div class="mx-auto max-w-7xl px-4 py-8 relative">
        <div class="mb-8 text-center">
          <h1 class="text-5xl font-bold bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent mb-3 drop-shadow-lg">
            Interplanetary Fuel Calculator
          </h1>
          <p class="text-blue-200 text-lg drop-shadow-md">
            Calculate the fuel needed for your space mission
          </p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div class="space-y-6">
            <.form for={@form} id="flight-path-form" phx-change="validate">
              <div class="backdrop-blur-md bg-white/10 rounded-2xl shadow-2xl p-6 border border-white/20">
                <h2 class="text-xl font-semibold text-white mb-4 flex items-center gap-2">
                  <span class="text-2xl">🚀</span> Spacecraft Mass
                </h2>
                <.input
                  field={@form[:mass]}
                  type="number"
                  label="Equipment Mass (kg)"
                  placeholder="Enter mass in kilograms"
                  min="1"
                  step="1"
                />
              </div>

              <div class="backdrop-blur-md bg-white/10 rounded-2xl shadow-2xl p-6 border border-white/20 mt-4">
                <h2 class="text-xl font-semibold text-white mb-4 flex items-center gap-2">
                  <span class="text-2xl">🌌</span> Flight Path Builder
                </h2>

                <div class="mb-6">
                  <Components.planet_selector
                    planets={@planets}
                    current_steps={@flight_path.steps}
                  />
                </div>

                <Components.flight_path_list steps={@flight_path.steps} planets={@planets} />
              </div>
            </.form>
          </div>

          <div class="space-y-6">
            <Components.fuel_result
              :if={@total_fuel}
              total_fuel={@total_fuel}
              calculated_flight_path={@calculated_flight_path}
              planets={@planets}
            />

            <Components.empty_result :if={!@total_fuel} />
          </div>
        </div>
      </div>
    </div>
    """
  end
end
