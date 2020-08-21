class PreorderInformation < ApplicationRecord
  self.table_name = 'preorder_information'

  belongs_to :school

  enum status: {
    needs_contact: 'needs_contact',
    needs_info: 'needs_info',
    ready: 'ready',
    school_contacted: 'school_contacted'
  }

  # Update this method as we add more fields (e.g. chromebook info)
  # with reference to the prototype:
  # https://github.com/DFE-Digital/increasing-internet-access-prototype/blob/master/app/views/responsible-body/devices/school/_status-tag.html
  def infer_status
    if who_will_order_devices == 'school'
      :needs_contact
    else
      :needs_info
    end
  end
end
