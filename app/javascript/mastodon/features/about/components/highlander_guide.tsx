import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import categoriesImage from '@/images/highlander/onboarding/highlander-categories.png';
import createAccountImage from '@/images/highlander/onboarding/highlander-create-account.png';
import notificationsImage from '@/images/highlander/onboarding/highlander-notifications.png';

const richTextValues = {
  strong: (chunks: React.ReactNode) => <strong>{chunks}</strong>,
};

const messages = defineMessages({
  iphoneStep1: {
    id: 'about.highlander.install.iphone.step_1',
    defaultMessage:
      'Tap the <strong>Share</strong> button (the square with an upward arrow) at the bottom of the screen.',
  },
  iphoneStep2: {
    id: 'about.highlander.install.iphone.step_2',
    defaultMessage: 'Scroll down and tap <strong>Add to Home Screen</strong>.',
  },
  iphoneStep3: {
    id: 'about.highlander.install.iphone.step_3',
    defaultMessage:
      'Change the name if you like, then tap <strong>Add</strong>.',
  },
  androidStep1: {
    id: 'about.highlander.install.android.step_1',
    defaultMessage:
      'Tap the <strong>three-dot menu</strong> (⋮), usually in the top-right or bottom-right corner, depending on your setup.',
  },
  androidStep2: {
    id: 'about.highlander.install.android.step_2',
    defaultMessage:
      'Tap <strong>Add to Home Screen</strong>. You may also see an <strong>Install app</strong> banner at the bottom. Tap that instead if it appears.',
  },
  androidStep3: {
    id: 'about.highlander.install.android.step_3',
    defaultMessage:
      'Tap <strong>Install</strong> or <strong>Add</strong> to confirm.',
  },
});

const iphoneSteps = [
  messages.iphoneStep1,
  messages.iphoneStep2,
  messages.iphoneStep3,
];

const androidSteps = [
  messages.androidStep1,
  messages.androidStep2,
  messages.androidStep3,
];

export const HighlanderGuide: FC = () => {
  const intl = useIntl();

  return (
    <div className='about__guide'>
      <h3 className='about__guide__app-title'>
        <FormattedMessage
          id='about.highlander.app_title'
          defaultMessage='The Highlander Community App'
        />
      </h3>

      <p className='about__guide__tagline'>
        <FormattedMessage
          id='about.highlander.app_tagline'
          defaultMessage='Everything local in one trusted place.'
        />
      </p>

      <p className='about__guide__lead'>
        <FormattedMessage
          id='about.highlander.lead'
          defaultMessage="Breaking news and community alerts when they matter. The Highlander is Canadian-owned and community-focused. By using this app, you're supporting local businesses and local journalism together."
        />
      </p>

      <h2 className='about__guide__steps-title'>
        <FormattedMessage
          id='about.highlander.steps_title'
          defaultMessage="Here's some tips that will help you get started:"
        />
      </h2>

      <div className='about__guide__step'>
        <h4 className='about__guide__step-title'>
          <FormattedMessage
            id='about.highlander.create_account.title'
            defaultMessage='1. Create an account'
          />
        </h4>

        <p className='about__guide__step-body'>
          <FormattedMessage
            id='about.highlander.create_account.body'
            defaultMessage='Tap <strong>Create account</strong> to get started.'
            values={richTextValues}
          />
        </p>

        <img
          className='about__guide__step-image'
          src={createAccountImage}
          alt={intl.formatMessage({
            id: 'about.highlander.create_account.alt',
            defaultMessage: 'Create account screen',
          })}
        />
      </div>

      <div className='about__guide__step'>
        <h4 className='about__guide__step-title'>
          <FormattedMessage
            id='about.highlander.categories.title'
            defaultMessage='2. Choose your categories'
          />
        </h4>

        <p className='about__guide__step-body'>
          <FormattedMessage
            id='about.highlander.categories.body'
            defaultMessage="All categories are selected by default. Use the toggle switches to turn off any categories you don't wish to follow."
          />
        </p>

        <img
          className='about__guide__step-image'
          src={categoriesImage}
          alt={intl.formatMessage({
            id: 'about.highlander.categories.alt',
            defaultMessage: 'Category toggle switches',
          })}
        />
      </div>

      <div className='about__guide__step'>
        <h4 className='about__guide__step-title'>
          <FormattedMessage
            id='about.highlander.notifications.title'
            defaultMessage='3. Turn on notifications'
          />
        </h4>

        <p className='about__guide__step-body'>
          <FormattedMessage
            id='about.highlander.notifications.body'
            defaultMessage="Tap the bell icon next to any category to get notified when new posts are added. For example, you may want notifications for Breaking News, so you'll know right away when a highway is closed or school buses are cancelled."
          />
        </p>

        <img
          className='about__guide__step-image'
          src={notificationsImage}
          alt={intl.formatMessage({
            id: 'about.highlander.notifications.alt',
            defaultMessage: 'Bell icons for notifications',
          })}
        />
      </div>

      <hr className='about__guide__divider' />

      <div className='about__guide__step'>
        <h4 className='about__guide__step-title'>
          <FormattedMessage
            id='about.highlander.install.title'
            defaultMessage='4. Install the app on your phone'
          />
        </h4>

        <p className='about__guide__step-body'>
          <FormattedMessage
            id='about.highlander.install.body'
            defaultMessage='Add this app to your home screen so it works just like a regular app. No app store needed.'
          />
        </p>

        <h5 className='about__guide__platform-title'>
          <FormattedMessage
            id='about.highlander.install.iphone.title'
            defaultMessage='iPhone (Safari only)'
          />
        </h5>

        <div className='about__guide__callout'>
          <FormattedMessage
            id='about.highlander.install.iphone.warning'
            defaultMessage="You must use <strong>Safari.</strong> The install option isn't available in Chrome or Firefox on iPhone."
            values={richTextValues}
          />
        </div>

        <ol className='about__guide__list'>
          {iphoneSteps.map((step) => (
            <li key={step.id}>
              <FormattedMessage {...step} values={richTextValues} />
            </li>
          ))}
        </ol>

        <h5 className='about__guide__platform-title'>
          <FormattedMessage
            id='about.highlander.install.android.title'
            defaultMessage='Android (Chrome)'
          />
        </h5>

        <ol className='about__guide__list about__guide__list--last'>
          {androidSteps.map((step) => (
            <li key={step.id}>
              <FormattedMessage {...step} values={richTextValues} />
            </li>
          ))}
        </ol>
      </div>
    </div>
  );
};
