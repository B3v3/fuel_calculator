defmodule FuelCalculator.FlightPaths.Step do
  @moduledoc """
  Embedded schema for a single flight path step.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @actions [:launch, :land]
  @planets [:earth, :moon, :mars]

  @primary_key false
  embedded_schema do
    field :action, Ecto.Enum, values: @actions
    field :planet, Ecto.Enum, values: @planets
    field :temp_id, :string, virtual: true
  end

  def changeset(step, attrs) do
    step
    |> cast(attrs, [:action, :planet, :temp_id])
    |> validate_required([:action, :planet])
    |> validate_inclusion(:action, @actions)
    |> validate_inclusion(:planet, @planets)
  end

  def actions, do: @actions
  def planets, do: @planets

  def generate_temp_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16()
  end
end
