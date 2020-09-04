class AddOrdersDevicesToSchoolWelcomeWizard < ActiveRecord::Migration[6.0]
  def change
    add_column :school_welcome_wizards, :orders_devices, :boolean
    add_column :school_welcome_wizards, :first_school_user, :boolean
  end
end
