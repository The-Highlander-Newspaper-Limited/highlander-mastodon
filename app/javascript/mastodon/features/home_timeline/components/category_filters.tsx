import type { ChangeEvent } from 'react';
import { useCallback, useEffect, useMemo, useState } from 'react';

import type { IntlShape } from 'react-intl';
import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import Toggle from 'react-toggle';

import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import ExpandMoreIcon from '@/material-icons/400-24px/expand_more.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications.svg?react';
import NotificationsActiveIcon from '@/material-icons/400-24px/notifications_active-fill.svg?react';
import {
  addCategoryFilter,
  fetchCategoryFilters,
  removeCategoryFilter,
} from 'mastodon/actions/category_filters';
import {
  addCategoryNotification,
  fetchCategoryNotifications,
  removeCategoryNotification,
} from 'mastodon/actions/category_notifications';
import { requestBrowserPermission } from 'mastodon/actions/notifications';
import {
  changeAlerts,
  register as registerPushNotifications,
} from 'mastodon/actions/push_notifications';
import { CircularProgress } from 'mastodon/components/circular_progress';
import { Icon } from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';
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
  pushEnable: {
    id: 'home.category_filters.push_enable',
    defaultMessage: 'Enable notifications for {category}',
  },
  pushDisable: {
    id: 'home.category_filters.push_disable',
    defaultMessage: 'Disable notifications for {category}',
  },
  pushUnavailable: {
    id: 'home.category_filters.push_unavailable',
    defaultMessage: 'Push permission will be requested if needed',
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

    return Array.from(categories.values()).sort((a, b) => {
      const aMandatory = a.get('mandatory_for_readers') ? 1 : 0;
      const bMandatory = b.get('mandatory_for_readers') ? 1 : 0;

      if (aMandatory !== bMandatory) {
        return bMandatory - aMandatory;
      }

      return a.get('name').localeCompare(b.get('name'));
    });
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

const selectNotificationCategories = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn([
    'category_notifications',
    'items',
  ]) as ImmutableMap<string, AccountCategory> | undefined;

const selectNotificationsLoading = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn(
    ['category_notifications', 'isLoading'],
    false,
  ) as boolean;

const selectNotificationsLoaded = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn(
    ['category_notifications', 'loaded'],
    false,
  ) as boolean;

const selectNotificationsSaving = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn([
    'category_notifications',
    'saving',
  ]) as ImmutableMap<string, boolean> | undefined;

const selectPushSubscribed = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn(
    ['push_notifications', 'isSubscribed'],
    false,
  ) as boolean;

const selectPushStatusEnabled = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn(
    ['push_notifications', 'alerts', 'status'],
    false,
  ) as boolean;

const selectBrowserSupport = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn(
    ['notifications', 'browserSupport'],
    false,
  ) as boolean;

const selectBrowserPermission = (state: RootState) =>
  (state as unknown as ImmutableMap<string, unknown>).getIn(
    ['notifications', 'browserPermission'],
    'default',
  ) as string;

interface CategoryFiltersDataParams {
  dispatch: ReturnType<typeof useAppDispatch>;
  isLoaded: boolean;
  isLoading: boolean;
  isNotificationsLoaded: boolean;
  isNotificationsLoading: boolean;
  categoriesLength: number;
}

const useCategoryFiltersData = ({
  dispatch,
  isLoaded,
  isLoading,
  isNotificationsLoaded,
  isNotificationsLoading,
  categoriesLength,
}: CategoryFiltersDataParams) => {
  useEffect(() => {
    if (!isLoaded && me) {
      void dispatch(fetchCategoryFilters());
    }
  }, [dispatch, isLoaded]);

  useEffect(() => {
    if (!isNotificationsLoaded && me) {
      void dispatch(fetchCategoryNotifications());
    }
  }, [dispatch, isNotificationsLoaded]);

  return (
    (!isLoaded ||
      isLoading ||
      !isNotificationsLoaded ||
      isNotificationsLoading) &&
    categoriesLength === 0
  );
};

interface CategoryRowProps {
  category: AccountCategory;
  isHidden: boolean;
  isMandatory: boolean;
  isSaving: boolean;
  isNotifySaving: boolean;
  isNotifyEnabled: boolean;
  notifyTitle: string;
  toggleAriaLabel: string;
  onToggleChange: (event: ChangeEvent<HTMLInputElement>) => void;
  onNotifyToggle: () => void;
}

const CategoryRow: React.FC<CategoryRowProps> = ({
  category,
  isHidden,
  isMandatory,
  isSaving,
  isNotifySaving,
  isNotifyEnabled,
  notifyTitle,
  toggleAriaLabel,
  onToggleChange,
  onNotifyToggle,
}) => {
  const categoryId = getCategoryId(category);

  return (
    <div className='home-category-filters__item'>
      <label
        htmlFor={`home-category-filter-${categoryId}`}
        className='home-category-filters__toggle'
      >
        <Toggle
          id={`home-category-filter-${categoryId}`}
          checked={!isHidden}
          disabled={isSaving || isMandatory}
          onChange={onToggleChange}
          aria-label={toggleAriaLabel}
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

      <IconButton
        className='home-category-filters__notify'
        icon={isNotifyEnabled ? 'bell' : 'bell-o'}
        iconComponent={
          isNotifyEnabled ? NotificationsActiveIcon : NotificationsIcon
        }
        active={isNotifyEnabled}
        title={notifyTitle}
        onClick={onNotifyToggle}
        disabled={isNotifySaving}
      />
    </div>
  );
};

const getNotifyTitle = (
  intl: IntlShape,
  categoryName: string,
  isNotifyEnabled: boolean,
  browserSupport: boolean,
  browserPermission: string,
) => {
  if (!isNotifyEnabled && browserSupport && browserPermission !== 'granted') {
    return intl.formatMessage(messages.pushUnavailable);
  }

  return intl.formatMessage(
    isNotifyEnabled ? messages.pushDisable : messages.pushEnable,
    { category: categoryName },
  );
};

export const CategoryFilters: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const [expanded, setExpanded] = useState(false);

  const categories = useAppSelector(selectHomeCategories);
  const hiddenCategories = useAppSelector(selectHiddenCategories);
  const isLoading = useAppSelector(selectIsLoading);
  const isLoaded = useAppSelector(selectIsLoaded);
  const saving = useAppSelector(selectSaving);
  const notificationCategories = useAppSelector(selectNotificationCategories);
  const isNotificationsLoading = useAppSelector(selectNotificationsLoading);
  const isNotificationsLoaded = useAppSelector(selectNotificationsLoaded);
  const notificationsSaving = useAppSelector(selectNotificationsSaving);
  const pushSubscribed = useAppSelector(selectPushSubscribed);
  const pushStatusEnabled = useAppSelector(selectPushStatusEnabled);
  const browserSupport = useAppSelector(selectBrowserSupport);
  const browserPermission = useAppSelector(selectBrowserPermission);

  const isStillLoading = useCategoryFiltersData({
    dispatch,
    isLoaded,
    isLoading,
    isNotificationsLoaded,
    isNotificationsLoading,
    categoriesLength: categories.length,
  });

  useEffect(() => {
    if (!pushSubscribed || pushStatusEnabled) {
      return;
    }

    if (notificationCategories && notificationCategories.size > 0) {
      dispatch(changeAlerts(['alerts', 'status'], true));
    }
  }, [dispatch, notificationCategories, pushStatusEnabled, pushSubscribed]);

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

  const handleNotificationToggle = useCallback(
    (categoryId: string) => () => {
      const isEnabled = notificationCategories?.has(categoryId);

      if (isEnabled) {
        void dispatch(removeCategoryNotification({ categoryId }));
        return;
      }

      void dispatch(addCategoryNotification({ categoryId }));

      if (browserSupport) {
        if (browserPermission !== 'granted') {
          dispatch(requestBrowserPermission());
        } else if (!pushSubscribed) {
          dispatch(registerPushNotifications());
        }
      }

      if (pushSubscribed && !pushStatusEnabled) {
        dispatch(changeAlerts(['alerts', 'status'], true));
      }
    },
    [
      browserPermission,
      browserSupport,
      dispatch,
      notificationCategories,
      pushSubscribed,
      pushStatusEnabled,
    ],
  );

  const renderBody = useMemo(() => {
    if (isStillLoading) {
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

    return (
      <div className='home-category-filters__list'>
        {categories.map((category) => {
          const categoryId = getCategoryId(category);
          const categoryName = category.get('name');
          const isMandatory = category.get('mandatory_for_readers');
          const isHidden =
            !isMandatory && Boolean(hiddenCategories?.has(categoryId));
          const isSaving = Boolean(saving?.get(categoryId));
          const isNotifySaving = Boolean(notificationsSaving?.get(categoryId));
          const isNotifyEnabled = Boolean(
            notificationCategories?.has(categoryId),
          );
          const notifyTitle = getNotifyTitle(
            intl,
            categoryName,
            isNotifyEnabled,
            browserSupport,
            browserPermission,
          );
          const toggleAriaLabel = intl.formatMessage(messages.toggleLabel, {
            category: categoryName,
          });

          return (
            <CategoryRow
              key={categoryId}
              category={category}
              isHidden={isHidden}
              isMandatory={isMandatory}
              isSaving={isSaving}
              isNotifySaving={isNotifySaving}
              isNotifyEnabled={isNotifyEnabled}
              notifyTitle={notifyTitle}
              toggleAriaLabel={toggleAriaLabel}
              onToggleChange={handleToggleChange(categoryId)}
              onNotifyToggle={handleNotificationToggle(categoryId)}
            />
          );
        })}
      </div>
    );
  }, [
    browserPermission,
    browserSupport,
    categories,
    handleNotificationToggle,
    handleToggleChange,
    hiddenCategories,
    intl,
    notificationCategories,
    notificationsSaving,
    saving,
    isStillLoading,
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
