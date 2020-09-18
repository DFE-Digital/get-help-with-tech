require 'rails_helper'

RSpec.describe Computacenter::ChromebookDetails do
  subject(:service) { described_class }

  describe '.to_csv' do
    let(:expected_headers) do
      [
        'Responsible Body URN',
        'Responsible Body Name',
        'School Name',
        'School URN',
        'Google Domain',
        'Valid Recovery Off Domain Email Address',
        'Date',
        'Time'
      ]
    end
    let(:chromebook_details) { create_list(:preorder_information, 5, :needs_chromebooks) }

    it 'has correct headers set' do
      rows = CSV.parse(service.to_csv)

      expect(rows[0]).to eql(expected_headers)
    end

    it 'includes all the chromebook details' do
      details = details_to_array
      rows = CSV.parse(service.to_csv)
      (1..5).each do |n|
        expect(rows[n]).to eql(details[n - 1])
      end
    end

    def details_to_array
      details = []
      chromebook_details.each do |cb| 
        details << [
          cb.school.responsible_body.computacenter_identifier,
          cb.school.responsible_body.name,
          cb.school.name,
          cb.school.urn.to_s,
          cb.school_or_rb_domain,
          cb.recovery_email_address,
          cb.updated_at.utc.strftime('%d/%m/%Y'),
          cb.updated_at.utc.strftime('%R')
        ]
      end
      details
    end
  end
end
