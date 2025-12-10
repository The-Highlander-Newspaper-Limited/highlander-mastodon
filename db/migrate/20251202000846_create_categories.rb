# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :mandatory_for_readers, default: false, null: false

      t.timestamps
    end

    add_index :categories, :name, unique: true

    create_table :account_categories do |t|
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :category, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :account_categories, [:account_id, :category_id], unique: true
    add_index :account_categories, [:category_id, :account_id]
  end
end
