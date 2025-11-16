defmodule FuelCalculator.Repo do
  use Ecto.Repo,
    otp_app: :fuel_calculator,
    adapter: Ecto.Adapters.Postgres
end
