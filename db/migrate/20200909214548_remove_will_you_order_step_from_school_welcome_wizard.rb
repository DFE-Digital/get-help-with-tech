class RemoveWillYouOrderStepFromSchoolWelcomeWizard < ActiveRecord::Migration[6.0]
  def change
    update_sql = <<~SQL
      UPDATE  school_welcome_wizards
        SET   step = 'techsource_account'
        WHERE step = 'will_you_order'
    SQL
    SchoolWelcomeWizard.connection.execute(update_sql)
  end
end
