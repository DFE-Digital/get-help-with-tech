class ChangeDefaultSchoolWelcomeWizardStepToPrivacy < ActiveRecord::Migration[6.0]
  def change
    change_column_default :school_welcome_wizards, :step, from: 'welcome', to: 'privacy'

    update_sql = <<~SQL
      UPDATE  school_welcome_wizards
        SET   step = 'privacy'
        WHERE step = 'welcome'
    SQL
    SchoolWelcomeWizard.connection.execute(update_sql)
  end
end
