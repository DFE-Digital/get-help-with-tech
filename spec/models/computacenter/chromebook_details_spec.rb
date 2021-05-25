require 'rails_helper'

RSpec.describe Computacenter::ChromebookDetails do
  subject(:service) { described_class }

  describe '.to_csv' do
    let!(:chromebook_details) do
      create_list(:preorder_information, 5, :needs_chromebooks)
        .concat(create_list(:preorder_information, 2, :dont_know_they_need_chromebooks))
    end

    before { create_list(:preorder_information, 3, :does_not_need_chromebooks) }

    it 'has correct headers set' do
      rows = CSV.parse(service.to_csv)

      expect(rows[0]).to eql(Computacenter::ChromebookDetails::HEADERS)
    end

    it 'has correct number of rows' do
      rows = CSV.parse(service.to_csv)

      expect(rows.size).to be(8)
    end

    it 'includes all the chromebook details for will_need_chromebooks yes and i_dont_know only' do
      details = details_to_array
      rows = CSV.parse(service.to_csv)

      (1..7).each do |n|
        expect(rows[n]).to eql(details[n - 1])
      end
    end

    def details_to_array
      details = []
      chromebook_details.sort_by(&:updated_at).each do |cb|
        details << [
          cb.school.responsible_body.computacenter_identifier,
          cb.school.responsible_body.name,
          cb.school.name,
          cb.school.urn.to_s,
          cb.school_or_rb_domain,
          cb.recovery_email_address,
          cb.updated_at.utc.strftime('%d/%m/%Y'),
          cb.updated_at.utc.strftime('%R'),
        ]
      end
      details
    end
  end
end
