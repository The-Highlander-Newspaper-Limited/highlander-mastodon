import type { ApiAccountCategoryJSON } from '@/mastodon/api_types/account_categories';

export interface ApiCategoryNotificationJSON {
  id: string;
  category: ApiAccountCategoryJSON;
}
