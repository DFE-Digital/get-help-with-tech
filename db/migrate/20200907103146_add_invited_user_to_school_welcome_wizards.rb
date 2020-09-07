class AddInvitedUserToSchoolWelcomeWizards < ActiveRecord::Migration[6.0]
  def change
    add_reference :school_welcome_wizards, :invited_user, foreign_key: { to_table: :users }
    rename_column :school_welcome_wizards, :orders_devices, :user_orders_devices
  end
end
