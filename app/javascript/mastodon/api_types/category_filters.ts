import type { ApiAccountCategoryJSON } from '@/mastodon/api_types/account_categories';

export interface ApiCategoryFilterJSON {
  id: string;
  created_at: string;
  category: ApiAccountCategoryJSON;
}
