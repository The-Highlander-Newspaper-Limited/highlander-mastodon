import logoBlack from '@/images/highlander_H_black.svg';
import logoWhite from '@/images/highlander_H_white.svg';

interface ThemedLogoProps {
  className: string;
  label: string;
}

export const ThemedLogo: React.FC<ThemedLogoProps> = ({ className, label }) => (
  <span className={`logo logo--img ${className}`} role='img' aria-label={label}>
    <img src={logoBlack} alt='' className='logo__img logo__img--light' />
    <img src={logoWhite} alt='' className='logo__img logo__img--dark' />
  </span>
);
