require 'rails_helper'

RSpec.describe GetInformationAboutSchools, type: :model do
  it 'returns a filtered list of open single- and multi-academy trusts' do
    data = [
      'Group Name,Companies House Number,Group Type,Group Status',
      'AAA,12345,Federation,Open',
      'AA TRUST,67890,Single-academy trust,Open',
      'ABC MAT,13579,Multi-academy trust,Open',
      'ZZZ MAT,14725,Multi-academy trust,Closed',
    ].join("\n")

    stub_request(:get, GetInformationAboutSchools::URL)
      .to_return(body: data)

    entries = GetInformationAboutSchools.trusts_entries

    expect(entries.size).to eq(2)
    expect(entries.first).to eq({
      'Group Name' => 'AA TRUST',
      'Companies House Number' => '67890',
      'Group Type' => 'Single-academy trust',
      'Group Status' => 'Open',
    })
    expect(entries.second).to eq({
      'Group Name' => 'ABC MAT',
      'Companies House Number' => '13579',
      'Group Type' => 'Multi-academy trust',
      'Group Status' => 'Open',
    })
  end
end
