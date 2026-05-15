import { apiRequestGet } from 'mastodon/api';
import type { ApiAccountCategoryJSON } from 'mastodon/api_types/account_categories';

export const apiFetchCategories = () =>
  apiRequestGet<ApiAccountCategoryJSON[]>('v1/categories');
