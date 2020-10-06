class DropLegacySchoolIdFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :legacy_school_id, :bigint
  end
end
