import { createReducer } from '@reduxjs/toolkit';
import type { RecordOf } from 'immutable';
import { Map as ImmutableMap, Record as ImmutableRecord } from 'immutable';

import type {
  AccountCategory,
  AccountCategoryShape,
} from '@/mastodon/models/account_categories';
import { AccountCategoryFactory } from '@/mastodon/models/account_categories';
import {
  addCategoryNotification,
  fetchCategoryNotifications,
  removeCategoryNotification,
} from 'mastodon/actions/category_notifications';
import type { ApiCategoryNotificationJSON } from 'mastodon/api_types/category_notifications';

type CategoryMap = ImmutableMap<string, AccountCategory>;
type SavingMap = ImmutableMap<string, boolean>;

interface CategoryNotificationsState {
  isLoading: boolean;
  loaded: boolean;
  items: CategoryMap;
  saving: SavingMap;
}

const CategoryNotificationsStateRecord =
  ImmutableRecord<CategoryNotificationsState>({
    isLoading: false,
    loaded: false,
    items: ImmutableMap<string, AccountCategory>(),
    saving: ImmutableMap<string, boolean>(),
  });

type State = RecordOf<CategoryNotificationsState>;

const initialState: State = CategoryNotificationsStateRecord();

const normalizeCategory = (
  categoryJSON: ApiCategoryNotificationJSON['category'],
): AccountCategory => {
  return AccountCategoryFactory({
    id: categoryJSON.id,
    name: categoryJSON.name,
    mandatory_for_readers: categoryJSON.mandatory_for_readers,
  } as AccountCategoryShape);
};

const getCategoryId = (category: AccountCategory) =>
  category.get('id') || category.get('name');

const setSaving = (state: State, categoryId: string, isSaving: boolean) =>
  state.setIn(['saving', categoryId], isSaving);

const storeCategories = (
  state: State,
  categoryNotifications: ApiCategoryNotificationJSON[],
) => {
  let categories = ImmutableMap<string, AccountCategory>();

  categoryNotifications.forEach((notification) => {
    const category = normalizeCategory(notification.category);
    const categoryId = getCategoryId(category);

    categories = categories.set(categoryId, category);
  });

  return state.set('items', categories);
};

export const categoryNotificationsReducer = createReducer(
  initialState,
  (builder) => {
    builder
      .addCase(fetchCategoryNotifications.pending, (state) => {
        return state.set('isLoading', true);
      })
      .addCase(fetchCategoryNotifications.rejected, (state) => {
        return state.set('isLoading', false);
      })
      .addCase(fetchCategoryNotifications.fulfilled, (state, action) => {
        return storeCategories(
          state.set('isLoading', false).set('loaded', true),
          action.payload,
        );
      })
      .addCase(addCategoryNotification.pending, (state, action) => {
        const categoryId = action.meta.arg.categoryId;
        return setSaving(state, categoryId, true);
      })
      .addCase(addCategoryNotification.rejected, (state, action) => {
        const categoryId = action.meta.arg.categoryId;
        return setSaving(state, categoryId, false);
      })
      .addCase(addCategoryNotification.fulfilled, (state, action) => {
        const category = normalizeCategory(action.payload.category);
        const categoryId = getCategoryId(category);

        return state
          .setIn(['items', categoryId], category)
          .setIn(['saving', categoryId], false);
      })
      .addCase(removeCategoryNotification.pending, (state, action) => {
        const categoryId = action.meta.arg.categoryId;
        return setSaving(state, categoryId, true);
      })
      .addCase(removeCategoryNotification.rejected, (state, action) => {
        const categoryId = action.meta.arg.categoryId;
        return setSaving(state, categoryId, false);
      })
      .addCase(removeCategoryNotification.fulfilled, (state, action) => {
        const categoryId = action.payload;

        return state
          .setIn(['saving', categoryId], false)
          .update('items', (items) => items.delete(categoryId));
      });
  },
);
