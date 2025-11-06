defmodule SpendTrack.Repo do
  use Ecto.Repo,
    otp_app: :spend_track,
    adapter: Ecto.Adapters.Postgres
end
