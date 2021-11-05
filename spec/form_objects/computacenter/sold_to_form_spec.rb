require 'rails_helper'

RSpec.describe Computacenter::SoldToForm, type: :model do
  subject(:form) { described_class.new }

  let(:rb) do
    create(:local_authority,
           :manages_centrally,
           :vcap_feature_flag,
           computacenter_reference: '1000')
  end

  it do
    expect(form).to validate_numericality_of(:sold_to)
                      .only_integer
                      .with_message('Sold To must be a number')
  end

  it do
    expect(form).to validate_inclusion_of(:change_sold_to)
                      .in_array(%w[yes no])
                      .with_message('Tell us whether the Sold To number needs to change')
  end

  describe '#save' do
    before { stub_computacenter_outgoing_api_calls }

    context 'when the form is not valid' do
      subject(:save) { described_class.new(responsible_body: rb).save }

      it { is_expected.to be_falsey }

      it 'do not change the responsible body computacenter_reference to the given one' do
        expect {
          save
        }.not_to change { ResponsibleBody.find(rb.id).computacenter_reference }.from('1000')
      end

      it 'do not update caps on Computacenter' do
        expect_not_to_have_sent_caps_to_computacenter
      end
    end

    context 'when the responsible body computacenter_reference cannot be updated' do
      before { rb.organisation_type = nil }

      subject(:save) { described_class.new(responsible_body: rb, sold_to: '1', change_sold_to: 'yes').save }

      it { is_expected.to be_falsey }

      it 'do not change the responsible body computacenter_reference to the given one' do
        expect {
          save
        }.not_to change { ResponsibleBody.find(rb.id).computacenter_reference }.from('1000')
      end

      it 'do not update caps on Computacenter' do
        expect_not_to_have_sent_caps_to_computacenter
      end
    end

    context 'when everything ok' do
      subject(:save) do
        described_class.new(responsible_body: rb,
                            sold_to: '100',
                            change_sold_to: 'yes')
                       .save
      end

      before do
        create(:school,
               :manages_orders,
               laptops: [2, 2, 1],
               routers: [2, 2, 1],
               responsible_body: rb,
               computacenter_reference: '11')

        create(:school,
               :manages_orders,
               laptops: [2, 2, 1],
               routers: [2, 2, 1],
               responsible_body: rb,
               computacenter_reference: '12')
      end

      it { is_expected.to be_truthy }

      it 'change the responsible body computacenter_reference to the given one' do
        expect {
          save
        }.to change { ResponsibleBody.find(rb.id).computacenter_reference }.from('1000').to('100')
      end

      it 'update caps on Computacenter' do
        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '12', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '12', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '11', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '1' },
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
