require 'rails_helper'

RSpec.describe ComputacenterAssetJob, type: :job do
  let(:sys_id_1) { '62c7' }
  let(:asset_tag_1) { '30000000' }
  let(:serial_number_1) { '1FFFFFF' }
  let(:model_name_1) { 'Acme Laptop 1000' }
  let(:department_name_1) { 'X ACADEMY TRUST' }
  let(:department_id_1) { 't9000000' }
  let(:sold_to_1) { '81000000' }
  let(:location_name_1) { 'X Academy' }
  let(:location_id_1) { 'L1' }
  let(:ship_to_1) { '81000000' }
  let(:bios_password_1) { 'secretbiospassword1' }
  let(:admin_password_1) { 'secretadminpassword1' }
  let(:hardware_hash_1) { 'secrethardwarehash1' }
  let(:sys_created_on_1) { '2020-11-23 14:03:04' }

  let(:sys_id_2) { '7bd4' }
  let(:asset_tag_2) { '30000001' }
  let(:serial_number_2) { '1FFFFF1' }
  let(:model_name_2) { 'Acme Laptop 2000' }
  let(:department_name_2) { 'Y ACADEMY TRUST' }
  let(:department_id_2) { 't9000001' }
  let(:sold_to_2) { '81000001' }
  let(:location_name_2) { 'Y Academy' }
  let(:location_id_2) { 'L2' }
  let(:ship_to_2) { '81000001' }
  let(:bios_password_2) { 'secretbiospassword2' }
  let(:admin_password_2) { 'secretadminpassword2' }
  let(:hardware_hash_2) { 'secrethardwarehash2' }
  let(:sys_created_on_2) { '2020-12-24 18:03:04' }

  let(:header_row) { %w[sys_id asset_tag serial_number model.display_name department.name department.id department.u_sold_to_id location.name location.name.u_location_id location.u_cc_ship_to_account u_bios_password u_admin_password u_hardware_hash sys_created_on] }
  let(:row_1) { [sys_id_1, asset_tag_1, serial_number_1, model_name_1, department_name_1, department_id_1, sold_to_1, location_name_1, location_id_1, ship_to_1, bios_password_1, admin_password_1, hardware_hash_1, sys_created_on_1] }
  let(:row_2) { [sys_id_2, asset_tag_2, serial_number_2, model_name_2, department_name_2, department_id_2, sold_to_2, location_name_2, location_id_2, ship_to_2, bios_password_2, admin_password_2, hardware_hash_2, sys_created_on_2] }

  let(:asset_csv_file_path) { 'assets.csv' }

  before do
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:fatal)
  end

  describe '#perform_on_csv_file_path' do
    let(:job) { described_class.new }

    before do
      # behaves as CSV does when CSV options say file contains a header row
      allow(CSV).to receive(:foreach).and_yield(row_1).and_yield(row_2)
      allow(job).to receive(:unix_word_count_output).and_return("      3 #{asset_csv_file_path}\n")
    end

    context 'create assets' do
      let(:action) { :create }

      describe 'record creation' do
        it 'creates two records' do
          expect { job.perform_on_csv_file_path(asset_csv_file_path, action) }.to change { Asset.count }.from(0).to(2)
          expect(Asset.first).to have_attributes(tag: asset_tag_1, serial_number: serial_number_1, model: model_name_1, department: department_name_1, department_id: department_id_1, department_sold_to_id: sold_to_1, location: location_name_1, location_id: location_id_1, location_cc_ship_to_account: ship_to_1, bios_password: bios_password_1, admin_password: admin_password_1, hardware_hash: hardware_hash_1, sys_created_at: Time.zone.parse(sys_created_on_1))
          expect(Asset.second).to have_attributes(tag: asset_tag_2, serial_number: serial_number_2, model: model_name_2, department: department_name_2, department_id: department_id_2, department_sold_to_id: sold_to_2, location: location_name_2, location_id: location_id_2, location_cc_ship_to_account: ship_to_2, bios_password: bios_password_2, admin_password: admin_password_2, hardware_hash: hardware_hash_2, sys_created_at: Time.zone.parse(sys_created_on_2))
        end
      end

      describe 'logging' do
        before { job.perform_on_csv_file_path(asset_csv_file_path, action) }

        it 'logs' do
          expect(Rails.logger).to have_received(:info).with('Started ComputacenterAssetJob (assets.csv, :create) ~2 asset(s)').ordered
          expect(Rails.logger).to have_received(:info).with('Finished ComputacenterAssetJob (assets.csv, :create) with 2 asset(s) from CSV file').ordered
          expect(Rails.logger).to have_received(:info).with('2 asset(s) added to the database').ordered
          expect(Rails.logger).to have_received(:info).with('There are now 2 total asset(s) in the database').ordered
        end
      end
    end

    context 'update assets' do
      let(:action) { :update }

      before { create(:asset, tag: asset_tag_1, serial_number: serial_number_1) }

      describe 'record updates' do
        it 'updates one record' do
          expect { job.perform_on_csv_file_path(asset_csv_file_path, action) }.not_to change { Asset.count } # rubocop:disable Lint/AmbiguousBlockAssociation:
          expect(Rails.logger).to have_received(:info).with('Started ComputacenterAssetJob (assets.csv, :update) ~2 asset(s)').ordered
          expect(Rails.logger).to have_received(:info).with('Finished ComputacenterAssetJob (assets.csv, :update) with 2 asset(s) from CSV file').ordered
          expect(Rails.logger).to have_received(:info).with('1 asset(s) updated in the database').ordered
          expect(Rails.logger).to have_received(:info).with('0 asset(s) found but unchanged in the database').ordered
          expect(Rails.logger).to have_received(:info).with('1 missing asset(s) could not be updated').ordered
        end
      end
    end

    context 'invalid action' do
      before { job.perform_on_csv_file_path(asset_csv_file_path, :blah) }

      specify { expect(Rails.logger).to have_received(:fatal).with('Unknown action :blah') }
    end
  end

  describe '#log_progress' do
    before { described_class.new.log_progress(50, 99) }

    specify { expect(Rails.logger).to have_received(:info).with('(50.51%) Processed 50 of ~99 asset(s) so far...') }
  end
end
