import type { RecordOf } from 'immutable';
import { List as ImmutableList, Record as ImmutableRecord } from 'immutable';

import type { ApiAccountJSON } from 'mastodon/api_types/accounts';

export interface ApiAccountCategoryJSON {
  name: string;
  mandatory_for_readers: boolean;
}

export type AccountCategoryShape = ApiAccountCategoryJSON;
export type AccountCategory = RecordOf<AccountCategoryShape>;

export const AccountCategoryFactory = ImmutableRecord<AccountCategoryShape>({
  name: '',
  mandatory_for_readers: false,
});

export function mapCategoriesFromJSON(
  serverJSON: Pick<ApiAccountJSON, 'categories'>,
) {
  const list = serverJSON.categories ?? [];
  return ImmutableList(
    list.map((category) => AccountCategoryFactory(category)),
  );
}
