import { apiRequestDelete, apiRequestGet, apiRequestPost } from 'mastodon/api';
import type { ApiCategoryFilterJSON } from 'mastodon/api_types/category_filters';

export const apiFetchCategoryFilters = () =>
  apiRequestGet<ApiCategoryFilterJSON[]>('v1/category_filters');

export const apiAddCategoryFilter = (categoryId: string) =>
  apiRequestPost<ApiCategoryFilterJSON>('v1/category_filters', {
    id: categoryId,
  });

export const apiRemoveCategoryFilter = (categoryId: string) =>
  apiRequestDelete(`v1/category_filters/${categoryId}`);
