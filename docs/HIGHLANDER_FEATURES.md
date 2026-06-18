# Highlander Features

This document covers Highlander-specific behavior that maintainers should
understand before changing feeds, roles, onboarding, account administration, or
category APIs. General setup, deployment, and operational guidance mostly
follows upstream Mastodon and is linked from the root README.

## Product behavior

- The home feed is an all-reader feed, not only a follow graph feed. Public
  statuses are fanned out to active readers, and home feed regeneration pulls
  from all recently active, unsuspended, unsilenced posting accounts.
- Highlander is operated as an unfederated app and does not use Mastodon
  federation or ActivityPub-facing network behavior.
- Highlander avoids Trends and algorithmic discovery feeds. Reading surfaces
  should stay explicit and local: home feed delivery, category filters, and
  direct navigation rather than ranked discovery.
- Highlander is an installable PWA, with browser install guidance and
  production-mode service worker behavior.
- Accounts can be assigned one or more content categories. Category badges are
  exposed on account JSON and shown in selected status views.
- Readers can hide optional categories from the home feed.
- Readers can enable push notifications for selected categories.
- The fork adds a `Poster` role, invitation role assignment, posting action
  permissions, and a `manage_categories` permission.
- The posting and preferences UI is simplified around Highlander's public local
  reading model.
- Annual report generation is disabled by no-op worker behavior.

## Roles and permissions

The fork defines a `Poster` role in `config/roles.yml`. The role can create,
reply to, reblog, and favourite statuses. It does not receive administration
permissions.

The fork also adds the `manage_categories` permission to `UserRole::FLAGS`.
Admins with this permission can manage the category taxonomy from the admin UI.
The admin navigation entry is only shown when the current user can
`manage_categories`.

Posting and interaction actions are also role-gated. `StatusPolicy` checks
`create_statuses`, `reply_to_statuses`, `reblog_statuses`, and `fav_statuses`
before allowing create, reply, boost, and favourite behavior. Frontend action
controls and navigation entries use matching permission flags so unavailable
actions are hidden or disabled for users whose role does not include them.

Invites can carry a role. The invite form rejects role assignments that would
elevate above the inviter's own role, and registration assigns the invite role to
the newly-created user when present.

When a user is created with the `Poster` role, or later changes to that role,
`User::CategoryAssignment` assigns the user's account to the seeded
`New Poster` category when that category exists.

Accounts created for users with a non-`Everyone` role default to discoverable
and indexable profiles. Accounts created without a specific role remain
undiscoverable by default.

Related files:

- `config/roles.yml`
- `app/models/user_role.rb`
- `app/policies/status_policy.rb`
- `app/controllers/api/v1/statuses_controller.rb`
- `app/javascript/mastodon/permissions.ts`
- `app/models/invite.rb`
- `app/controllers/admin/invites_controller.rb`
- `app/controllers/auth/registrations_controller.rb`
- `app/views/admin/invites/`
- `app/models/concerns/account/default_discoverability.rb`
- `app/models/concerns/user/category_assignment.rb`
- `db/seeds/06_categories.rb`
- `config/navigation.rb`

## Categories

Categories are stored in the `categories` table and joined to accounts through
`account_categories`. Category names are unique. Categories sort with mandatory
categories first, then by name.

A category can be marked `mandatory_for_readers`. Mandatory categories are
always visible to readers and cannot be hidden through category filters.

Admins can:

- create, edit, and delete categories at `/admin/categories`;
- assign categories to accounts from the account admin view;
- filter admin account search by categories.

Category assignment is account-based. A status inherits category display and
feed filtering behavior from the status author's account. For boosts, feed
filtering considers both the boosting account and the boosted account.

Related files:

- `app/models/category.rb`
- `app/models/account_category.rb`
- `app/controllers/admin/categories_controller.rb`
- `app/controllers/admin/accounts/categories_controller.rb`
- `app/views/admin/categories/`
- `app/views/admin/accounts/categories/`
- `app/helpers/categories_helper.rb`

## Home feed behavior

`FeedManager` prepends `Custom::CategoryBasedFeed`.

The fork changes three important home feed paths:

- `populate_home` fills a reader's home feed from all source accounts with
  recent public statuses instead of only followed accounts.
- `merge_into_home` only merges public statuses, which avoids private status
  leakage into the all-reader home feed.
- `filter_from_home` applies category filters after upstream Mastodon filters.

`FanOutOnWriteService` prepends `Custom::AllReadersDelivery`. For public
statuses, it enqueues `FeedInsertWorker` jobs for all recently signed-in
accounts. Non-public statuses use upstream follower fan-out behavior.

Category filtering is opt-out:

- all categories are visible by default;
- creating an `AccountCategoryFilter` hides a category from that reader's home
  feed;
- destroying the filter shows the category again;
- changing filters regenerates the reader's home feed.

Current compatibility note: statuses whose authors have no categories are not
hidden by category filters. The code marks this as temporary until all statuses
or authors are forced to have categories.

Related files:

- `app/lib/feed_manager.rb`
- `app/lib/custom/category_based_feed.rb`
- `app/services/fan_out_on_write_service.rb`
- `app/services/custom/all_readers_delivery.rb`
- `app/models/account_category_filter.rb`

## Category notifications

`FeedInsertWorker` prepends `Custom::CategoryNotifications`.

Category notifications are evaluated for home timeline inserts only. They do
not fire for boosts, replies to other accounts, or statuses filtered out of the
reader's home feed. Per-follow notifications still take priority.
If the status is eligible for home notifications and is not filtered out,
a reader who enabled notifications for any category assigned to the status author
receives a notification.

The push subscription controller enables the `status` push alert when the
current account has any category notification settings. This lets category
notification preferences use the existing status push channel.

Related files:

- `app/workers/feed_insert_worker.rb`
- `app/workers/custom/category_notifications.rb`
- `app/models/account_category_notification.rb`
- `app/controllers/api/web/push_subscriptions_controller.rb`

## API endpoints

The fork adds these authenticated REST endpoints under `/api/v1`.

### `GET /api/v1/categories`

Returns all categories in display order.

Required OAuth scope: `read` or `read:accounts`.

Response items contain:

- `id`
- `name`
- `mandatory_for_readers`

### `GET /api/v1/category_filters`

Returns the current account's hidden category filters.

Required OAuth scope: `read` or `read:accounts`.

### `POST /api/v1/category_filters/:id`

Hides category `:id` for the current account and regenerates the home feed.
Mandatory categories return `422 Unprocessable Entity`.

Required OAuth scope: `write` or `write:accounts`.

### `DELETE /api/v1/category_filters/:id`

Removes the current account's filter for category `:id` and regenerates the
home feed.

Required OAuth scope: `write` or `write:accounts`.

### `GET /api/v1/category_notifications`

Returns category notification settings for the current account.

Required OAuth scope: `read` or `read:accounts`.

### `POST /api/v1/category_notifications/:id`

Enables category notifications for category `:id`.

Required OAuth scope: `write` or `write:accounts`.

### `DELETE /api/v1/category_notifications/:id`

Disables category notifications for category `:id`.

Required OAuth scope: `write` or `write:accounts`.

Related files:

- `config/routes/api.rb`
- `app/controllers/api/v1/categories_controller.rb`
- `app/controllers/api/v1/category_filters_controller.rb`
- `app/controllers/api/v1/category_notifications_controller.rb`
- `app/serializers/rest/custom/account_categories.rb`
- `app/serializers/rest/category_filter_serializer.rb`
- `app/serializers/rest/category_notification_serializer.rb`

## Frontend behavior

The home timeline renders a category filter panel before the timeline list.
The panel fetches all categories, the current account's hidden category
filters, and the current account's category notification settings.

Reader-facing behavior:

- toggling a category off creates a category filter;
- toggling it on deletes that category filter;
- mandatory categories render as always-on;
- notification controls create or delete category notification settings;
- client-side timeline rendering also hides matching statuses while API state
  and feed regeneration catch up.

Category badges are shown on statuses in timeline feeds, detailed status views,
embedded notification statuses, and admin status partials. The notification
email templates also include category output, but Highlander does not currently
use status notification emails in the normal user-facing flow.

Related files:

- `app/javascript/mastodon/features/home_timeline/components/category_filters.tsx`
- `app/javascript/mastodon/features/ui/util/status_list_category_filters.js`
- `app/javascript/mastodon/components/status.jsx`
- `app/javascript/mastodon/features/status/components/detailed_status.tsx`
- `app/javascript/mastodon/features/notifications_v2/components/embedded_status.tsx`
- `app/javascript/mastodon/components/category_badges.tsx`
- `app/javascript/mastodon/reducers/categories.ts`
- `app/javascript/mastodon/reducers/category_filters.ts`
- `app/javascript/mastodon/reducers/category_notifications.ts`
- `app/views/admin/shared/_status.html.haml`
- `app/views/admin/trends/statuses/_status.html.haml`
- `app/views/notification_mailer/_status.html.haml`
- `app/views/notification_mailer/_status.text.erb`
- `app/javascript/styles/mastodon/categories.scss`

## Posting UI

Highlander narrows post visibility to `public` and `unlisted`, shown as
`Public` and `Quiet public` in the compose UI. Private mentions and follower-only
posting are not selectable in the normal compose flow. The visibility modal and
posting defaults page use the same selectable visibility list.

Related files:

- `app/models/concerns/status/visibility.rb`
- `app/javascript/mastodon/features/compose/components/privacy_dropdown.jsx`
- `app/javascript/mastodon/features/compose/components/visibility_button.tsx`
- `app/javascript/mastodon/features/ui/components/visibility_modal.tsx`
- `app/views/settings/preferences/posting_defaults/show.html.haml`

## Navigation and guest flow

Highlander removes navigation entries for product areas that are not part of the
local reading model:

- lists and followed hashtags are removed from the main navigation;
- signed-in users no longer get Live Feed links in the drawer or main
  navigation, while guest-facing public feed pages are still titled `Live feed`;
- signing in from `/public`, `/public/local`, or `/public/remote` redirects to
  `/home` instead of returning the user to those guest feed pages.

Keyboard shortcuts for hidden UI and unavailable actions are removed too.

Related files:

- `app/javascript/mastodon/features/navigation_panel/index.tsx`
- `app/javascript/mastodon/features/compose/index.tsx`
- `app/javascript/mastodon/features/firehose/index.jsx`
- `app/controllers/auth/sessions_controller.rb`
- `app/javascript/mastodon/permissions.ts`
- `app/javascript/mastodon/features/keyboard_shortcuts/index.jsx`

## Preference UI

Highlander keeps the preferences pages focused on settings that still apply:

- trend-related preference controls are shown only when trends are
  enabled (user-level trend display and trend email settings default to off);
- boost confirmation and quick-boost controls are removed from appearance
  preferences;
- filter-language preferences are removed from the other-preferences page;
- email notification preferences expose follow and follow-request emails for
  normal users, while status notification email settings remain backend-only.

Related files:

- `app/views/settings/preferences/appearance/show.html.haml`
- `app/views/settings/preferences/other/show.html.haml`
- `app/views/settings/preferences/notifications/show.html.haml`
- `app/models/user_settings.rb`

## Limits and diagnostics

Highlander raises the local status length limit to 1,000 characters and the
account display-name limit to 50 characters.

The fork also adds targeted home-feed lifecycle logging around feed cleanup,
feed regeneration enqueue/start/finish/failure, skipped regeneration, and empty
initial home timeline responses. These logs are meant to make all-reader feed
delivery and regeneration issues easier to diagnose.

Related files:

- `app/validators/status_length_validator.rb`
- `app/models/account.rb`
- `app/lib/custom/feed_lifecycle_logging.rb`
- `config/initializers/custom_feed_lifecycle_logging.rb`

## Onboarding and branding

The fork includes Highlander-specific onboarding copy and images. The public
about guide and welcome email both explain category selection, notification
setup, and installing Highlander as a PWA.

After profile setup, onboarding skips the follow-recommendations step.

The PWA install prompt handles Android browser install events and shows iOS
Safari install instructions. The manifest uses Highlander app naming and
standalone launch behavior.

Branding changes also cover app logos, mailer header/footer assets,
account-related emails, server/footer links, and English locale copy.

Related files:

- `app/javascript/mastodon/features/about/components/highlander_guide.tsx`
- `app/javascript/mastodon/features/onboarding/profile.tsx`
- `app/javascript/mastodon/components/pwa_install_prompt.tsx`
- `app/serializers/manifest_serializer.rb`
- `app/javascript/mastodon/service_worker/`
- `app/views/user_mailer/welcome.html.haml`
- `app/views/user_mailer/welcome.text.erb`
- `app/views/layouts/mailer.html.haml`
- `app/views/user_mailer/`
- `app/views/admin/settings/about/show.html.haml`
- `app/javascript/mastodon/features/ui/components/link_footer.tsx`
- `app/javascript/images/highlander/onboarding/`
- `app/javascript/images/logo-symbol-wordmark.svg`
- `app/javascript/images/mailer-new/`
- `config/locales/en.yml`

## Annual report behavior

Annual report generation is intentionally disabled in this fork. The
`GenerateAnnualReportWorker` is a no-op so it does not create
`GeneratedAnnualReport` records or enqueue annual report mailers.

Related files:

- `app/workers/generate_annual_report_worker.rb`
- `spec/workers/generate_annual_report_worker_spec.rb`

## Development and verification

For local setup, use `docs/DEVELOPMENT.md`.

Focused specs for fork behavior include:

- `spec/lib/custom/category_based_feed_spec.rb`
- `spec/workers/custom/category_notifications_spec.rb`
- `spec/requests/api/v1/categories_spec.rb`
- `spec/requests/api/v1/category_filters_spec.rb`
- `spec/requests/api/v1/category_notifications_spec.rb`
- `spec/requests/admin/categories_spec.rb`
- `spec/requests/admin/accounts/categories_spec.rb`
- `spec/models/category_spec.rb`
- `spec/models/account_category_filter_spec.rb`
- `spec/models/account_category_notification_spec.rb`
- `spec/models/user/category_assignment_spec.rb`
- `spec/models/user_role_custom_spec.rb`
- `spec/models/invite_custom_spec.rb`
- `spec/policies/status_policy_custom_spec.rb`
- `spec/requests/admin/invites_custom_spec.rb`
- `spec/requests/api/v1/statuses_custom_spec.rb`
- `spec/models/concerns/account/default_discoverability_spec.rb`
- `spec/models/user/home_feed_generation_spec.rb`

Run focused Ruby specs with:

```shell
bin/rspec spec/lib/custom/category_based_feed_spec.rb \
  spec/workers/custom/category_notifications_spec.rb \
  spec/requests/api/v1/categories_spec.rb \
  spec/requests/api/v1/category_filters_spec.rb \
  spec/requests/api/v1/category_notifications_spec.rb \
  spec/requests/admin/categories_spec.rb \
  spec/requests/admin/accounts/categories_spec.rb
```

Run frontend checks for category UI changes with the project's existing
JavaScript test and lint commands. The category badge component has focused
coverage in `app/javascript/mastodon/components/__tests__/category_badges.tsx`.
