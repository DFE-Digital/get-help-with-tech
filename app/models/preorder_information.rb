class PreorderInformation < ApplicationRecord
  self.table_name = 'preorder_information'

  enum status: {
    needs_contact: 'needs_contact',
    needs_info: 'needs_info',
    ready: 'ready',
  }


  # Update this method as we add more fields (e.g. chromebook info)
  def infer_status
    if who_will_order_devices == 'school'
      :needs_contact
    else
      :needs_info
    end
  end
end
