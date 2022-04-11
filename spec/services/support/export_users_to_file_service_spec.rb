require 'rails_helper'

RSpec.describe Support::ExportUsersToFileService, type: :model do
  describe '#call' do
    let(:user) { create(:school_user) }
    let(:filename) { Rails.root.join('tmp/support_export_users_test_data.csv') }
    let(:csv) { CSV.read(filename, headers: true) }
    let(:expected_headers) { Support::UserReport.headers }
    let(:relevent_user_count) { User.count }
    let(:user_csv_row) { csv[0] }
    let(:user_ids) { User.ids }
    let(:service_call) { service.call }
    let(:sold_to) { user.school.sold_to }

    after do
      remove_file(filename)
    end

    subject(:service) { described_class.new(filename, user_ids:) }

    before do
      user
      service_call
    end

    context 'when given a filename' do
      it 'creates a CSV file' do
        expect(File.exist?(filename)).to be true
      end

      it 'includes a heading row and all relevant Users in the CSV file' do
        line_count = `wc -l "#{filename}"`.split.first.to_i
        expect(line_count).to eq(relevent_user_count + 1)
      end

      it 'includes the correct headers' do
        expect(csv.headers).to match_array(expected_headers)
      end
    end

    context 'when the user belongs to a school' do
      it 'includes the full_name in the csv' do
        expect(user_csv_row['full_name']).to eq(user.full_name)
      end

      it 'includes the email_address in the csv' do
        expect(user_csv_row['email_address']).to eq(user.email_address)
      end

      it 'includes the school_name in the csv' do
        expect(user_csv_row['school_name']).to eq(user.school&.name)
      end

      it 'includes the school_urn in the csv' do
        expect(user_csv_row['school_urn']).to eq(user.school.urn.to_s)
      end

      it 'as is_support set to false' do
        expect(user_csv_row['is_support']).to eq('false')
      end

      it 'as is_computacenter set to false' do
        expect(user_csv_row['is_computacenter']).to eq('false')
      end
    end

    context 'when the user belongs to an rb' do
      let(:user) { create(:local_authority_user) }
      let(:rb) { user.rb }

      it 'includes the user_rb_name in the csv' do
        expect(user_csv_row['user_rb_name']).to eq(rb.local_authority_official_name)
      end

      it 'includes the user_rb_gias_id in the csv' do
        expect(user_csv_row['user_rb_gias_id']).to eq(rb.gias_id)
      end
    end

    context 'when the user is a support user' do
      let(:user) { create(:support_user) }

      it 'as is_support set to false' do
        expect(user_csv_row['is_support']).to eq('true')
      end

      it 'as is_computacenter set to false' do
        expect(user_csv_row['is_computacenter']).to eq('false')
      end
    end

    context 'when the user is a supplier user' do
      let(:user) { create(:computacenter_user) }

      it 'as is_support set to false' do
        expect(user_csv_row['is_support']).to eq('false')
      end

      it 'as is_computacenter set to false' do
        expect(user_csv_row['is_computacenter']).to eq('true')
      end
    end
  end
end
