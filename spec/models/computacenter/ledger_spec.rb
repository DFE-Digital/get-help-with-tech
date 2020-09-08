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
        'Original Email',
      ]
    end

    it 'has correct headers set' do
      rows = CSV.parse(service.to_csv)

      expect(rows[0]).to eql(expected_headers)
    end

    context 'when trust user' do
      let!(:user) { create(:trust_user, orders_devices: true) }

      it 'has correct data' do
        rows = CSV.parse(service.to_csv)

        expect(rows[1]).to eql([
          user.first_name,
          user.last_name,
          user.email_address,
          user.telephone,
          user.responsible_body.name,
          user.responsible_body.computacenter_identifier,
          user.responsible_body.computacenter_reference,
          nil,
          nil,
          nil,
          user.created_at.utc.strftime('%d/%m/%Y'),
          user.created_at.utc.strftime('%R'),
          user.created_at.utc.iso8601,
          'New',
          nil,
        ])
      end
    end

    context 'when school user' do
      let!(:user) { create(:school_user, orders_devices: true) }

      it 'has correct data' do
        rows = CSV.parse(service.to_csv)

        expect(rows[1]).to eql([
          user.first_name,
          user.last_name,
          user.email_address,
          user.telephone,
          user.school.responsible_body.name,
          user.school.responsible_body.computacenter_identifier,
          user.school.responsible_body.computacenter_reference,
          user.school.name,
          user.school.urn.to_s,
          user.school.computacenter_reference,
          user.created_at.utc.strftime('%d/%m/%Y'),
          user.created_at.utc.strftime('%R'),
          user.created_at.utc.iso8601,
          'New',
          nil,
        ])
      end
    end
  end
end
