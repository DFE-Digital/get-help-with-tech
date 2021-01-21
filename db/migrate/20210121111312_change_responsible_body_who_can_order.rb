class ChangeResponsibleBodyWhoCanOrder < ActiveRecord::Migration[6.0]
  def change
    ResponsibleBody.where(who_will_order_devices: 'schools').update_all(who_will_order_devices: 'school')
  end
end
