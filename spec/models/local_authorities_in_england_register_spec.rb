require 'rails_helper'

RSpec.describe LocalAuthoritiesInEnglandRegister, type: :model do
  it 'returns a list of local authorities that maintain schools' do
    stub_request(:get, LocalAuthoritiesInEnglandRegister::URL)
      .to_return(body: '
        {
          "BRD": {
            "index-entry-number": "11",
            "entry-number": "11",
            "entry-timestamp": "2016-10-21T16:11:20Z",
            "key": "BRD",
            "item": [
              {
                "local-authority-type": "MD",
                "official-name": "City of Bradford Metropolitan District Council",
                "local-authority-eng": "BRD",
                "name": "Bradford",
                "start-date": "1974-04-01"
              }
            ]
          },
          "SHF": {
            "index-entry-number": "64",
            "entry-number": "64",
            "entry-timestamp": "2016-10-21T16:11:20Z",
            "key": "SHF",
            "item": [{
              "local-authority-type": "MD",
              "official-name": "Sheffield City Council",
              "local-authority-eng": "SHF",
              "name": "Sheffield",
              "start-date": "1905-06-08"
            }]
          }
        }')

    entries = LocalAuthoritiesInEnglandRegister.local_authorities_that_maintain_schools

    expect(entries.size).to eq(2)
    expect(entries.first).to include({
      'local-authority-type' => 'MD',
      'official-name' => 'City of Bradford Metropolitan District Council',
      'local-authority-eng' => 'BRD',
      'name' => 'Bradford',
    })
    expect(entries.second).to include({
      'local-authority-type' => 'MD',
      'official-name' => 'Sheffield City Council',
      'local-authority-eng' => 'SHF',
      'name' => 'Sheffield',
    })
  end

  it 'filters out closed local authorities (those with an end-date)' do
    stub_request(:get, LocalAuthoritiesInEnglandRegister::URL)
      .to_return(body: '
        {
          "BKM": {
            "index-entry-number": "392",
            "entry-number": "392",
            "entry-timestamp": "2020-02-29T11:57:30Z",
            "key": "BKM",
            "item": [{
              "end-date": "2020-03-31",
              "local-authority-type": "CTY",
              "official-name": "Buckinghamshire County Council",
              "local-authority-eng": "BKM",
              "name": "Buckinghamshire",
              "start-date": "1905-06-19"
            }]
          }
        }')

    expect(LocalAuthoritiesInEnglandRegister.local_authorities_that_maintain_schools).to be_empty
  end

  it "filters out local authority types that don't maintain schools" do
    stub_request(:get, LocalAuthoritiesInEnglandRegister::URL)
      .to_return(body: '
        {
          "TEI": {
            "index-entry-number": "128",
            "entry-number": "128",
            "entry-timestamp": "2016-10-21T16:11:20Z",
            "key": "TEI",
            "item": [
              {
                "local-authority-type": "NMD",
                "official-name": "Teignbridge District Council",
                "local-authority-eng": "TEI",
                "name": "Teignbridge"
              }
            ]
          }
        }')

    entries = LocalAuthoritiesInEnglandRegister.local_authorities_that_maintain_schools

    expect(entries).to be_empty
  end
end
