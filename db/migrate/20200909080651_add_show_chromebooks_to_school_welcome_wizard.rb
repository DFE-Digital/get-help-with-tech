class AddShowChromebooksToSchoolWelcomeWizard < ActiveRecord::Migration[6.0]
  def change
    add_column :school_welcome_wizards, :show_chromebooks, :boolean
  end
end
