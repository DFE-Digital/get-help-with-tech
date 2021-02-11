class AddRbUserToUserChange < ActiveRecord::Migration[6.1]
  def change
    add_column :computacenter_user_changes, :cc_rb_user, :boolean
    add_column :computacenter_user_changes, :original_cc_rb_user, :boolean
  end
end
