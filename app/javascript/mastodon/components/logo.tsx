import logo from '@/images/logo.svg';

export const WordmarkLogo: React.FC = () => (
  <svg viewBox='0 0 160 160' className='logo logo--wordmark' role='img'>
    <title>The Highlander</title>
    <use xlinkHref='#logo-symbol-wordmark' />
  </svg>
);

export const IconLogo: React.FC = () => (
  <svg viewBox='0 0 160 160' className='logo logo--icon' role='img'>
    <title>The Highlander</title>
    <use xlinkHref='#logo-symbol-icon' />
  </svg>
);

export const SymbolLogo: React.FC = () => (
  <img src={logo} alt='The Highlander' className='logo logo--icon' />
);
