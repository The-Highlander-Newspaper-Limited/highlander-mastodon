import { List as ImmutableList } from 'immutable';

import { render, screen } from '@/testing/rendering';
import { AccountCategoryFactory } from 'mastodon/models/account_categories';

import { CategoryBadges } from '../category_badges';

describe('<CategoryBadges />', () => {
  const createCategory = (name: string, mandatory: boolean) =>
    AccountCategoryFactory({
      id: name.toLowerCase(),
      name,
      mandatory_for_readers: mandatory,
    });

  it('renders nothing when categories is null', () => {
    const { container } = render(<CategoryBadges categories={null} />);
    expect(container.firstChild).toBeNull();
  });

  it('renders nothing when categories is empty', () => {
    const categories = ImmutableList([]);
    const { container } = render(<CategoryBadges categories={categories} />);
    expect(container.firstChild).toBeNull();
  });

  it('renders category badges', () => {
    const categories = ImmutableList([
      createCategory('News', false),
      createCategory('Opinion', true),
    ]);

    render(<CategoryBadges categories={categories} />);

    expect(screen.getByText('News')).toBeInTheDocument();
    expect(screen.getByText('Opinion')).toBeInTheDocument();
  });

  it('applies red border for mandatory categories', () => {
    const categories = ImmutableList([createCategory('Opinion', true)]);

    render(<CategoryBadges categories={categories} />);

    const badge = screen.getByText('Opinion');
    expect(badge).toHaveStyle({ borderColor: '#dd3333' });
  });

  it('applies black border for regular categories', () => {
    const categories = ImmutableList([createCategory('News', false)]);

    render(<CategoryBadges categories={categories} />);

    const badge = screen.getByText('News');
    expect(badge).toHaveStyle({ borderColor: '#000000' });
  });

  it('includes title attribute for accessibility', () => {
    const categories = ImmutableList([createCategory('Opinion', true)]);

    render(<CategoryBadges categories={categories} />);

    const badge = screen.getByText('Opinion');
    expect(badge).toHaveAttribute('title', 'Opinion (mandatory for readers)');
  });

  it('applies custom className', () => {
    const categories = ImmutableList([createCategory('News', false)]);

    const { container } = render(
      <CategoryBadges categories={categories} className='custom-class' />,
    );

    expect(container.firstChild).toHaveClass('category-badges');
    expect(container.firstChild).toHaveClass('custom-class');
  });
});
