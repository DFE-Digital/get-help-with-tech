require 'rails_helper'

RSpec.describe Computacenter::ShipToForm, type: :model do
  let(:school) { build(:school, computacenter_reference: '11') }

  subject(:form) { described_class.new }

  it do
    expect(form).to validate_numericality_of(:ship_to)
                      .only_integer
                      .with_message('Ship To must be a number')
  end

  it do
    expect(form).to validate_inclusion_of(:change_ship_to)
                      .in_array(%w[yes no])
                      .with_message('Tell us whether the Ship To number needs to change')
  end

  describe '#save' do
    before { stub_computacenter_outgoing_api_calls }

    context 'when the form is not valid' do
      subject(:save) { described_class.new(school:).save }

      it { is_expected.to be_falsey }

      specify do
        expect {
          save
        }.not_to change(school, :computacenter_reference).from('11')
      end

      it 'do not update caps on Computacenter' do
        expect_not_to_have_sent_caps_to_computacenter
      end
    end

    context 'when the school computacenter_reference cannot be updated' do
      let(:school) { create(:school, computacenter_reference: '11') }

      before { school.name = nil }

      subject(:save) { described_class.new(school:, ship_to: '1', change_ship_to: 'yes').save }

      it { is_expected.to be_falsey }

      it 'do not change the school computacenter_reference to the given one' do
        expect {
          save
        }.not_to change { School.find(school.id).computacenter_reference }.from('11')
      end

      it 'do not update caps on Computacenter' do
        expect_not_to_have_sent_caps_to_computacenter
      end
    end

    context 'when everything ok' do
      let(:school) { create(:school, laptops: [2, 2, 1], routers: [2, 2, 1], computacenter_reference: '11') }

      subject(:save) { described_class.new(school:, ship_to: '100', change_ship_to: 'yes').save }

      it { is_expected.to be_truthy }

      it 'change the school computacenter_reference to the given one' do
        expect {
          save
        }.to change { School.find(school.id).computacenter_reference }.from('11').to('100')
      end

      it 'update caps on Computacenter' do
        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '100', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '100', 'capAmount' => '1' },
          ],
        ]

        expect(save).to be_truthy

        expect_to_have_sent_caps_to_computacenter(requests)
      end

      it 'do not notify Computacenter by email' do
        expect { save }.not_to have_enqueued_mail(ComputacenterMailer)
      end

      it 'do not notify the school' do
        expect { save }.not_to have_enqueued_mail.with(CanOrderDevicesMailer)
      end
    end
  end
end
