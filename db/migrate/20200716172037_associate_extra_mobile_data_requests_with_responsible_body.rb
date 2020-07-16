class AssociateExtraMobileDataRequestsWithResponsibleBody < ActiveRecord::Migration[6.0]
  def change
    add_reference :extra_mobile_data_requests, :responsible_body, foreign_key: true
  end
end
