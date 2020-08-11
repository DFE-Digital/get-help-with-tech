require 'rails_helper'

RSpec.describe ExtraMobileDataRequestSpreadsheet, type: :model do
  let(:file_path) { file_fixture('extra-mobile-data-requests.xlsx') }

  subject(:spreadsheet) { described_class.new(file_path) }

  before do
    ['EE', 'O2', 'Tesco Mobile', 'Virgin Mobile', 'Three'].each do |brand|
      create(:mobile_network, brand: brand)
    end
  end

  it 'imports reads requests from a spreadsheet' do
    requests = spreadsheet.requests

    expect(requests.size).to eq(5)

    expect(requests[0]).to have_attributes(
      account_holder_name: 'Jane Smith',
      device_phone_number: '07123456789',
      mobile_network: MobileNetwork.find_by(brand: 'Virgin Mobile'),
      contract_type: 'pay_monthly',
      agrees_with_privacy_statement: true,
    )
    expect(requests[1]).to have_attributes(
      account_holder_name: 'Bill Jones',
      device_phone_number: '07000222222',
      mobile_network: MobileNetwork.find_by(brand: 'O2'),
      contract_type: 'pay_as_you_go_payg',
      agrees_with_privacy_statement: true,
    )
    expect(requests[2]).to have_attributes(
      account_holder_name: 'Mary West',
      device_phone_number: '07111456789',
      mobile_network: MobileNetwork.find_by(brand: 'Tesco Mobile'),
      contract_type: 'pay_as_you_go_payg',
      agrees_with_privacy_statement: true,
    )
    expect(requests[3]).to have_attributes(
      account_holder_name: 'Arthur Radish',
      device_phone_number: '07722123123',
      mobile_network: MobileNetwork.find_by(brand: 'Virgin Mobile'),
      contract_type: 'pay_monthly',
      agrees_with_privacy_statement: true,
    )
    expect(requests[4]).to have_attributes(
      account_holder_name: 'Felicity Hamburger',
      device_phone_number: '07001234567',
      mobile_network: MobileNetwork.find_by(brand: 'Three'),
      contract_type: 'pay_as_you_go_payg',
      agrees_with_privacy_statement: false,
    )
  end
end
