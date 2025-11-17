defmodule FuelCalculatorWeb.FuelCalculatorLiveTest do
  use FuelCalculatorWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "FuelCalculatorLive" do
    test "renders the initial page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      assert html =~ "Interplanetary Fuel Calculator"
      assert html =~ "Spacecraft Mass"
      assert html =~ "Flight Path"
      assert has_element?(view, "#flight-path-form")
    end

    test "shows empty state when no steps are added", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "No steps added yet"
    end

    test "adds a new step when clicking a planet button", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Initially shows empty state
      assert has_element?(view, "p", "No steps added yet")

      # Click Earth - should add "launch from earth"
      view
      |> element("button[phx-value-planet='earth']")
      |> render_click()

      # Now we should have a launch step
      assert has_element?(view, "span", "launch")
      assert has_element?(view, "span", "earth")
    end

    test "removes a step when clicking remove button", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Add a step by clicking Earth
      view
      |> element("button[phx-value-planet='earth']")
      |> render_click()

      assert has_element?(view, "span", "launch")

      # Remove the step
      view |> element("button[phx-click='remove_step'][phx-value-index='0']") |> render_click()

      # Should show empty state again
      assert has_element?(view, "p", "No steps added yet")
    end

    test "calculates fuel for Apollo 11 mission", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Set mass
      view
      |> form("#flight-path-form", %{flight_path: %{mass: "28801"}})
      |> render_change()

      # With smart button behavior:
      # Click 1: Earth -> adds "launch from earth"
      view
      |> element("button[phx-value-planet='earth']")
      |> render_click()

      # Click 2: Moon -> adds "land on moon" (waits for next planet before adding launch)
      view
      |> element("button[phx-value-planet='moon']")
      |> render_click()

      # Click 3: Earth -> adds "launch from moon" + "land on earth"
      view
      |> element("button[phx-value-planet='earth']")
      |> render_click()

      html = render(view)

      # Should show the correct fuel calculation (4 steps total)
      assert html =~ "51,898"
      assert html =~ "Total Fuel Required"
    end

    test "calculates fuel for Mars mission", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Set mass
      view
      |> form("#flight-path-form", %{flight_path: %{mass: "14606"}})
      |> render_change()

      # With smart button behavior:
      # Click 1: Earth -> adds "launch from earth"
      view
      |> element("button[phx-value-planet='earth']")
      |> render_click()

      # Click 2: Mars -> adds "land on mars"
      view
      |> element("button[phx-value-planet='mars']")
      |> render_click()

      # Click 3: Earth -> adds "launch from mars" + "land on earth"
      view
      |> element("button[phx-value-planet='earth']")
      |> render_click()

      # Should show the correct fuel calculation (4 steps total)
      assert has_element?(view, "div", "33,388")
    end

    test "calculates fuel for Passenger Ship mission", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Set mass
      view
      |> form("#flight-path-form", %{flight_path: %{mass: "75432"}})
      |> render_change()

      # With smart button behavior:
      # Click 1: Earth -> adds "launch from earth"
      view
      |> element("button[phx-value-planet='earth']")
      |> render_click()

      # Click 2: Moon -> adds "land on moon"
      view
      |> element("button[phx-value-planet='moon']")
      |> render_click()

      # Click 3: Mars -> adds "launch from moon" + "land on mars"
      view
      |> element("button[phx-value-planet='mars']")
      |> render_click()

      # Click 4: Earth -> adds "launch from mars" + "land on earth"
      view
      |> element("button[phx-value-planet='earth']")
      |> render_click()

      # Should show the correct fuel calculation (6 steps total)
      assert has_element?(view, "div", "212,161")
    end

    test "validates mass is required", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Add a step by clicking a planet
      view
      |> element("button[phx-value-planet='earth']")
      |> render_click()

      # Try to submit with no mass
      view
      |> form("#flight-path-form", %{flight_path: %{mass: ""}})
      |> render_change()

      # Should not show fuel calculation
      refute has_element?(view, "div", "Total Fuel Required")
    end

    test "validates mass must be positive", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Add a step by clicking a planet
      view
      |> element("button[phx-value-planet='earth']")
      |> render_click()

      # Try with negative mass
      view
      |> form("#flight-path-form", %{flight_path: %{mass: "-100"}})
      |> render_change()

      # Should show validation error
      html = render(view)
      assert html =~ "must be a positive number"
    end

    test "does not calculate fuel without steps", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Enter mass but no steps
      view
      |> form("#flight-path-form", %{
        flight_path: %{
          mass: "1000"
        }
      })
      |> render_change()

      # Should not show fuel calculation
      refute has_element?(view, "div", "Total Fuel Required")
    end

    test "shows mission summary when fuel is calculated", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Set mass
      view
      |> form("#flight-path-form", %{flight_path: %{mass: "1000"}})
      |> render_change()

      # Add a step by clicking a planet
      view
      |> element("button[phx-value-planet='earth']")
      |> render_click()

      # Should show mission summary
      assert has_element?(view, "h3", "Mission Summary")
      assert has_element?(view, "span", "1,000 kg")
      assert has_element?(view, "span", "1")
    end
  end
end
