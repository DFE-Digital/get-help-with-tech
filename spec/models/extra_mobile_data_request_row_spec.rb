require 'rails_helper'

RSpec.describe ExtraMobileDataRequestRow, type: :model do
  before do
    ['EE', 'O2', 'Tesco Mobile', 'Virgin Mobile', 'Three'].each do |brand|
      create(:mobile_network, brand:)
    end
  end

  let(:valid_input_data) do
    {
      account_holder_name: 'Jane Smith',
      mobile_phone_number: '07123456789',
      mobile_network: 'Virgin Mobile',
      pay_monthly_or_payg: 'Pay monthly',
      has_someone_shared_the_privacy_statement_with_the_account_holder: true,
    }
  end

  it 'builds a valid ExtraMobileDataRequest from a valid input row' do
    row = described_class.new(valid_input_data)

    expect(row.build_request).to have_attributes(
      account_holder_name: 'Jane Smith',
      device_phone_number: '07123456789',
      mobile_network: MobileNetwork.find_by(brand: 'Virgin Mobile'),
      contract_type: 'pay_monthly',
      agrees_with_privacy_statement: true,
    )
  end

  it 'builds an ExtraMobileDataRequest with a nil contract_type from an invalid input contract type' do
    invalid_input_data = valid_input_data.merge(pay_monthly_or_payg: 'invalid')

    row = described_class.new(invalid_input_data)

    expect(row.build_request.contract_type).to be_nil
  end

  it 'builds an ExtraMobileDataRequest with a nil mobile network from an invalid network name in the input' do
    invalid_input_data = valid_input_data.merge(mobile_network: 'invalid')

    row = described_class.new(invalid_input_data)

    expect(row.build_request.mobile_network).to be_nil
  end
end
