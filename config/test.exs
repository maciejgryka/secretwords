import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :secretwords, SecretwordsWeb.Endpoint,
  http: [port: 4002],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

config :wallaby,
  driver: Wallaby.Chrome
