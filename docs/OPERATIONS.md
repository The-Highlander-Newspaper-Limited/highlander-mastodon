# Highlander Operations

This document covers production operation notes that are specific to The
Highlander deployment. General Mastodon administration guidance still comes from
the upstream Mastodon documentation.

## Uptime monitoring with UptimeRobot

Use UptimeRobot to monitor both the public application and its health endpoint:

```text
https://thehighlander.app
https://thehighlander.app/health
```

The following UptimeRobot free tier setups are suitable for a small team of
maintainers:

- **Individual accounts:** Each maintainer creates an UptimeRobot account and
  configures the same monitors. Everyone receives personal email and mobile push
  notifications, but monitor configuration and incident history are duplicated.
- **Shared Discord notifications:** One maintainer owns and configures the
  monitors, then sends alerts to a shared Discord channel. Other maintainers do
  not need UptimeRobot accounts, but only the account owner can manage the
  monitors and view their complete incident history.

If the team grows, consider moving to the Team plan, consolidating the monitors
under one account, and adding maintainers with login or notify-only access.

The Free plan’s shortest monitoring interval is five minutes.
If an alerting delay of up to approximately five minutes is not acceptable,
a paid plan should be used. SMS and voice notifications require credits;
email and mobile app push notifications are the preferred default channels.

### Create the monitors

Create two monitors in each account:

| Friendly name            | Type    | URL                                | Purpose                                |
| ------------------------ | ------- | ---------------------------------- | -------------------------------------- |
| `The Highlander website` | HTTP(s) | `https://thehighlander.app`        | Checks the public, user-facing route   |
| `The Highlander health`  | HTTP(s) | `https://thehighlander.app/health` | Checks the application health endpoint |

Configure the health monitor as follows:

1. Register or sign in at [UptimeRobot](https://uptimerobot.com/).
2. Select **Add New Monitor** and choose **HTTP(s)**.
3. Set the friendly name to `The Highlander health`.
4. Set the URL to `https://thehighlander.app/health`.
5. Select the account's email alert contact and any configured mobile push
   contact.
6. Use the shortest monitoring interval available to the account, then create
   the monitor.

Repeat the process with the website URL to create the public website monitor.
Enable the same notification contacts on both monitors. HTTP responses such as
502 mark the corresponding monitor as down. A full outage can mark both
monitors as down and therefore generate two sets of notifications.

### Configure personal notifications

Use this option when each maintainer has a separate UptimeRobot account and
receives notifications directly.

- **Email:** UptimeRobot uses the account email as its personal email channel.
- **Mobile push:** Install the UptimeRobot Android or iOS app and sign in with
  the same account. Enable the resulting push contact on both monitors.
- **SMS or voice:** Add and verify one phone number, purchase credits, and enable
  that contact on the monitor only if phone escalation is needed.

Confirm that every intended contact is enabled on both monitors and use
UptimeRobot's notification test before relying on it.

### Configure shared Discord notifications

Use this option when one maintainer owns the monitors and the others only need alerts through Discord.

1. In Discord, open the target channel's settings, select `Integrations`, create
   a webhook, and copy its URL.
2. In UptimeRobot, open `Integrations & API`, add the Discord integration, paste
   the webhook URL, and select the DOWN and UP events.
3. Enable the integration for both monitors from each monitor's
   `Integrations & Team` tab.
4. Use UptimeRobot's notification test and verify that both DOWN and recovery
   messages reach the Discord channel.

### Respond to an alert

When a DOWN notification arrives, record the alert time in UTC. First, check the
public endpoint from any machine with internet access:

```shell
curl -i https://thehighlander.app/health
```

Then open the Elestio VM terminal, change to the production Compose project
directory, and check the stack:

```shell
docker compose ps
```

Capture incident logs before rebuilding or recreating containers whenever
possible. An UP notification confirms that the external health check has
recovered, but the Compose health and application logs should still be checked.

UptimeRobot setup details and plan capabilities can change. Refer to its
[monitor setup guide](https://help.uptimerobot.com/en/articles/11358364-how-to-create-your-first-monitor-on-uptimerobot-quick-setup-guide),
[notification channel guide](https://help.uptimerobot.com/en/articles/11360953-uptimerobot-personal-notification-channels-setup-guide), and
[Discord integration guide](https://uptimerobot.com/integrations/discord-integration/).
Check its [current pricing](https://uptimerobot.com/pricing/) when choosing or changing the monitoring setup.

## Elestio 502 recovery after Elestio update

Highlander has seen 502 errors after Elestio VM update activity where the
reverse proxy could not reach the Rails app on port 3000. In the confirmed
incident, PostgreSQL and Redis were running, but the locally built app
containers were missing or not recreated:

- `web`
- `streaming`
- `sidekiq`

The app images are built locally by Compose (`highlander-mastodon:web`,
`highlander-mastodon:streaming`, and `highlander-mastodon:sidekiq`). They exist
only on the Elestio VM unless pushed to a registry.

Elestio support identified the failure sequence as:

1. Watchtower updates a managed image such as `postgres:14-alpine`.
2. Watchtower stops and removes dependent containers such as `web`, `streaming`,
   and `sidekiq` so it can recreate the affected dependency tree.
3. Elestio maintenance runs `docker image prune -a -f`.
4. Because the app containers have been removed, their locally built images are
   no longer referenced by running containers, so `prune -a` deletes them.
5. Watchtower tries to recreate the app containers, but the images no longer
   exist, producing errors like `No such image: highlander-mastodon:web`.
6. The reverse proxy keeps forwarding traffic to port 3000, but no healthy
   `web` container is listening, so users see 502 responses.

For locally built images, Watchtower cannot query a registry to determine
staleness. That check can fail without aborting the update run, so Watchtower
may still remove linked containers while recreating an updated dependency.

`restart: always` cannot recover from this state because the affected containers
were removed and the images needed to recreate them were deleted.

### Prevention

The production Compose file marks the locally built app containers as excluded
from Watchtower. This is a container label, not an image label:

```yaml
labels:
  - com.centurylinklabs.watchtower.enable=false
```

Keep that label on `web`, `streaming`, and `sidekiq`. Updates to those services
come from the application deployment pipeline, not from Watchtower.

On the Elestio VM, change `/opt/maintenance.sh` so image cleanup removes only
dangling images:

```shell
docker image prune -f
```

Do not use this command in maintenance:

```shell
docker image prune -a -f
```

The `-a` flag removes every unused image, including locally built app images
when their containers have been stopped or removed.

This maintenance script is VM-local and is not controlled by this repository.
Elestio support confirmed that `/opt/maintenance.sh` is not regenerated on the
current VM, so local edits should survive normal platform automation. If the
service is cloned or moved to another region, the new VM may get the default
script and this change must be reapplied. After Elestio platform changes,
verify the active cleanup command on the VM:

```shell
grep -n 'docker image prune' /opt/maintenance.sh
```

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
missing, check whether the local app image tags still exist:

```shell
docker image ls 'highlander-mastodon'
```

The expected tags are:

```text
highlander-mastodon   web
highlander-mastodon   streaming
highlander-mastodon   sidekiq
```

If the tags are missing, recreate the stack from Compose and rebuild the app
images:

```shell
docker compose down
docker compose up -d --build
```

After applying or changing the Watchtower labels, recreate the app containers so
Docker applies the labels:

```shell
docker compose up -d --no-deps --force-recreate web streaming sidekiq
```

Verify the label on each app container:

```shell
docker inspect highlander-mastodon-web-1 \
  --format '{{ index .Config.Labels "com.centurylinklabs.watchtower.enable" }}'
docker inspect highlander-mastodon-streaming-1 \
  --format '{{ index .Config.Labels "com.centurylinklabs.watchtower.enable" }}'
docker inspect highlander-mastodon-sidekiq-1 \
  --format '{{ index .Config.Labels "com.centurylinklabs.watchtower.enable" }}'
```

Each command should print `false`.

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
