class CreateSchoolWelcomeWizards < ActiveRecord::Migration[6.0]
  def change
    create_table :school_welcome_wizards do |t|
      t.references :user, null: false, index: true
      t.string :step, null: false, default: 'welcome'
      t.timestamps
    end
  end
end
