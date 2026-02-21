# frozen_string_literal: true

class CreateAccountCategoryNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :account_category_notifications do |t|
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :category, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :account_category_notifications, [:account_id, :category_id], unique: true
  end
end
