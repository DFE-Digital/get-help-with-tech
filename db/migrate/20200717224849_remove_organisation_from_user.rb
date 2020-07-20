class RemoveOrganisationFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :organisation, :string
  end
end
