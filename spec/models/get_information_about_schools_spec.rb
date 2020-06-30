require 'rails_helper'

RSpec.describe GetInformationAboutSchools, type: :model do
  it 'returns a filtered list of single- and multi-academy trusts' do
    data = [
      'Group Name,Companies House Number,Group Type',
      'AAA,12345,Federation',
      'AA TRUST,67890,Single-academy trust',
      'ABC MAT,13579,Multi-academy trust',
    ].join("\n")

    stub_request(:get, GetInformationAboutSchools::URL)
      .to_return(body: data)

    entries = GetInformationAboutSchools.trusts_entries

    expect(entries.size).to eq(2)
    expect(entries.first).to eq({
      'Group Name' => 'AA TRUST',
      'Companies House Number' => '67890',
      'Group Type' => 'Single-academy trust',
    })
    expect(entries.second).to eq({
      'Group Name' => 'ABC MAT',
      'Companies House Number' => '13579',
      'Group Type' => 'Multi-academy trust',
    })
  end
end
