# frozen_string_literal: true

class AddRoleToInvites < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      add_reference :invites, :user_role, null: true, foreign_key: { to_table: :user_roles, on_delete: :nullify }
    end
  end
end
