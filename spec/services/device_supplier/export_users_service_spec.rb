require 'rails_helper'

RSpec.describe DeviceSupplier::ExportUsersService, type: :model do
  describe '#call' do
    let(:user) { create(:school_user, :relevant_to_computacenter, :with_a_confirmed_techsource_account) }
    let(:filename) { Rails.root.join('tmp/device_supplier_export_users_test_data.csv') }
    let(:csv) { CSV.read(filename, headers: true) }
    let(:user_csv_row) { csv[0] }
    let(:service_call) { service.call }
    let(:sold_to) { user.school.sold_to }

    after do
      remove_file(filename)
    end

    subject(:service) { described_class.new(filename) }

    before do |test|
      user
      service_call unless test.metadata[:delayed_service_call]
    end

    context 'when given a filename' do
      it 'creates a CSV file' do
        expect(File.exist?(filename)).to be true
      end

      it 'includes a heading row and all Schools in the CSV file' do
        line_count = `wc -l "#{filename}"`.split.first.to_i
        expect(line_count).to eq(School.count + 1)
      end

      it 'includes the correct headers' do
        expect(csv.headers).to match_array(DeviceSupplier::ExportUsersService.headers)
      end
    end

    context 'when devices are managed by the school' do
      it 'includes the first_name in the csv' do
        expect(user_csv_row['first_name']).to eq(user.first_name)
      end

      it 'includes the last_name in the csv' do
        expect(user_csv_row['last_name']).to eq(user.last_name)
      end

      it 'includes the telephone in the csv' do
        expect(user_csv_row['telephone']).to eq(user.telephone)
      end

      it 'includes the email_address in the csv' do
        expect(user_csv_row['email_address']).to eq(user.email_address)
      end

      it 'includes the sold_to in the csv' do
        expect(user_csv_row['sold_to']).to eq(sold_to)
      end

      it 'includes the default_sold_to in the csv' do
        expect(user_csv_row['default_sold_to']).to eq(sold_to)
      end
    end

    context 'when the devices are centrally managed' do
      let(:user) { create(:local_authority_user, :relevant_to_computacenter, :with_a_confirmed_techsource_account) }
      let(:sold_to) { user.responsible_body.sold_to }

      it 'includes the sold_to in the csv' do
        expect(user_csv_row['sold_to']).to eq(sold_to)
      end

      it 'has a default_sold_to value equal to the rb sold_to' do
        expect(user_csv_row['default_sold_to']).to eq(sold_to)
      end
    end

    context 'when the user is associated with an rb and a further education college', :delayed_service_call do
      let(:user) { create(:fe_college_user, :relevant_to_computacenter, :with_a_confirmed_techsource_account) }
      let(:rb) { create(:local_authority) }
      let(:sold_to) { user.sold_tos.join('|') }
      let(:default_sold_to) { user.responsible_body.sold_to }

      before do
        user.responsible_body = rb
        user.save!
        service_call
      end

      it 'includes the sold_to in the csv' do
        expect(user_csv_row['sold_to']).to eq(sold_to)
      end

      it 'has a default_sold_to value equal to the rb sold_to' do
        expect(user_csv_row['default_sold_to']).to eq(default_sold_to)
      end
    end
  end
end
