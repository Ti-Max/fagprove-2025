defmodule MyPodcasts.Repo do
  use Ecto.Repo,
    otp_app: :my_podcasts,
    adapter: Ecto.Adapters.Postgres
end
