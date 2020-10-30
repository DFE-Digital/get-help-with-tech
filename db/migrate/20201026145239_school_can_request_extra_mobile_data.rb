class SchoolCanRequestExtraMobileData < ActiveRecord::Migration[6.0]
  def change
    add_reference :extra_mobile_data_requests, :school, foreign_key: true
    change_column_null :extra_mobile_data_requests, :responsible_body_id, true
  end
end
