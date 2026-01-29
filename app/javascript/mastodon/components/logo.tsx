import { ThemedLogo } from './themed_logo';

export const WordmarkLogo: React.FC = () => (
  <ThemedLogo className='logo--wordmark' label='The Highlander' />
);

export const IconLogo: React.FC = () => (
  <ThemedLogo className='logo--icon' label='The Highlander' />
);

export const SymbolLogo: React.FC = () => <IconLogo />;
