require 'rails_helper'

RSpec.describe RestrictedDevicePasswordEmailingForSettingJob do
  let!(:rb_a) { create(:trust) }
  let!(:rb_a_user_1) { create(:trust_user, responsible_body: rb_a) }
  let!(:rb_b) { create(:trust) }

  let!(:school_a) { create(:school) }
  let!(:school_a_user_1) { create(:school_user, school: school_a) }
  let!(:school_b) { create(:school) }

  let(:data) { StringIO.new(setting.assets.restricted.order(:serial_number).to_closure_notification_csv) }
  let(:link_to_file) { Notifications.prepare_upload(data, true) }

  before do
    create(:asset, setting: rb_a)
    create(:asset, :lacks_admin_password, setting: rb_a)
    create(:asset, setting: rb_b)
    create(:trust_user, responsible_body: rb_a, restricted_devices_comms_opt_out: true)
    create(:trust_user, responsible_body: rb_b)

    create(:asset, setting: school_a)
    create(:asset, setting: school_b)
    create(:school_user, school: school_a, restricted_devices_comms_opt_out: true)
    create(:school_user, school: school_b)
  end

  describe '#perform' do
    context 'when the setting is an RB' do
      let(:setting) { rb_a }

      it 'enqueue a RestrictedDevicePasswordsMailer per RB user with restricted devices comms enabled' do
        expect {
          described_class.perform_now(setting_id: setting.id, setting_classname: setting.class.name)
        }.to have_enqueued_mail(RestrictedDevicePasswordsMailer).once

        data.rewind

        expect {
          described_class.perform_now(setting_id: setting.id, setting_classname: setting.class.name)
        }.to have_enqueued_mail(RestrictedDevicePasswordsMailer, :notify_restricted_devices)
               .with(params: { user: rb_a_user_1, organisation_name: rb_a.name, link_to_file: }, args: [])
               .once
      end
    end

    context 'when the setting is a School' do
      let(:setting) { school_a }

      it 'enqueue a RestrictedDevicePasswordsMailer per School user with restricted devices comms enabled' do
        expect {
          described_class.perform_now(setting_id: setting.id, setting_classname: setting.class.name)
        }.to have_enqueued_mail(RestrictedDevicePasswordsMailer).once

        data.rewind

        expect {
          described_class.perform_now(setting_id: setting.id, setting_classname: setting.class.name)
        }.to have_enqueued_mail(RestrictedDevicePasswordsMailer, :notify_restricted_devices)
               .with(params: { user: school_a_user_1, organisation_name: school_a.name, link_to_file: }, args: [])
               .once
      end
    end
  end
end
