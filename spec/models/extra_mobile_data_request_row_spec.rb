require 'rails_helper'

RSpec.describe ExtraMobileDataRequestRow, type: :model do
  before do
    ['EE', 'O2', 'Tesco Mobile', 'Virgin Mobile', 'Three'].each do |brand|
      create(:mobile_network, brand: brand)
    end
  end

  subject(:row) do
    described_class.new(
      account_holder_name: 'Jane Smith',
      mobile_phone_number: '07123456789',
      mobile_network: 'Virgin Mobile',
      pay_monthly_or_payg: 'Pay monthly',
      has_someone_shared_the_privacy_statement_with_the_account_holder: true,
    )
  end

  it 'builds a request' do
    expect(row.build_request).to have_attributes(
      account_holder_name: 'Jane Smith',
      device_phone_number: '07123456789',
      mobile_network: MobileNetwork.find_by(brand: 'Virgin Mobile'),
      contract_type: 'pay_monthly',
      agrees_with_privacy_statement: true,
    )
  end
end
