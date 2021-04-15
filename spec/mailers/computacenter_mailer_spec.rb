require 'rails_helper'

RSpec.describe ComputacenterMailer do
  subject(:mailer) { described_class.new }

  # rubocop:disable RSpec/SubjectStub
  # Otherwise not able to inject custom params
  describe '#notify_of_devices_cap_change' do
    context 'when shipTo and soldTo not set' do
      let(:school) { build(:school, computacenter_reference: nil, responsible_body: rb) }
      let(:rb) { build(:trust, computacenter_reference: nil) }

      before do
        allow(mailer).to receive(:params).and_return({ school: school })
      end

      it 'displays Not set' do
        mail = mailer.notify_of_devices_cap_change
        expect(mail[:personalisation].unparsed_value[:ship_to_number]).to eq('Not set')
        expect(mail[:personalisation].unparsed_value[:sold_to_number]).to eq('Not set')
      end
    end
  end

  describe '#notify_of_comms_cap_change' do
    context 'when shipTo and soldTo not set' do
      let(:school) { build(:school, computacenter_reference: nil, responsible_body: rb) }
      let(:rb) { build(:trust, computacenter_reference: nil) }

      before do
        allow(mailer).to receive(:params).and_return({ school: school })
      end

      it 'displays Not set' do
        mail = mailer.notify_of_comms_cap_change
        expect(mail[:personalisation].unparsed_value[:ship_to_number]).to eq('Not set')
        expect(mail[:personalisation].unparsed_value[:sold_to_number]).to eq('Not set')
      end
    end
  end

  describe '#notify_of_school_can_order' do
    context 'when shipTo and soldTo not set' do
      let(:school) { build(:school, computacenter_reference: nil, responsible_body: rb) }
      let(:rb) { build(:trust, computacenter_reference: nil) }

      before do
        allow(mailer).to receive(:params).and_return({ school: school })
      end

      it 'displays Not set' do
        mail = mailer.notify_of_school_can_order
        expect(mail[:personalisation].unparsed_value[:ship_to_number]).to eq('Not set')
        expect(mail[:personalisation].unparsed_value[:sold_to_number]).to eq('Not set')
      end
    end
  end
  # rubocop:enable RSpec/SubjectStub
end
