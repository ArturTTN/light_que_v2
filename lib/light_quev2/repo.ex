defmodule LightQuev2.Repo do
  use Ecto.Repo,
    otp_app: :light_quev2,
    adapter: Ecto.Adapters.Postgres
end
