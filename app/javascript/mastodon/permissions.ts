export const PEMRISSION_VIEW_FEEDS = 0x0000000000100000;
export const PERMISSION_INVITE_USERS = 0x0000000000010000;
export const PERMISSION_MANAGE_USERS = 0x0000000000000400;
export const PERMISSION_MANAGE_TAXONOMIES = 0x0000000000000100;
export const PERMISSION_MANAGE_FEDERATION = 0x0000000000000020;

export const PERMISSION_MANAGE_REPORTS = 0x0000000000000010;
export const PERMISSION_VIEW_DASHBOARD = 0x0000000000000008;

// Posting/interaction permissions (mirror server-side UserRole FLAGS)
export const PERMISSION_CREATE_STATUSES = 0x0000000000200000; // 1 << 21
export const PERMISSION_REPLY_TO_STATUSES = 0x0000000000400000; // 1 << 22
export const PERMISSION_REBLOG_STATUSES = 0x0000000000800000; // 1 << 23
export const PERMISSION_FAV_STATUSES = 0x0000000001000000; // 1 << 24

// These helpers don't quite align with the names/categories in UserRole,
// but are likely "good enough" for the use cases at present.
//
// See: https://docs.joinmastodon.org/entities/Role/#permission-flags

export function canViewAdminDashboard(permissions: number) {
  return (
    (permissions & PERMISSION_VIEW_DASHBOARD) === PERMISSION_VIEW_DASHBOARD
  );
}

export function canManageReports(permissions: number) {
  return (
    (permissions & PERMISSION_MANAGE_REPORTS) === PERMISSION_MANAGE_REPORTS
  );
}

export const canViewFeed = (
  signedIn: boolean,
  permissions: number,
  setting: 'public' | 'authenticated' | 'disabled' | undefined,
) => {
  switch (setting) {
    case 'public':
      return true;
    case 'authenticated':
      return signedIn;
    case 'disabled':
    default:
      return (permissions & PEMRISSION_VIEW_FEEDS) === PEMRISSION_VIEW_FEEDS;
  }
};

export function canPost(permissions: number) {
  return (
    (permissions & PERMISSION_CREATE_STATUSES) === PERMISSION_CREATE_STATUSES
  );
}
export function canReply(permissions: number) {
  return (
    (permissions & PERMISSION_REPLY_TO_STATUSES) ===
    PERMISSION_REPLY_TO_STATUSES
  );
}
export function canReblog(permissions: number) {
  return (
    (permissions & PERMISSION_REBLOG_STATUSES) === PERMISSION_REBLOG_STATUSES
  );
}
export function canFavourite(permissions: number) {
  return (permissions & PERMISSION_FAV_STATUSES) === PERMISSION_FAV_STATUSES;
}
