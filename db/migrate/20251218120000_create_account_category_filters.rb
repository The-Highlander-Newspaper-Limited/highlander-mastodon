# frozen_string_literal: true

class CreateAccountCategoryFilters < ActiveRecord::Migration[8.0]
  def change
    create_table :account_category_filters do |t|
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :category, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :account_category_filters, [:account_id, :category_id], unique: true
  end
end
