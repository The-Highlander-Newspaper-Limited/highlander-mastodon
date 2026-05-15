import { apiFetchCategories } from 'mastodon/api/categories';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

export const fetchCategories = createDataLoadingThunk(
  'categories/fetch',
  () => apiFetchCategories(),
  { useLoadingBar: false },
);
