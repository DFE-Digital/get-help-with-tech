class AddUserSupportAndComputacenterFlags < ActiveRecord::Migration[6.0]
  def change
    reversible do |migrate|
      migrate.up do
        add_column :users, :is_support, :boolean, null: false, default: false
        add_column :users, :is_computacenter, :boolean, null: false, default: false

        User.where('email_address LIKE ?', '%education.gov.uk').update_all(is_support: true)
        User.where('email_address LIKE ?', '%computacenter.com').update_all(is_computacenter: true)
      end
      migrate.down do
        remove_column :users, :is_support
        remove_column :users, :is_computacenter
      end
    end
  end
end
