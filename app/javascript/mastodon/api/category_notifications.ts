import { apiRequestDelete, apiRequestGet, apiRequestPost } from 'mastodon/api';
import type { ApiCategoryNotificationJSON } from 'mastodon/api_types/category_notifications';

export const apiFetchCategoryNotifications = () =>
  apiRequestGet<ApiCategoryNotificationJSON[]>('v1/category_notifications');

export const apiAddCategoryNotification = (categoryId: string) =>
  apiRequestPost<ApiCategoryNotificationJSON>('v1/category_notifications', {
    id: categoryId,
  });

export const apiRemoveCategoryNotification = (categoryId: string) =>
  apiRequestDelete(`v1/category_notifications/${categoryId}`);
