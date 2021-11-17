require 'rails_helper'

RSpec.describe Computacenter::Ledger do
  subject(:service) { described_class.new }

  describe '#to_csv' do
    let(:expected_headers) do
      [
        'First Name',
        'Last Name',
        'Email',
        'Telephone',
        'Responsible Body',
        'Responsible Body URN',
        'CC Sold To Number',
        'School',
        'School URN',
        'CC Ship To Number',
        'Date of Update',
        'Time of Update',
        'Timestamp of Update',
        'Type of Update',
        'Original First Name',
        'Original Last Name',
        'Original Email',
        'Original Telephone',
        'Original Responsible Body',
        'Original Responsible Body URN',
        'Original CC Sold To Number',
        'Original School',
        'Original School URN',
        'Original CC Ship To Number',
      ]
    end

    it 'has correct headers set' do
      rows = CSV.parse(service.to_csv)

      expect(rows[0]).to eql(expected_headers)
    end

    context 'a new local authority user' do
      let!(:user_change) { create(:user_change, :new_local_authority_user) }

      it 'has correct data' do
        rows = CSV.parse(service.to_csv)

        expect(rows[1]).to eql([
          user_change.first_name,
          user_change.last_name,
          user_change.email_address,
          user_change.telephone,
          user_change.responsible_body,
          user_change.responsible_body_urn,
          user_change.cc_sold_to_number,
          nil,
          nil,
          nil,
          user_change.updated_at_timestamp.utc.strftime('%d/%m/%Y'),
          user_change.updated_at_timestamp.utc.strftime('%R'),
          user_change.updated_at_timestamp.utc.iso8601,
          'New',
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
        ])
      end
    end

    context 'when a school user changes telephone but not school' do
      let!(:user_change) { create(:user_change, :school_user, :school_unchanged, :changed_telephone) }

      it 'has correct data' do
        rows = CSV.parse(service.to_csv)
        expect(rows[1]).to eql([
          user_change.first_name,
          user_change.last_name,
          user_change.email_address,
          user_change.telephone,
          user_change.responsible_body,
          user_change.responsible_body_urn,
          user_change.cc_sold_to_number,
          user_change.school,
          user_change.school_urn,
          user_change.cc_ship_to_number,
          user_change.updated_at_timestamp.utc.strftime('%d/%m/%Y'),
          user_change.updated_at_timestamp.utc.strftime('%R'),
          user_change.updated_at_timestamp.utc.iso8601,
          'Change',
          nil,
          nil,
          nil,
          user_change.original_telephone,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
        ])
      end
    end

    context 'when a school user changes school' do
      let!(:user_change) { create(:user_change, :school_user, :school_changed) }

      it 'has correct data' do
        rows = CSV.parse(service.to_csv)
        expect(rows[1]).to eql([
          user_change.first_name,
          user_change.last_name,
          user_change.email_address,
          user_change.telephone,
          user_change.responsible_body,
          user_change.responsible_body_urn,
          user_change.cc_sold_to_number,
          user_change.school,
          user_change.school_urn,
          user_change.cc_ship_to_number,
          user_change.updated_at_timestamp.utc.strftime('%d/%m/%Y'),
          user_change.updated_at_timestamp.utc.strftime('%R'),
          user_change.updated_at_timestamp.utc.iso8601,
          'Change',
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          user_change.original_school,
          user_change.original_school_urn,
          user_change.original_cc_ship_to_number,
        ])
      end
    end

    context 'when data provided by users is not secure' do
      let!(:user_change) { create(:user_change, :school_user, :school_unchanged, :changed_telephone, telephone: '=cmd|’ /C notepad’!A1') }
      let(:secured_telephone) { "\"'=cmd|’ /C notepad’!A1\"" }

      it 'secure it' do
        rows = CSV.parse(service.to_csv)
        expect(rows[1]).to eql([
          user_change.first_name,
          user_change.last_name,
          user_change.email_address,
          secured_telephone,
          user_change.responsible_body,
          user_change.responsible_body_urn,
          user_change.cc_sold_to_number,
          user_change.school,
          user_change.school_urn,
          user_change.cc_ship_to_number,
          user_change.updated_at_timestamp.utc.strftime('%d/%m/%Y'),
          user_change.updated_at_timestamp.utc.strftime('%R'),
          user_change.updated_at_timestamp.utc.iso8601,
          'Change',
          nil,
          nil,
          nil,
          user_change.original_telephone,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
        ])
      end
    end
  end
end
