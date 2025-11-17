defmodule FuelCalculator.FlightPaths.FlightPath do
  @moduledoc """
  Embedded schema for handling flight path form data and validation.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias FuelCalculator.FlightPaths.Step

  @primary_key false
  embedded_schema do
    field :mass, :integer
    embeds_many :steps, Step, on_replace: :delete
  end

  def changeset(flight_path, attrs) do
    flight_path
    |> cast(attrs, [:mass])
    |> cast_embed(:steps, with: &Step.changeset/2)
    |> validate_required([:mass])
    |> validate_number(:mass, greater_than: 0, message: "must be a positive number")
  end
end
