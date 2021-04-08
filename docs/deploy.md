# Create a new release

```bash
mix deps.get --only prod &&
MIX_ENV=prod mix compile &&
npm run deploy --prefix ./assets &&
mix phx.digest &&
MIX_ENV=prod mix release --overwrite
# copy the release over to the server
rsync -r _build/prod/rel/secretwords worde:~/srv/
```

# Notes

## The asset pipeline
- The raw assets are owned by node and need to be compiled to `priv/static`.
- From there, they're digested by `mix phx.digest` and copied over to the release with `mix release`?