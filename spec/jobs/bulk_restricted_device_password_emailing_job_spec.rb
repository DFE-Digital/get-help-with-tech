require 'rails_helper'

RSpec.describe BulkRestrictedDevicePasswordEmailingJob do
  let!(:rb_a) { create(:trust) }
  let!(:rb_a_asset) { create(:asset, setting: rb_a) }
  let!(:rb_a_user) { create(:trust_user, responsible_body: rb_a) }
  let!(:rb_b) { create(:trust) }
  let!(:rb_b_asset) { create(:asset, setting: rb_b) }
  let!(:rb_b_user) { create(:trust_user, responsible_body: rb_b) }
  let!(:rb_c) { create(:trust) }
  let!(:rb_c_asset) { create(:asset, setting: rb_c) }
  let!(:rb_c_user) { create(:trust_user, responsible_body: rb_c, restricted_devices_comms_opt_out: true) }
  let!(:rb_d) { create(:trust) }

  let!(:school_a) { create(:school) }
  let!(:school_a_asset) { create(:asset, setting: school_a) }
  let!(:school_a_user) { create(:school_user, school: school_a) }
  let!(:school_b) { create(:school) }
  let!(:school_b_asset) { create(:asset, setting: school_b) }
  let!(:school_b_user) { create(:school_user, school: school_b) }
  let!(:school_c) { create(:school) }
  let!(:school_c_asset) { create(:asset, setting: school_c) }
  let!(:school_c_user) { create(:school_user, school: school_c, restricted_devices_comms_opt_out: true) }
  let!(:school_d) { create(:school) }

  describe '#perform' do
    it 'enqueue a RestrictedDevicePasswordEmailingForSettingJob per RB and School with restricted devices and users' do
      expect { described_class.perform_now }.to have_enqueued_job(RestrictedDevicePasswordEmailingForSettingJob).exactly(4).times
      expect {
        described_class.perform_now
      }.to have_enqueued_job(RestrictedDevicePasswordEmailingForSettingJob)
             .with(hash_including(setting_id: rb_a.id, setting_classname: 'Trust'))
             .once
      expect {
        described_class.perform_now
      }.to have_enqueued_job(RestrictedDevicePasswordEmailingForSettingJob)
             .with(hash_including(setting_id: rb_b.id, setting_classname: 'Trust'))
             .once
      expect {
        described_class.perform_now
      }.to have_enqueued_job(RestrictedDevicePasswordEmailingForSettingJob)
             .with(hash_including(setting_id: school_a.id, setting_classname: 'CompulsorySchool'))
             .once
      expect {
        described_class.perform_now
      }.to have_enqueued_job(RestrictedDevicePasswordEmailingForSettingJob)
             .with(hash_including(setting_id: school_b.id, setting_classname: 'CompulsorySchool'))
             .once
    end

    it 'enqueue a limited number of rb jobs' do
      expect { described_class.perform_now(rb_limit: 1, school_limit: 1) }
        .to have_enqueued_job(RestrictedDevicePasswordEmailingForSettingJob).twice
      expect {
        described_class.perform_now
      }.to have_enqueued_job(RestrictedDevicePasswordEmailingForSettingJob)
             .with(hash_including(setting_id: rb_a.id, setting_classname: 'Trust'))
             .once
      expect {
        described_class.perform_now
      }.to have_enqueued_job(RestrictedDevicePasswordEmailingForSettingJob)
             .with(hash_including(setting_id: school_a.id, setting_classname: 'CompulsorySchool'))
             .once
    end
  end
end
