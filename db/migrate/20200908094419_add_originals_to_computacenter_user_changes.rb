class AddOriginalsToComputacenterUserChanges < ActiveRecord::Migration[6.0]
  def change
    add_column :computacenter_user_changes, :original_first_name, :text
    add_column :computacenter_user_changes, :original_last_name, :text
    add_column :computacenter_user_changes, :original_telephone, :text
    add_column :computacenter_user_changes, :original_responsible_body, :text
    add_column :computacenter_user_changes, :original_responsible_body_urn, :text
    add_column :computacenter_user_changes, :original_cc_sold_to_number, :text
    add_column :computacenter_user_changes, :original_school, :text
    add_column :computacenter_user_changes, :original_school_urn, :text
    add_column :computacenter_user_changes, :original_cc_ship_to_number, :text
  end
end
