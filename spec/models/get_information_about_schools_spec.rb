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

    stub_request(:get, GetInformationAboutSchools.groups_url)
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

  describe '.groups_url' do
    it 'returns the groups file url for the date specified' do
      t = Time.zone.now
      file = "allgroupsdata#{t.strftime('%Y%m%d')}.csv"
      url = GetInformationAboutSchools.groups_url(date: t)
      expect(url).to end_with(file)
    end
  end

  describe '.schools_url' do
    it 'returns the schools file url for the date specified' do
      t = Time.zone.now
      file = "edubasealldata#{t.strftime('%Y%m%d')}.csv"
      url = GetInformationAboutSchools.schools_url(date: t)
      expect(url).to end_with(file)
    end
  end

  describe '.school_links_url' do
    it 'returns the school links file url for the date specified' do
      t = Time.zone.now
      file = "links_edubasealldata#{t.strftime('%Y%m%d')}.csv"
      url = GetInformationAboutSchools.school_links_url(date: t)
      expect(url).to end_with(file)
    end
  end
end
