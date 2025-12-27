import { createReducer } from '@reduxjs/toolkit';
import type { RecordOf } from 'immutable';
import { Map as ImmutableMap, Record as ImmutableRecord } from 'immutable';

import type {
  AccountCategory,
  AccountCategoryShape,
} from '@/mastodon/models/account_categories';
import { AccountCategoryFactory } from '@/mastodon/models/account_categories';
import {
  addCategoryFilter,
  fetchCategoryFilters,
  removeCategoryFilter,
} from 'mastodon/actions/category_filters';
import type { ApiCategoryFilterJSON } from 'mastodon/api_types/category_filters';

type CategoryMap = ImmutableMap<string, AccountCategory>;
type SavingMap = ImmutableMap<string, boolean>;

interface CategoryFiltersState {
  isLoading: boolean;
  loaded: boolean;
  items: CategoryMap;
  saving: SavingMap;
}

const CategoryFiltersStateRecord = ImmutableRecord<CategoryFiltersState>({
  isLoading: false,
  loaded: false,
  items: ImmutableMap<string, AccountCategory>(),
  saving: ImmutableMap<string, boolean>(),
});

type State = RecordOf<CategoryFiltersState>;

const initialState: State = CategoryFiltersStateRecord();

const normalizeCategory = (
  categoryJSON: ApiCategoryFilterJSON['category'],
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
  categoryFilters: ApiCategoryFilterJSON[],
) => {
  let categories = ImmutableMap<string, AccountCategory>();

  categoryFilters.forEach((filter) => {
    const category = normalizeCategory(filter.category);
    const categoryId = getCategoryId(category);

    categories = categories.set(categoryId, category);
  });

  return state.set('items', categories);
};

export const categoryFiltersReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(fetchCategoryFilters.pending, (state) => {
      return state.set('isLoading', true);
    })
    .addCase(fetchCategoryFilters.rejected, (state) => {
      return state.set('isLoading', false);
    })
    .addCase(fetchCategoryFilters.fulfilled, (state, action) => {
      return storeCategories(
        state.set('isLoading', false).set('loaded', true),
        action.payload,
      );
    })
    .addCase(addCategoryFilter.pending, (state, action) => {
      const categoryId = action.meta.arg.categoryId;
      return setSaving(state, categoryId, true);
    })
    .addCase(addCategoryFilter.rejected, (state, action) => {
      const categoryId = action.meta.arg.categoryId;
      return setSaving(state, categoryId, false);
    })
    .addCase(addCategoryFilter.fulfilled, (state, action) => {
      const category = normalizeCategory(action.payload.category);
      const categoryId = getCategoryId(category);

      return state
        .setIn(['items', categoryId], category)
        .setIn(['saving', categoryId], false);
    })
    .addCase(removeCategoryFilter.pending, (state, action) => {
      const categoryId = action.meta.arg.categoryId;
      return setSaving(state, categoryId, true);
    })
    .addCase(removeCategoryFilter.rejected, (state, action) => {
      const categoryId = action.meta.arg.categoryId;
      return setSaving(state, categoryId, false);
    })
    .addCase(removeCategoryFilter.fulfilled, (state, action) => {
      const categoryId = action.payload;

      return state
        .setIn(['saving', categoryId], false)
        .update('items', (items) => items.delete(categoryId));
    });
});
