require 'rails_helper'

RSpec.describe ComputacenterMailer do
  let(:school) { create(:fe_school) }

  subject(:mailer) { described_class.new }

  describe '#notify_of_devices_cap_change' do
    context 'when FE school devices cap change' do
      let(:mail) { mailer.notify_of_devices_cap_change }
      let(:params_hash) do
        {
          school: school,
          new_cap_value: 10,
        }
      end

      before do
        mailer.params = params_hash
      end

      it 'renders the headers' do
        expect(mail.subject).to be_nil
        expect(mail.to).to eq([Settings.computacenter.notify_email_address])
      end

      it 'sends correct personalisation' do
        expected_hash = {
          new_cap_value: 10,
          responsible_body_name: school.name,
          responsible_body_reference: school.computacenter_identifier,
          responsible_body_type: 'FurtherEducationSchool',
          school_name: nil,
          ship_to_number: nil,
          sold_to_number: school.computacenter_reference,
          urn: nil,
        }

        expect(mail[:personalisation].unparsed_value).to eql(expected_hash)
      end
    end
  end
end
