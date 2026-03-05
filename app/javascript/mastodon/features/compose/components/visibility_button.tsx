import { useCallback, useMemo } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import {
  changeComposeVisibility,
  setComposeQuotePolicy,
} from '@/mastodon/actions/compose_typed';
import { openModal } from '@/mastodon/actions/modal';
import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { Icon } from '@/mastodon/components/icon';
import { useAppSelector, useAppDispatch } from '@/mastodon/store';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';

import type { VisibilityModalCallback } from '../../ui/components/visibility_modal';

import { messages as privacyMessages } from './privacy_dropdown';

const messages = defineMessages({
  anyone_quote: {
    id: 'privacy.quote.anyone',
    defaultMessage: '{visibility}, anyone can quote',
  },
  limited_quote: {
    id: 'privacy.quote.limited',
    defaultMessage: '{visibility}, quotes limited',
  },
  disabled_quote: {
    id: 'privacy.quote.disabled',
    defaultMessage: '{visibility}, quotes disabled',
  },
});

interface PrivacyDropdownProps {
  disabled?: boolean;
}

export const VisibilityButton: FC<PrivacyDropdownProps> = (props) => {
  return <PrivacyModalButton {...props} />;
};

const visibilityOptions = {
  public: {
    icon: 'globe',
    iconComponent: PublicIcon,
    value: 'public',
    text: privacyMessages.public_short,
  },
  unlisted: {
    icon: 'unlock',
    iconComponent: QuietTimeIcon,
    value: 'unlisted',
    text: privacyMessages.unlisted_short,
  },
};

const PrivacyModalButton: FC<PrivacyDropdownProps> = ({ disabled = false }) => {
  const intl = useIntl();

  const quotePolicy = useAppSelector(
    (state) => state.compose.get('quote_policy') as ApiQuotePolicy,
  );
  const visibility = useAppSelector(
    (state) => state.compose.get('privacy') as StatusVisibility,
  );
  const selectedVisibility =
    visibility === 'public' || visibility === 'unlisted'
      ? visibility
      : 'unlisted';

  const { icon, iconComponent } = useMemo(() => {
    const option = visibilityOptions[selectedVisibility];
    return { icon: option.icon, iconComponent: option.iconComponent };
  }, [selectedVisibility]);
  const text = useMemo(() => {
    const visibilityText = intl.formatMessage(
      visibilityOptions[selectedVisibility].text,
    );
    if (quotePolicy === 'nobody') {
      return intl.formatMessage(messages.disabled_quote, {
        visibility: visibilityText,
      });
    }
    if (quotePolicy !== 'public') {
      return intl.formatMessage(messages.limited_quote, {
        visibility: visibilityText,
      });
    }
    return intl.formatMessage(messages.anyone_quote, {
      visibility: visibilityText,
    });
  }, [quotePolicy, selectedVisibility, intl]);

  const dispatch = useAppDispatch();

  const handleChange: VisibilityModalCallback = useCallback(
    (newVisibility, newQuotePolicy) => {
      if (newVisibility !== visibility) {
        dispatch(changeComposeVisibility(newVisibility));
      }
      if (newQuotePolicy !== quotePolicy) {
        dispatch(setComposeQuotePolicy(newQuotePolicy));
      }
    },
    [dispatch, quotePolicy, visibility],
  );

  const handleOpen = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'COMPOSE_PRIVACY',
        modalProps: { onChange: handleChange },
      }),
    );
  }, [dispatch, handleChange]);

  return (
    <button
      type='button'
      title={intl.formatMessage(privacyMessages.change_privacy)}
      onClick={handleOpen}
      disabled={disabled}
      className={classNames('dropdown-button')}
    >
      <Icon id={icon} icon={iconComponent} />
      <span className='dropdown-button__label'>{text}</span>
    </button>
  );
};
