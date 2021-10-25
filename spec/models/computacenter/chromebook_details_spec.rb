require 'rails_helper'

RSpec.describe Computacenter::ChromebookDetails do
  subject(:service) { described_class }

  describe '.to_csv' do
    let!(:chromebook_details) { create_list(:school, 5, :needs_chromebooks) }

    before do
      create_list(:school, 2, :dont_know_they_need_chromebooks)
      create_list(:school, 3, :does_not_need_chromebooks)
    end

    it 'has correct headers set' do
      rows = CSV.parse(service.to_csv)

      expect(rows[0]).to eql(Computacenter::ChromebookDetails::HEADERS)
    end

    it 'has correct number of rows' do
      rows = CSV.parse(service.to_csv)

      expect(rows.size).to be(6)
    end

    it 'includes all the chromebook details for will_need_chromebooks yes' do
      details = details_to_array
      rows = CSV.parse(service.to_csv)

      (1..5).each do |n|
        expect(rows[n]).to eql(details[n - 1])
      end
    end

    def details_to_array
      details = []
      chromebook_details.sort_by(&:updated_at).each do |school|
        details << [
          school.responsible_body.computacenter_identifier,
          school.responsible_body.name,
          school.name,
          school.urn.to_s,
          school.school_or_rb_domain,
          school.recovery_email_address,
          school.updated_at.utc.strftime('%d/%m/%Y'),
          school.updated_at.utc.strftime('%R'),
        ]
      end
      details
    end
  end
end
