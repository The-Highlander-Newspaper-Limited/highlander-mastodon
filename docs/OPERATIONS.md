# Highlander Operations

This document covers production operation notes that are specific to The
Highlander deployment. General Mastodon administration guidance still comes from
the upstream Mastodon documentation.

## Elestio 502 recovery after Elestio update

Highlander has seen 502 errors after Elestio VM update activity where
PostgreSQL and Redis were still running, but the app containers were missing or
stopped:

- `web`
- `streaming`
- `sidekiq`

In that state, Docker may log messages like:

```text
ShouldRestart failed, container will not be restarted
hasBeenManuallyStopped=true
restart canceled
```

`restart: always` does not necessarily recover a container after Docker or
platform automation marks it as manually stopped. Elestio support identified one
root cause as the app containers running from dangling, untagged images. Their
fix was to take the Compose stack down and bring it back up so the app containers
were recreated from properly tagged images.

### Prevention

When restarting the production stack on Elestio, prefer the Elestio UI restart
action or run Compose from the Elestio pipeline terminal. This keeps the restart
inside the deployment environment that owns the stack.

Avoid ad-hoc Docker container restarts for only one app container after platform
maintenance. If the app images or Compose state are wrong, recreate the Compose
app stack instead.

### Recovery checklist

First, confirm which services are running:

```shell
docker compose ps
```

If only `db` and `redis` are running, or if `web`, `streaming`, or `sidekiq` are
missing, recreate the stack from Compose:

```shell
docker compose down
docker compose up -d --build
```

If a plain Compose recreate does not fix the stale image/container state, you can
try to run the full reset command:

> **Caution:** Use `down -v` carefully. It removes Compose-managed named and
> anonymous volumes. The current repository `docker-compose.yml` stores
> PostgreSQL, Redis, and media as bind-mounted directories (`./postgres14`,
> `./redis`, and `./public/system`), so those paths are not removed by `down -v`.
> A customized production Compose file may use named volumes instead, so verify
> storage and backups before running it.

```shell
docker-compose down -v
docker-compose up -d
```

After recreation, check the app containers:

```shell
docker compose ps
docker compose logs --tail=100 web streaming sidekiq
```

The site should stop returning 502 once `web` is healthy and the reverse proxy
can reach it.
