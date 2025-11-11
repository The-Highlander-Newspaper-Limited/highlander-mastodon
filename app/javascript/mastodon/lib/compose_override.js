const WINDOW_KEY = '__COMPOSE_OVERRIDE__';

const composeOverride = {
  enable() {
    if (typeof window === 'undefined') return;

    window[WINDOW_KEY] = true;
  },

  disable() {
    if (typeof window === 'undefined') return;

    delete window[WINDOW_KEY];
  },

  isEnabled() {
    if (typeof window === 'undefined') return false;

    return window[WINDOW_KEY] === true;
  },
};

export default composeOverride;
