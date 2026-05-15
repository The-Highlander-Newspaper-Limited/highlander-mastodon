import { createReducer } from '@reduxjs/toolkit';
import type { RecordOf } from 'immutable';
import { List as ImmutableList, Record as ImmutableRecord } from 'immutable';

import type { AccountCategory } from '@/mastodon/models/account_categories';
import { mapCategoryFromJSON } from '@/mastodon/models/account_categories';
import { fetchCategories } from 'mastodon/actions/categories';

interface CategoriesState {
  isLoading: boolean;
  loaded: boolean;
  items: ImmutableList<AccountCategory>;
}

const CategoriesStateRecord = ImmutableRecord<CategoriesState>({
  isLoading: false,
  loaded: false,
  items: ImmutableList<AccountCategory>(),
});

type State = RecordOf<CategoriesState>;

const initialState: State = CategoriesStateRecord();

export const categoriesReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(fetchCategories.pending, (state) => {
      return state.set('isLoading', true);
    })
    .addCase(fetchCategories.rejected, (state) => {
      return state.set('isLoading', false);
    })
    .addCase(fetchCategories.fulfilled, (state, action) => {
      return state
        .set('isLoading', false)
        .set('loaded', true)
        .set(
          'items',
          ImmutableList<AccountCategory>(
            action.payload.map(mapCategoryFromJSON),
          ),
        );
    });
});
