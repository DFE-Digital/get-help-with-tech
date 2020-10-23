require 'rails_helper'

RSpec.describe UserCanOrderDevicesNotifications do
  subject(:service) { described_class.new(user: user) }

  context 'when orders can be placed' do
    let(:allocation) { create(:school_device_allocation, :with_std_allocation, :with_orderable_devices) }
    let(:preorder) { create(:preorder_information, :school_will_order, status: :school_can_order) }
    let(:school) { create(:school, preorder_information: preorder, std_device_allocation: allocation, order_state: :can_order) }
    let(:user) { create(:school_user, orders_devices: true, school: school) }

    it 'sends :user_can_order email' do
      expect {
        service.call
      }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order', 'deliver_now', params: { user: user, school: school }, args: [])
    end
  end

  context 'when orders cannot be placed' do
    let(:allocation) { create(:school_device_allocation, :with_std_allocation, :with_orderable_devices) }
    let(:preorder) { create(:preorder_information, :school_will_order, status: :needs_info) }
    let(:school) { create(:school, preorder_information: preorder, std_device_allocation: allocation, order_state: :can_order) }
    let(:user) { create(:school_user, orders_devices: true, school: school) }

    it 'sends :user_can_order_but_action_needed email' do
      expect {
        service.call
      }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order_but_action_needed', 'deliver_now', params: { user: user, school: school }, args: [])
    end
  end
end
