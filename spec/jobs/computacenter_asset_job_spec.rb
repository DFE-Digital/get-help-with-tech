require 'rails_helper'

RSpec.describe ComputacenterAssetJob, type: :job do
  let(:urn_1) { 't9000000' }
  let(:sold_to_account_no_1) { '81000000' }
  let(:sold_to_customer_1) { 'X ACADEMY TRUST' }
  let(:school_urn_1) { 'L1' }
  let(:ship_to_account_no_1) { '81000000' }
  let(:ship_to_customer_1) { 'X Academy' }
  let(:ship_to_address_1) { 'Borodin Avenue' }
  let(:ship_to_town_1) { 'Town End Farm' }
  let(:ship_to_postcode_1) { 'SR5 4NX' }
  let(:customer_order_number_1) { 'HYB-80448803' }
  let(:delivery_number_1) { '2013719960' }
  let(:order_number_1) { '5009131919' }
  let(:order_position_1) { '20' }
  let(:persona_1) { 'C' }
  let(:persona_description_1) { 'Chromebook' }
  let(:material_number_1) { '4282197' }
  let(:material_description_1) { 'Lenovo 100e Chromebook (G2)' }
  let(:manufacturer_part_number_1) { '81MA000UUK' }
  let(:manufacturer_name_1) { 'Buy and Store' }
  let(:part_classification_desc_1) { 'Laptops' }
  let(:serial_number_1) { '1FFFFFF' }
  let(:customer_order_date_1) { '10/29/21' }
  let(:order_date_1) { '10/29/21' }
  let(:despatch_date_1) { '10/29/21' }
  let(:report_quantity_1) { '1,00' }

  let(:urn_2) { 't9000001' }
  let(:sold_to_account_no_2) { '81000001' }
  let(:sold_to_customer_2) { 'Y ACADEMY TRUST' }
  let(:school_urn_2) { 'L2' }
  let(:ship_to_account_no_2) { '81000001' }
  let(:ship_to_customer_2) { 'Y Academy' }
  let(:ship_to_address_2) { 'School Road' }
  let(:ship_to_town_2) { 'Leeds' }
  let(:ship_to_postcode_2) { 'LS9 7PY' }
  let(:customer_order_number_2) { 'HYB-80448227' }
  let(:delivery_number_2) { '2013719240' }
  let(:order_number_2) { '5009131359' }
  let(:order_position_2) { '20' }
  let(:persona_2) { 'C' }
  let(:persona_description_2) { 'Chromebook' }
  let(:material_number_2) { '4282197' }
  let(:material_description_2) { 'Lenovo 100e Chromebook (G2)' }
  let(:manufacturer_part_number_2) { '81MA000UUK' }
  let(:manufacturer_name_2) { 'Buy and Store' }
  let(:part_classification_desc_2) { 'Laptops' }
  let(:serial_number_2) { '1FFFFF1' }
  let(:customer_order_date_2) { '10/29/21' }
  let(:order_date_2) { '10/29/21' }
  let(:despatch_date_2) { '10/29/21' }
  let(:report_quantity_2) { '1,00' }

  let(:header_row) { %w[URN SoldToAccountNo SoldToCustomer SchoolURN ShipToAccountNo ShipToCustomer ShipToAddress ShipToTown ShipToPostCode CustomerOrderNumber DeliveryNumber OrderNumber OrderPosition Persona PersonaDescription MaterialNumber MaterialDescription ManufacturerPartNumber ManufacturerName PartClassificationDesc SerialNumber CustomerOrderDate OrderDate DespatchDate ReportQuantity] }
  let(:row_1) { [urn_1, sold_to_account_no_1, sold_to_customer_1, school_urn_1, ship_to_account_no_1, ship_to_customer_1, ship_to_address_1, ship_to_town_1, ship_to_postcode_1, customer_order_number_1, delivery_number_1, order_number_1, order_position_1, persona_1, persona_description_1, material_number_1, material_description_1, manufacturer_part_number_1, manufacturer_name_1, part_classification_desc_1, serial_number_1, customer_order_date_1, order_date_1, despatch_date_1, report_quantity_1] }
  let(:row_2) { [urn_2, sold_to_account_no_2, sold_to_customer_2, school_urn_2, ship_to_account_no_2, ship_to_customer_2, ship_to_address_2, ship_to_town_2, ship_to_postcode_2, customer_order_number_2, delivery_number_2, order_number_2, order_position_2, persona_2, persona_description_2, material_number_2, material_description_2, manufacturer_part_number_2, manufacturer_name_2, part_classification_desc_2, serial_number_2, customer_order_date_2, order_date_2, despatch_date_2, report_quantity_2] }

  let(:asset_csv_file_path) { 'assets.csv' }

  before do
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:fatal)
  end

  describe '#perform_on_csv_file_path' do
    let(:job) { described_class.new }

    before do
      # behaves as CSV does when CSV options say file contains a header row
      allow(CSV).to receive(:foreach).and_yield(CSV::Row.new(header_row, row_1)).and_yield(CSV::Row.new(header_row, row_2))
      allow(job).to receive(:unix_word_count_output).and_return("      3 #{asset_csv_file_path}\n")
    end

    context 'create assets' do
      let(:action) { :create }

      describe 'record creation' do
        it 'creates two records' do
          expect { job.perform_on_csv_file_path(asset_csv_file_path, action) }.to change { Asset.count }.from(0).to(2)
          expect(Asset.first).to have_attributes(tag: order_number_1, serial_number: serial_number_1, model: material_description_1, department: sold_to_customer_1, department_id: urn_1, department_sold_to_id: sold_to_account_no_1, location: ship_to_customer_1, location_id: school_urn_1, location_cc_ship_to_account: ship_to_account_no_1)
          expect(Asset.second).to have_attributes(tag: order_number_2, serial_number: serial_number_2, model: material_description_2, department: sold_to_customer_2, department_id: urn_2, department_sold_to_id: sold_to_account_no_2, location: ship_to_customer_2, location_id: school_urn_2, location_cc_ship_to_account: ship_to_account_no_2)
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

      before do
        create(:asset, tag: order_number_1, serial_number: serial_number_1)
        create(:asset, tag: order_number_2)
        job.perform_on_csv_file_path(asset_csv_file_path, action)
      end

      describe 'record updates' do
        it 'logs' do
          expect(Rails.logger).to have_received(:info).with('Started ComputacenterAssetJob (assets.csv, :update) ~2 asset(s)').ordered
          expect(Rails.logger).to have_received(:info).with('Finished ComputacenterAssetJob (assets.csv, :update) with 2 asset(s) from CSV file').ordered
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
