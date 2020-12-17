require 'rails_helper'
require 'shared/school_creator'

RSpec.describe UserCanOrderDevicesNotifications do
  subject(:service) { described_class.new(user: user) }

  context 'when orders can be placed' do
    let(:school) { create_schools_at_status(preorder_status: 'school_can_order') }
    let(:user) { create(:school_user, :orders_devices, school: school) }

    it 'sends :user_can_order email' do
      expect {
        service.call
      }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order', 'deliver_now', params: { user: user, school: school }, args: [])
    end
  end

  context 'when orders can be placed within a virtual cap', with_feature_flags: { virtual_caps: 'active' } do
    let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }
    let(:school) { create_schools_at_status(preorder_status: 'rb_can_order', responsible_body: responsible_body) }
    let(:user) { create(:trust_user, orders_devices: true, responsible_body: responsible_body) }

    it 'sends :user_can_order email' do
      expect {
        service.call
      }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order_in_virtual_cap', 'deliver_now', params: { user: user, school: school }, args: [])
    end
  end

  context 'when orders cannot be placed' do
    let(:responsible_body) { create(:trust, :manages_centrally) }
    let(:school) { create_schools_at_status(preorder_status: 'needs_info', responsible_body: responsible_body) }
    let(:user) { create(:user, orders_devices: true, responsible_body: responsible_body) }

    before do
      school.device_allocations.std_device.create!(cap: 10, allocation: 10, devices_ordered: 0)
      school.can_order!
    end

    it 'sends :user_can_order_but_action_needed email' do
      expect {
        service.call
      }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order_but_action_needed', 'deliver_now', params: { user: user, school: school }, args: [])
    end
  end
end
