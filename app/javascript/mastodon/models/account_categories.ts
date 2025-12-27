import type { RecordOf } from 'immutable';
import { List as ImmutableList, Record as ImmutableRecord } from 'immutable';

import type { ApiAccountCategoryJSON } from '@/mastodon/api_types/account_categories';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';

export type AccountCategoryShape = ApiAccountCategoryJSON;
export type AccountCategory = RecordOf<AccountCategoryShape>;

export const AccountCategoryFactory = ImmutableRecord<AccountCategoryShape>({
  id: '',
  name: '',
  mandatory_for_readers: false,
});

const mapCategory = ({
  id,
  name,
  mandatory_for_readers,
}: ApiAccountCategoryJSON) =>
  AccountCategoryFactory({ id, name, mandatory_for_readers });

export function mapCategoriesFromJSON(
  serverJSON: Pick<ApiAccountJSON, 'categories'>,
) {
  const categories = serverJSON.categories ?? [];

  return ImmutableList<AccountCategory>(categories.map(mapCategory));
}

export function mapCategoryFromJSON(category: ApiAccountCategoryJSON) {
  return AccountCategoryFactory(category);
}
