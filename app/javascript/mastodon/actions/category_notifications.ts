import {
  apiAddCategoryNotification,
  apiFetchCategoryNotifications,
  apiRemoveCategoryNotification,
} from 'mastodon/api/category_notifications';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

interface CategoryNotificationArg {
  categoryId: string;
  [key: string]: unknown;
}

export const fetchCategoryNotifications = createDataLoadingThunk(
  'categoryNotifications/fetch',
  () => apiFetchCategoryNotifications(),
  { useLoadingBar: false },
);

export const addCategoryNotification = createDataLoadingThunk(
  'categoryNotifications/add',
  ({ categoryId }: CategoryNotificationArg) =>
    apiAddCategoryNotification(categoryId),
  { useLoadingBar: false },
);

export const removeCategoryNotification = createDataLoadingThunk(
  'categoryNotifications/remove',
  async ({ categoryId }: CategoryNotificationArg) => {
    await apiRemoveCategoryNotification(categoryId);
    return categoryId;
  },
  { useLoadingBar: false },
);
