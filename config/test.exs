import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :my_podcasts, MyPodcasts.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "my_podcasts_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :my_podcasts, MyPodcastsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "uOa0WuaA8DDnFiIf8Eh09sKgbg7fEYMSnYI9s3p+Kzeg+Jmx4fTwV8V/1//hBeCO",
  server: false

# Configure Downloader module
config :my_podcasts, downloader: MyPodcasts.DownloaderMock

# In test we don't send emails
config :my_podcasts, MyPodcasts.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
