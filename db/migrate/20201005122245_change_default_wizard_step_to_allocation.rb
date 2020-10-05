class ChangeDefaultWizardStepToAllocation < ActiveRecord::Migration[6.0]
  def change
    change_column_default :school_welcome_wizards, :step, from: 'privacy', to: 'allocation'

    update_sql = <<~SQL
      UPDATE  school_welcome_wizards
        SET   step = 'allocation'
        WHERE step = 'privacy'
    SQL
    SchoolWelcomeWizard.connection.execute(update_sql)
  end
end
