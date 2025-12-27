import { Map as ImmutableMap } from 'immutable';

export const selectCategoryFilterContext = (state, { type }) => ({
  accounts: state.get('accounts'),
  hiddenCategories: state.getIn(['category_filters', 'items'], ImmutableMap()),
  timelineType: type,
});

export const shouldHideStatusByCategory = (
  status,
  statuses,
  accounts,
  hiddenCategories,
) => {
  if (!hiddenCategories || hiddenCategories.isEmpty() || !status) {
    return false;
  }

  const accountId = status.get('account');
  if (!accountId) return false;

  const authorAccountIds = [accountId];
  const reblogId = status.get('reblog');

  if (reblogId && statuses.get(reblogId)) {
    authorAccountIds.push(statuses.getIn([reblogId, 'account']));
  }

  const authorCategories = authorAccountIds.flatMap((id) => {
    const account = accounts.get(id);
    const accountCategories = account?.get('categories');

    if (!accountCategories || accountCategories.size === 0) {
      return [];
    }

    return accountCategories
      .map((category) => category.get('id') || category.get('name'))
      .filter(Boolean)
      .toArray();
  });

  return (
    authorCategories.length > 0 &&
    authorCategories.every((categoryId) =>
      hiddenCategories.has(categoryId),
    )
  );
};
