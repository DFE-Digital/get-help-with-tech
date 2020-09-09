require 'rails_helper'

RSpec.describe PreorderInformation, type: :model do
  describe 'status' do
    context 'when the school orders devices and the school contact is missing' do
      subject do
        build(:preorder_information,
              who_will_order_devices: :school,
              school_contact: nil,
              school_contacted_at: nil).infer_status
      end

      it { is_expected.to eq('needs_contact') }
    end

    context "when the school orders devices, the school contact is present but hasn't been contacted yet" do
      subject do
        build(:preorder_information,
              who_will_order_devices: :school,
              school_contact: build(:school_contact),
              school_contacted_at: nil).infer_status
      end

      it { is_expected.to eq('school_will_be_contacted') }
    end

    context "when the school orders devices, it's been contacted but hasn't logged in to input the Chromebook details" do
      subject do
        build(:preorder_information,
              who_will_order_devices: :school,
              school_contact: build(:school_contact),
              school_contacted_at: Time.zone.now,
              will_need_chromebooks: nil).infer_status
      end

      it { is_expected.to eq('school_contacted') }
    end

    context "when the school orders devices, it has logged in and doesn't plan to order Chromebooks" do
      subject do
        build(:preorder_information,
              :does_not_need_chromebooks,
              who_will_order_devices: :school,
              school_contact: build(:school_contact),
              school_contacted_at: Time.zone.now).infer_status
      end

      it { is_expected.to eq('school_ready') }
    end

    context 'when the school orders devices, it has logged in and plans to order Chromebooks' do
      subject do
        build(:preorder_information,
              :needs_chromebooks,
              who_will_order_devices: :school,
              school_contact: build(:school_contact),
              school_contacted_at: Time.zone.now).infer_status
      end

      it { is_expected.to eq('school_ready') }
    end

    context 'when the orders are placed centrally and the responsible body has not provided Chromebook details' do
      subject do
        build(:preorder_information,
              who_will_order_devices: :responsible_body,
              will_need_chromebooks: nil).infer_status
      end

      it { is_expected.to eq('needs_info') }
    end

    context "when the orders are placed centrally and the responsible body doesn't plan to order Chromebooks" do
      subject do
        build(:preorder_information,
              :does_not_need_chromebooks,
              who_will_order_devices: :responsible_body).infer_status
      end

      it { is_expected.to eq('ready') }
    end

    context 'when the orders are placed centrally and the school has logged in and plans to order Chromebooks' do
      subject do
        build(:preorder_information,
              :needs_chromebooks,
              who_will_order_devices: :responsible_body).infer_status
      end

      it { is_expected.to eq('ready') }
    end
  end
end
