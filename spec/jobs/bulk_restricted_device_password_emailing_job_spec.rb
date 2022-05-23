require 'rails_helper'

RSpec.describe BulkRestrictedDevicePasswordEmailingJob do
  let!(:rb_b) { create(:trust, name: 'Trust B') }
  let!(:rb_a) { create(:trust, name: 'Trust A') }
  let!(:rb_c) { create(:trust, name: 'Trust C') }

  let!(:school_c) { create(:school, name: 'School C') }
  let!(:school_a) { create(:school, name: 'School A') }
  let!(:school_b) { create(:school, name: 'School B') }

  before do
    create(:asset, setting: rb_a)
    create(:asset, setting: rb_b)
    create(:asset, setting: rb_c)
    create(:trust_user, responsible_body: rb_a)
    create(:trust_user, responsible_body: rb_b)
    create(:trust_user, responsible_body: rb_c, restricted_devices_comms_opt_out: true)
    create(:trust)

    create(:asset, setting: school_a)
    create(:asset, setting: school_b)
    create(:asset, setting: school_c)
    create(:school_user, school: school_a)
    create(:school_user, school: school_b)
    create(:school_user, school: school_c, restricted_devices_comms_opt_out: true)
    create(:school)
  end

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

    it 'enqueue the first limited number of jobs' do
      expect { described_class.perform_now(number_of_rbs: 1, number_of_schools: 1) }
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

    it 'enqueue an offset of limited number of jobs' do
      expect { described_class.perform_now(rb_offset: 1, school_offset: 1) }
        .to have_enqueued_job(RestrictedDevicePasswordEmailingForSettingJob).twice
      expect {
        described_class.perform_now
      }.to have_enqueued_job(RestrictedDevicePasswordEmailingForSettingJob)
             .with(hash_including(setting_id: rb_b.id, setting_classname: 'Trust'))
             .once
      expect {
        described_class.perform_now
      }.to have_enqueued_job(RestrictedDevicePasswordEmailingForSettingJob)
             .with(hash_including(setting_id: school_b.id, setting_classname: 'CompulsorySchool'))
             .once
    end
  end
end
