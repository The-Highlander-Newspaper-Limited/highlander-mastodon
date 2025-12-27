import type React from 'react';

import type { List as ImmutableList } from 'immutable';

import type { AccountCategory } from '@/mastodon/models/account_categories';

const CATEGORY_COLORS = {
  borderRed: '#dd3333',
  borderBlack: '#000000',
  borderGrey: '#6c757d',
};

interface CategoryBadgesProps {
  categories?: ImmutableList<AccountCategory> | null;
  className?: string;
}

export const CategoryBadges: React.FC<CategoryBadgesProps> = ({
  categories,
  className = '',
}) => {
  if (!categories || categories.size === 0) {
    return null;
  }

  return (
    <div className={`category-badges ${className}`.trim()}>
      {categories.map((category, index) => {
        const color = category.mandatory_for_readers
          ? CATEGORY_COLORS.borderRed
          : CATEGORY_COLORS.borderGrey;

        return (
          <span
            key={index}
            className='category-badge'
            style={{
              display: 'inline-block',
              border: `1px solid ${color}`,
              color,
              backgroundColor: 'transparent',
              padding: '2px 6px',
              borderRadius: '4px',
              fontSize: '12px',
              fontWeight: 500,
              marginRight: '4px',
              marginBottom: '4px',
            }}
            title={
              category.mandatory_for_readers
                ? `${category.name} (featured)`
                : category.name
            }
          >
            {category.name}
          </span>
        );
      })}
    </div>
  );
};
