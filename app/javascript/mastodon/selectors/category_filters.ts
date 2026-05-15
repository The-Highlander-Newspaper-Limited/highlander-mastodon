import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import type { AccountCategory } from 'mastodon/models/account_categories';
import type { RootState } from 'mastodon/store/store';

const stateMap = (state: RootState) =>
  state as unknown as ImmutableMap<string, unknown>;

export const selectCategories = (state: RootState) =>
  stateMap(state).getIn(['categories', 'items']) as
    | ImmutableList<AccountCategory>
    | undefined;

export const selectCategoriesLoading = (state: RootState) =>
  stateMap(state).getIn(['categories', 'isLoading'], false) as boolean;

export const selectCategoriesLoaded = (state: RootState) =>
  stateMap(state).getIn(['categories', 'loaded'], false) as boolean;

export const selectHiddenCategories = (state: RootState) =>
  stateMap(state).getIn(['category_filters', 'items']) as
    | ImmutableMap<string, AccountCategory>
    | undefined;

export const selectFiltersLoading = (state: RootState) =>
  stateMap(state).getIn(['category_filters', 'isLoading'], false) as boolean;

export const selectFiltersLoaded = (state: RootState) =>
  stateMap(state).getIn(['category_filters', 'loaded'], false) as boolean;

export const selectFiltersSaving = (state: RootState) =>
  stateMap(state).getIn(['category_filters', 'saving']) as
    | ImmutableMap<string, boolean>
    | undefined;

export const selectNotificationCategories = (state: RootState) =>
  stateMap(state).getIn(['category_notifications', 'items']) as
    | ImmutableMap<string, AccountCategory>
    | undefined;

export const selectNotificationsLoading = (state: RootState) =>
  stateMap(state).getIn(
    ['category_notifications', 'isLoading'],
    false,
  ) as boolean;

export const selectNotificationsLoaded = (state: RootState) =>
  stateMap(state).getIn(['category_notifications', 'loaded'], false) as boolean;

export const selectNotificationsSaving = (state: RootState) =>
  stateMap(state).getIn(['category_notifications', 'saving']) as
    | ImmutableMap<string, boolean>
    | undefined;

export const selectPushSubscribed = (state: RootState) =>
  stateMap(state).getIn(
    ['push_notifications', 'isSubscribed'],
    false,
  ) as boolean;

export const selectPushStatusEnabled = (state: RootState) =>
  stateMap(state).getIn(
    ['push_notifications', 'alerts', 'status'],
    false,
  ) as boolean;

export const selectBrowserSupport = (state: RootState) =>
  stateMap(state).getIn(['notifications', 'browserSupport'], false) as boolean;

export const selectBrowserPermission = (state: RootState) =>
  stateMap(state).getIn(
    ['notifications', 'browserPermission'],
    'default',
  ) as string;
