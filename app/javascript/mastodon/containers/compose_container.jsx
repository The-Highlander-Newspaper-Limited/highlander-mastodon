import { Provider } from 'react-redux';

import { fetchServer } from 'mastodon/actions/server';
import { hydrateStore } from 'mastodon/actions/store';
import { Router } from 'mastodon/components/router';
import Compose from 'mastodon/features/standalone/compose';
import { IdentityContext, createIdentityContext } from 'mastodon/identity_context';
import { initialState } from 'mastodon/initial_state';
import { IntlProvider } from 'mastodon/locales';
import { store } from 'mastodon/store';

if (initialState) {
  store.dispatch(hydrateStore(initialState));
}

store.dispatch(fetchServer());

const identity = initialState
  ? createIdentityContext(initialState)
  : { signedIn: false, accountId: undefined, disabledAccountId: undefined, permissions: 0 };

const ComposeContainer = () => (
  <IdentityContext.Provider value={identity}>
    <IntlProvider>
      <Provider store={store}>
        <Router>
          <Compose />
        </Router>
      </Provider>
    </IntlProvider>
  </IdentityContext.Provider>
);

export default ComposeContainer;
