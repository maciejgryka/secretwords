# Local prod run

```bash
mix deps.get --only prod &&
MIX_ENV=prod mix compile &&
MIX_ENV=prod mix release --overwrite &&
npm run deploy --prefix ./assets &&
mix phx.digest

```

# copy the release over

- `rsync -r _build/prod/rel/secretwords worde:~/srv/`
- `rsync -r data worde:~/srv/secretwords/bin`
- on the server `~/srv/secretwords/bin/secretwords restart`