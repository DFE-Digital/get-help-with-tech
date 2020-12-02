require 'rails_helper'

RSpec.describe ComputacenterMailer do
  let(:school) { create(:fe_school) }

  describe '#notify_of_devices_cap_change' do
    context 'when FE school devices cap change' do
      let(:mail) { subject.notify_of_devices_cap_change }
      let(:params_hash) do
        {
          school: school,
          new_cap_value: 10
        }
      end

      before do
        allow(subject).to receive(:params) { params_hash }
      end

      it "renders the headers" do
        expect(mail.subject).to eq("Signup")
        expect(mail.to).to eq(["to@example.org"])
        expect(mail.from).to eq(["from@example.com"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hi")
      end
    end
  end
end
