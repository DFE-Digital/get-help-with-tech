require 'rails_helper'

RSpec.describe AnonymiseExtraMobileDataRequestsJob, type: :job do
  describe '#perform' do
    context 'different names and different numbers' do
      let!(:request1) { create(:extra_mobile_data_request) }
      let!(:name1) { request1.account_holder_name }
      let!(:mobile_number1) { request1.device_phone_number }

      let!(:request2) { create(:extra_mobile_data_request) }
      let!(:name2) { request2.account_holder_name }
      let!(:mobile_number2) { request2.device_phone_number }

      before do
        described_class.new.perform_now
        request1.reload
        request2.reload
      end

      specify { expect(request1).to be_valid }
      specify { expect(request1.account_holder_name).not_to eq(name1) }
      specify { expect(request1.device_phone_number).not_to eq(mobile_number1) }

      specify { expect(request2).to be_valid }
      specify { expect(request2.account_holder_name).not_to eq(name2) }
      specify { expect(request2.device_phone_number).not_to eq(mobile_number2) }
    end

    context 'same number' do
      let(:number) { '07777777777' }
      let(:request1_name) { 'Barry Butler' }
      let(:request2_name) { 'Mark Miller' }
      let!(:request1) { create(:extra_mobile_data_request, device_phone_number: number, account_holder_name: request1_name) }
      let!(:request2) { create(:extra_mobile_data_request, device_phone_number: number, account_holder_name: request2_name) }

      before do
        described_class.new.perform_now
        request1.reload
        request2.reload
      end

      specify { expect(request1.device_phone_number).not_to eq(number) }
      specify { expect(request2.device_phone_number).not_to eq(number) }
      specify { expect(request1.device_phone_number).to eq(request2.device_phone_number) }

      specify { expect(request1.account_holder_name).not_to eq(request1_name) }
      specify { expect(request2.account_holder_name).not_to eq(request2_name) }
      specify { expect(request1.account_holder_name).not_to eq(request2.account_holder_name) }
    end

    context 'same name' do
      let(:name) { 'Barry Butler' }
      let(:request1_number) { '07777777777' }
      let(:request2_number) { '07777777778' }

      let!(:request1) { create(:extra_mobile_data_request, device_phone_number: request1_number, account_holder_name: name) }
      let!(:request2) { create(:extra_mobile_data_request, device_phone_number: request2_number, account_holder_name: name) }

      before do
        described_class.new.perform_now
        request1.reload
        request2.reload
      end

      specify { expect(request1.device_phone_number).not_to eq(request1_number) }
      specify { expect(request2.device_phone_number).not_to eq(request2_number) }
      specify { expect(request1.device_phone_number).not_to eq(request2.device_phone_number) }

      specify { expect(request1.account_holder_name).not_to eq(name) }
      specify { expect(request2.account_holder_name).not_to eq(name) }
      specify { expect(request1.account_holder_name).to eq(request2.account_holder_name) }
    end

    context 'name normalises identically' do
      let(:name) { 'Barry Butler' }
      let(:equivalent_name) { 'BARRY BUTLER' }

      let!(:request1) { create(:extra_mobile_data_request, account_holder_name: name) }
      let!(:request2) { create(:extra_mobile_data_request, account_holder_name: equivalent_name) }

      before do
        described_class.new.perform_now
        request1.reload
        request2.reload
      end

      specify { expect(request1.account_holder_name).not_to eq(name) }
      specify { expect(request2.account_holder_name).not_to eq(equivalent_name) }
      specify { expect(request1.account_holder_name).to eq(request2.account_holder_name) }
    end

    context 'number normalises identically' do
      let(:number) { '07777 777 777' }
      let(:equivalent_number) { '07777777777' }

      let!(:request1) { create(:extra_mobile_data_request, device_phone_number: number) }
      let!(:request2) { create(:extra_mobile_data_request, device_phone_number: equivalent_number) }

      before do
        described_class.new.perform_now
        request1.reload
        request2.reload
      end

      specify { expect(request1.device_phone_number).not_to eq(number) }
      specify { expect(request2.device_phone_number).not_to eq(equivalent_number) }
      specify { expect(request1.device_phone_number).to eq(request2.device_phone_number) }
    end
  end
end
