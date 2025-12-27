import type { ChangeEvent } from 'react';
import { useCallback, useEffect, useMemo, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import Toggle from 'react-toggle';

import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import ExpandMoreIcon from '@/material-icons/400-24px/expand_more.svg?react';
import {
  addCategoryFilter,
  fetchCategoryFilters,
  removeCategoryFilter,
} from 'mastodon/actions/category_filters';
import { CircularProgress } from 'mastodon/components/circular_progress';
import { Icon } from 'mastodon/components/icon';
import { me } from 'mastodon/initial_state';
import type { Account } from 'mastodon/models/account';
import type { AccountCategory } from 'mastodon/models/account_categories';
import type { Status } from 'mastodon/models/status';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from 'mastodon/store';
import type { RootState } from 'mastodon/store/store';

const messages = defineMessages({
  title: {
    id: 'home.category_filters.title',
    defaultMessage: 'Feed categories',
  },
  subtitle: {
    id: 'home.category_filters.subtitle',
    defaultMessage: 'Choose which categories stay in your home feed',
  },
  show: {
    id: 'home.category_filters.show',
    defaultMessage: 'Show category filters',
  },
  hide: {
    id: 'home.category_filters.hide',
    defaultMessage: 'Hide category filters',
  },
  empty: {
    id: 'home.category_filters.empty',
    defaultMessage:
      'Categories will appear here once the accounts you follow are categorized.',
  },
  loading: {
    id: 'home.category_filters.loading',
    defaultMessage: 'Loading categories...',
  },
  on: {
    id: 'home.category_filters.on',
    defaultMessage: 'Showing',
  },
  off: {
    id: 'home.category_filters.off',
    defaultMessage: 'Hidden',
  },
  toggleLabel: {
    id: 'home.category_filters.toggle',
    defaultMessage: 'Toggle {category} category',
  },
});

const selectHomeCategories = createAppSelector(
  [
    (state: RootState) =>
      (state as unknown as ImmutableMap<string, unknown>).getIn([
        'timelines',
        'home',
        'items',
      ]) as ImmutableList<string | null> | undefined,
    (state: RootState) =>
      (state as unknown as ImmutableMap<string, unknown>).get('statuses') as
        | ImmutableMap<string, Status>
        | undefined,
    (state: RootState) =>
      (state as unknown as ImmutableMap<string, unknown>).get('accounts') as
        | ImmutableMap<string, Account>
        | undefined,
    (state: RootState) =>
      (state as unknown as ImmutableMap<string, unknown>).getIn([
        'category_filters',
        'items',
      ]) as ImmutableMap<string, AccountCategory> | undefined,
  ],
  (statusIds, statuses, accounts, hiddenCategories) => {
    const categories = new Map<string, AccountCategory>();

    hiddenCategories?.forEach((category, categoryId) => {
      categories.set(categoryId, category);
    });

    statusIds?.forEach((statusId) => {
      if (!statusId) return;

      const status = statuses?.get(statusId);
      if (!status) return;

      const accountId = status.get('account') as string | undefined;
      const reblogId = status.get('reblog') as string | undefined;
      const account = accountId ? accounts?.get(accountId) : null;
      const reblogAccount =
        reblogId && statuses
          ? accounts?.get(statuses.getIn([reblogId, 'account']) as string)
          : null;

      [account, reblogAccount].filter(Boolean).forEach((statusAccount) => {
        const statusCategories = statusAccount?.get('categories');

        statusCategories?.forEach((category) => {
          const categoryId = getCategoryId(category);
          if (!categoryId) return;

          if (!categories.has(categoryId)) {
            categories.set(categoryId, category);
          }
        });
      });
    });

    return Array.from(categories.values()).sort((a, b) =>
      a.get('name').localeCompare(b.get('name')),
    );
  },
);

const getCategoryId = (category: AccountCategory) =>
  category.get('id') || category.get('name');

const selectHiddenCategories = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn([
    'category_filters',
    'items',
  ]) as ImmutableMap<string, AccountCategory> | undefined;

const selectIsLoading = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn(
    ['category_filters', 'isLoading'],
    false,
  ) as boolean;

const selectIsLoaded = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn(
    ['category_filters', 'loaded'],
    false,
  ) as boolean;

const selectSaving = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn([
    'category_filters',
    'saving',
  ]) as ImmutableMap<string, boolean> | undefined;

export const CategoryFilters: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const [expanded, setExpanded] = useState(true);

  const categories = useAppSelector(selectHomeCategories);
  const hiddenCategories = useAppSelector(selectHiddenCategories);
  const isLoading = useAppSelector(selectIsLoading);
  const isLoaded = useAppSelector(selectIsLoaded);
  const saving = useAppSelector(selectSaving);

  useEffect(() => {
    if (!isLoaded && me) {
      void dispatch(fetchCategoryFilters());
    }
  }, [dispatch, isLoaded]);

  const handleToggle = useCallback(
    (categoryId: string, checked: boolean) => {
      if (!checked) {
        void dispatch(addCategoryFilter({ categoryId }));
      } else {
        void dispatch(removeCategoryFilter({ categoryId }));
      }
    },
    [dispatch],
  );

  const handleToggleChange = useCallback(
    (categoryId: string) => (event: ChangeEvent<HTMLInputElement>) => {
      handleToggle(categoryId, event.target.checked);
    },
    [handleToggle],
  );

  const handleToggleExpanded = useCallback(() => {
    setExpanded((value) => !value);
  }, []);

  const renderBody = useMemo(() => {
    if ((!isLoaded || isLoading) && !categories.length) {
      return (
        <div className='home-category-filters__loading'>
          <CircularProgress size={24} strokeWidth={3} />
          <span>{intl.formatMessage(messages.loading)}</span>
        </div>
      );
    }

    if (!categories.length) {
      return (
        <p className='home-category-filters__empty'>
          <FormattedMessage {...messages.empty} />
        </p>
      );
    }

    const visibleCategories = categories.filter(
      (category) => !category.get('mandatory_for_readers'),
    );

    return (
      <div className='home-category-filters__list'>
        {visibleCategories.map((category) => {
          const categoryId = getCategoryId(category);
          const isHidden = hiddenCategories?.has(categoryId);
          const isSaving = saving?.get(categoryId);
          const inputId = `home-category-filter-${categoryId}`;

          return (
            <label
              key={categoryId}
              htmlFor={inputId}
              className='home-category-filters__item'
            >
              <Toggle
                id={inputId}
                checked={!isHidden}
                disabled={Boolean(isSaving)}
                onChange={handleToggleChange(categoryId)}
                aria-label={intl.formatMessage(messages.toggleLabel, {
                  category: category.get('name'),
                })}
              />

              <div className='home-category-filters__label'>
                <span className='home-category-filters__name'>
                  {category.get('name')}
                </span>

                <div className='home-category-filters__meta'>
                  <span className='home-category-filters__state'>
                    {isHidden ? (
                      <FormattedMessage {...messages.off} />
                    ) : (
                      <FormattedMessage {...messages.on} />
                    )}
                  </span>
                </div>
              </div>
            </label>
          );
        })}
      </div>
    );
  }, [
    categories,
    handleToggleChange,
    hiddenCategories,
    intl,
    isLoading,
    isLoaded,
    saving,
  ]);

  if (!me) return null;

  return (
    <div className='home-category-filters'>
      <button
        type='button'
        className='home-category-filters__header'
        onClick={handleToggleExpanded}
        aria-expanded={expanded}
      >
        <div className='home-category-filters__titles'>
          <span className='home-category-filters__title'>
            <FormattedMessage {...messages.title} />
          </span>
          <span className='home-category-filters__subtitle'>
            <FormattedMessage {...messages.subtitle} />
          </span>
        </div>

        <Icon
          id={expanded ? 'expand-more' : 'chevron-right'}
          icon={expanded ? ExpandMoreIcon : ChevronRightIcon}
        />

        <span className='sr-only'>
          <FormattedMessage {...(expanded ? messages.hide : messages.show)} />
        </span>
      </button>

      {expanded && renderBody}
    </div>
  );
};
