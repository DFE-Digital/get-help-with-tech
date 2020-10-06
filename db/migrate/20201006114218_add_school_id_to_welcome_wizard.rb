class AddSchoolIdToWelcomeWizard < ActiveRecord::Migration[6.0]
  def change
    add_reference :school_welcome_wizards, :school

    add_index :school_welcome_wizards, %i[user_id school_id], unique: true

    SchoolWelcomeWizard.all.each do |wizard|
      wizard.update!(school_id: wizard.user.school_id)
    end
  end
end
