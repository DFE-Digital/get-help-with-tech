class AddPhaseAndEstablishmentTypeToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :phase, :string, index: true
    add_column :schools, :establishment_type, :string, index: true
  end
end
