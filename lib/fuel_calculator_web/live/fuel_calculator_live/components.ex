defmodule FuelCalculatorWeb.FuelCalculatorLive.Components do
  @moduledoc """
  Reusable UI components for the Fuel Calculator LiveView.
  """
  use Phoenix.Component
  import FuelCalculatorWeb.CoreComponents

  attr :planets, :map, required: true
  attr :current_steps, :list, required: true

  def planet_selector(assigns) do
    ~H"""
    <div class="mb-4">
      <p class="text-sm text-blue-200 mb-3">
        <%= if @current_steps == [] do %>
          Click a planet to <strong class="text-white">launch</strong> from:
        <% else %>
          Click the next planet to visit:
        <% end %>
      </p>
      <div class="flex gap-3">
        <.planet_button planet={:earth} gravity={@planets[:earth]} />
        <.planet_button planet={:moon} gravity={@planets[:moon]} />
        <.planet_button planet={:mars} gravity={@planets[:mars]} />
      </div>
    </div>
    """
  end

  attr :planet, :atom, required: true
  attr :gravity, :float, required: true

  defp planet_button(%{planet: :earth} = assigns) do
    ~H"""
    <button
      type="button"
      phx-click="add_step"
      phx-value-planet="earth"
      class="flex-1 group relative overflow-hidden rounded-xl border-2 border-blue-400/30 bg-gradient-to-br from-blue-500/20 to-blue-600/20 backdrop-blur-sm p-4 hover:border-blue-400 hover:shadow-xl hover:shadow-blue-500/50 transition-all transform hover:scale-105"
    >
      <div class="text-4xl mb-1">🌍</div>
      <div class="text-sm font-semibold text-white">Earth</div>
      <div class="text-xs text-blue-200">{@gravity} m/s²</div>
    </button>
    """
  end

  defp planet_button(%{planet: :moon} = assigns) do
    ~H"""
    <button
      type="button"
      phx-click="add_step"
      phx-value-planet="moon"
      class="flex-1 group relative overflow-hidden rounded-xl border-2 border-gray-400/30 bg-gradient-to-br from-gray-500/20 to-gray-600/20 backdrop-blur-sm p-4 hover:border-gray-300 hover:shadow-xl hover:shadow-gray-400/50 transition-all transform hover:scale-105"
    >
      <div class="text-4xl mb-1">🌙</div>
      <div class="text-sm font-semibold text-white">Moon</div>
      <div class="text-xs text-gray-200">{@gravity} m/s²</div>
    </button>
    """
  end

  defp planet_button(%{planet: :mars} = assigns) do
    ~H"""
    <button
      type="button"
      phx-click="add_step"
      phx-value-planet="mars"
      class="flex-1 group relative overflow-hidden rounded-xl border-2 border-red-400/30 bg-gradient-to-br from-red-500/20 to-orange-500/20 backdrop-blur-sm p-4 hover:border-red-400 hover:shadow-xl hover:shadow-red-500/50 transition-all transform hover:scale-105"
    >
      <div class="text-4xl mb-1">🔴</div>
      <div class="text-sm font-semibold text-white">Mars</div>
      <div class="text-xs text-orange-200">{@gravity} m/s²</div>
    </button>
    """
  end

  attr :steps, :list, required: true
  attr :planets, :map, required: true

  def flight_path_list(assigns) do
    assigns = assign(assigns, :last_index, length(assigns.steps) - 1)

    ~H"""
    <div class="border-t border-white/20 pt-4">
      <h3 class="text-sm font-semibold text-white mb-3">Current Flight Path</h3>

      <div :if={@steps == []} class="text-center py-6 text-blue-200/60">
        <p class="text-sm">No steps added yet</p>
      </div>

      <div :if={@steps != []} class="space-y-2">
        <.flight_path_step
          :for={{step, idx} <- Enum.with_index(@steps)}
          step={step}
          index={idx}
          planets={@planets}
          is_last={idx == @last_index}
        />
      </div>
    </div>
    """
  end

  attr :step, :map, required: true
  attr :index, :integer, required: true
  attr :planets, :map, required: true
  attr :is_last, :boolean, required: true

  defp flight_path_step(assigns) do
    ~H"""
    <div class="flex items-center gap-3 p-3 backdrop-blur-sm bg-white/5 rounded-xl border border-white/10 hover:bg-white/10 transition-all">
      <div class="flex-shrink-0 w-8 h-8 rounded-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-sm font-semibold text-white shadow-lg">
        {@index + 1}
      </div>
      <div class="flex-1 flex items-center gap-2">
        <.icon
          :if={@step.action == :launch}
          name="hero-rocket-launch"
          class="w-4 h-4 text-blue-300"
        />
        <.icon
          :if={@step.action == :land}
          name="hero-arrow-down-circle"
          class="w-4 h-4 text-purple-300"
        />
        <span class="text-sm font-medium text-white capitalize">{@step.action}</span>
        <span class="text-sm text-blue-200">
          {if @step.action == :launch, do: "from", else: "on"}
        </span>
        <span class="text-lg">{planet_emoji(@step.planet)}</span>
        <span class="text-sm font-medium text-white capitalize">{@step.planet}</span>
      </div>
      <button
        :if={@is_last}
        type="button"
        phx-click="remove_step"
        phx-value-index={@index}
        class="flex-shrink-0 p-1.5 text-red-400 hover:bg-red-500/20 rounded-lg transition-colors"
        title="Remove step"
      >
        <.icon name="hero-trash" class="w-4 h-4" />
      </button>
      <div :if={!@is_last} class="flex-shrink-0 w-7 h-7">
      </div>
    </div>
    """
  end

  attr :total_fuel, :integer, required: true
  attr :calculated_flight_path, :map, required: true
  attr :planets, :map, required: true

  def fuel_result(assigns) do
    ~H"""
    <div class="backdrop-blur-md bg-gradient-to-br from-green-500/20 to-emerald-600/20 rounded-2xl shadow-2xl p-6 border border-green-400/30 sticky top-6">
      <div class="mb-6">
        <h2 class="text-lg font-semibold text-white mb-1 flex items-center gap-2">
          <span class="text-2xl">⚡</span> Total Fuel Required
        </h2>
        <p class="text-sm text-green-200">For your complete mission</p>
        <div class="mt-4 text-center">
          <div class="text-6xl font-bold bg-gradient-to-r from-green-300 to-emerald-400 bg-clip-text text-transparent drop-shadow-lg">
            {format_number(@total_fuel)}
          </div>
          <div class="text-lg text-green-200 font-medium mt-2">kilograms</div>
        </div>
      </div>

      <.mission_summary flight_path={@calculated_flight_path} planets={@planets} />
    </div>
    """
  end

  attr :flight_path, :map, required: true
  attr :planets, :map, required: true

  defp mission_summary(assigns) do
    ~H"""
    <div class="backdrop-blur-sm bg-white/10 rounded-xl p-4 border border-white/20">
      <h3 class="font-semibold text-white mb-3 flex items-center gap-2">
        <span>📋</span> Mission Summary
      </h3>
      <div class="space-y-2">
        <div class="flex justify-between text-sm">
          <span class="text-blue-200">Spacecraft Mass:</span>
          <span class="font-medium text-white">
            {format_number(@flight_path.mass)} kg
          </span>
        </div>
        <div class="flex justify-between text-sm">
          <span class="text-blue-200">Flight Path Steps:</span>
          <span class="font-medium text-white">
            {length(@flight_path.steps)}
          </span>
        </div>
        <div class="border-t border-white/20 pt-2 mt-2">
          <ol class="space-y-1 text-sm">
            <li
              :for={{step, idx} <- Enum.with_index(@flight_path.steps)}
              class="flex items-center gap-2"
            >
              <span class="text-blue-300">{idx + 1}.</span>
              <span class="capitalize font-medium text-white">{step.action}</span>
              <span class="text-blue-300">-</span>
              <span class="capitalize text-white">{step.planet}</span>
              <span :if={step.planet} class="text-xs text-blue-200">
                ({@planets[step.planet]} m/s²)
              </span>
            </li>
          </ol>
        </div>
      </div>
    </div>
    """
  end

  def empty_result(assigns) do
    ~H"""
    <div class="backdrop-blur-md bg-white/10 rounded-2xl shadow-2xl p-8 border border-white/20 text-center sticky top-6">
      <.icon name="hero-calculator" class="w-16 h-16 mx-auto mb-4 text-blue-300" />
      <h3 class="text-lg font-semibold text-white mb-2">Ready to Calculate</h3>
      <p class="text-sm text-blue-200">
        Enter spacecraft mass and add flight path steps to calculate fuel requirements
      </p>
    </div>
    """
  end

  def space_background(assigns) do
    ~H"""
    <div
      class="fixed inset-0 -z-10"
      style="background: linear-gradient(to bottom, #0a1628 0%, #0d2847 30%, #1a4d7a 60%, #0a1628 100%);"
    >
      <%!-- Enhanced stars effect --%>
      <div class="absolute inset-0">
        <div
          class="absolute w-1 h-1 bg-white rounded-full animate-pulse"
          style="top: 8%; left: 12%; box-shadow: 0 0 4px white;"
        >
        </div>
        <div
          class="absolute w-2 h-2 bg-blue-100 rounded-full"
          style="top: 15%; left: 25%; box-shadow: 0 0 10px #60a5fa;"
        >
        </div>
        <div
          class="absolute w-0.5 h-0.5 bg-white rounded-full"
          style="top: 18%; left: 48%; box-shadow: 0 0 2px white;"
        >
        </div>
        <div
          class="absolute w-1 h-1 bg-white rounded-full animate-pulse"
          style="top: 12%; left: 72%; box-shadow: 0 0 3px white; animation-delay: 0.5s;"
        >
        </div>
        <div
          class="absolute w-0.5 h-0.5 bg-white rounded-full"
          style="top: 22%; left: 88%; box-shadow: 0 0 2px white;"
        >
        </div>
        <div
          class="absolute w-1.5 h-1.5 bg-blue-200 rounded-full"
          style="top: 28%; left: 35%; box-shadow: 0 0 8px #93c5fd;"
        >
        </div>
        <div
          class="absolute w-1 h-1 bg-white rounded-full animate-pulse"
          style="top: 35%; left: 8%; box-shadow: 0 0 3px white; animation-delay: 1s;"
        >
        </div>
        <div
          class="absolute w-0.5 h-0.5 bg-white rounded-full"
          style="top: 42%; left: 58%; box-shadow: 0 0 2px white;"
        >
        </div>
        <div
          class="absolute w-2 h-2 bg-blue-200 rounded-full"
          style="top: 38%; left: 78%; box-shadow: 0 0 10px #60a5fa;"
        >
        </div>
        <div
          class="absolute w-1.5 h-1.5 bg-white rounded-full animate-pulse"
          style="top: 48%; left: 22%; box-shadow: 0 0 6px white; animation-delay: 1.5s;"
        >
        </div>
        <div
          class="absolute w-0.5 h-0.5 bg-white rounded-full"
          style="top: 52%; left: 42%; box-shadow: 0 0 2px white;"
        >
        </div>
        <div
          class="absolute w-1 h-1 bg-white rounded-full"
          style="top: 58%; left: 65%; box-shadow: 0 0 3px white;"
        >
        </div>
        <div
          class="absolute w-2 h-2 bg-blue-100 rounded-full"
          style="top: 55%; left: 85%; box-shadow: 0 0 8px #93c5fd;"
        >
        </div>
        <div
          class="absolute w-0.5 h-0.5 bg-white rounded-full"
          style="top: 62%; left: 15%; box-shadow: 0 0 2px white;"
        >
        </div>
        <div
          class="absolute w-1 h-1 bg-white rounded-full animate-pulse"
          style="top: 68%; left: 52%; box-shadow: 0 0 3px white; animation-delay: 0.75s;"
        >
        </div>
        <div
          class="absolute w-1.5 h-1.5 bg-blue-200 rounded-full"
          style="top: 72%; left: 32%; box-shadow: 0 0 6px #60a5fa;"
        >
        </div>
        <div
          class="absolute w-1 h-1 bg-white rounded-full"
          style="top: 78%; left: 72%; box-shadow: 0 0 3px white;"
        >
        </div>
        <div
          class="absolute w-0.5 h-0.5 bg-white rounded-full"
          style="top: 82%; left: 48%; box-shadow: 0 0 2px white;"
        >
        </div>
        <div
          class="absolute w-1 h-1 bg-white rounded-full animate-pulse"
          style="top: 88%; left: 18%; box-shadow: 0 0 3px white; animation-delay: 2s;"
        >
        </div>
        <div
          class="absolute w-2 h-2 bg-blue-100 rounded-full"
          style="top: 92%; left: 68%; box-shadow: 0 0 8px #93c5fd;"
        >
        </div>
      </div>
      <%!-- Blue nebula clouds --%>
      <div class="absolute top-10 right-1/4 w-[700px] h-[700px] bg-blue-400/20 rounded-full blur-3xl">
      </div>
      <div class="absolute top-1/3 left-10 w-[600px] h-[600px] bg-cyan-400/15 rounded-full blur-3xl">
      </div>
      <div class="absolute bottom-20 right-1/3 w-[500px] h-[500px] bg-blue-300/15 rounded-full blur-3xl">
      </div>
      <div
        class="absolute top-1/2 left-1/2 w-96 h-96 bg-pink-500 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse"
        style="animation-delay: 4s;"
      >
      </div>
    </div>
    """
  end

  defp planet_emoji(:earth), do: "🌍"
  defp planet_emoji(:moon), do: "🌙"
  defp planet_emoji(:mars), do: "🔴"
  defp planet_emoji(_), do: "❓"

  defp format_number(number) do
    number
    |> to_string()
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(",")
    |> String.reverse()
  end
end
