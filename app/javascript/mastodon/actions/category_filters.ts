import {
  apiAddCategoryFilter,
  apiFetchCategoryFilters,
  apiRemoveCategoryFilter,
} from 'mastodon/api/category_filters';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

interface CategoryFilterArg {
  categoryId: string;
  [key: string]: unknown;
}

export const fetchCategoryFilters = createDataLoadingThunk(
  'categoryFilters/fetch',
  () => apiFetchCategoryFilters(),
  { useLoadingBar: false },
);

export const addCategoryFilter = createDataLoadingThunk(
  'categoryFilters/add',
  ({ categoryId }: CategoryFilterArg) => apiAddCategoryFilter(categoryId),
  { useLoadingBar: false },
);

export const removeCategoryFilter = createDataLoadingThunk(
  'categoryFilters/remove',
  async ({ categoryId }: CategoryFilterArg) => {
    await apiRemoveCategoryFilter(categoryId);
    return categoryId;
  },
  { useLoadingBar: false },
);
