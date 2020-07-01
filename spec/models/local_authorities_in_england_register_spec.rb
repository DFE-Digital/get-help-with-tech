require 'rails_helper'

RSpec.describe LocalAuthoritiesInEnglandRegister, type: :model do
  it 'returns a list of entries' do
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

    entries = LocalAuthoritiesInEnglandRegister.entries

    expect(entries.size).to eq(2)
    expect(entries.first).to include({
      'local-authority-type' => 'MD',
      'official-name' => 'City of Bradford Metropolitan District Council',
      'local-authority-eng' => 'BRD',
      'name' => 'Bradford',
    })
    expect(entries.second).to include({
      'local-authority-type' => 'NMD',
      'official-name' => 'Teignbridge District Council',
      'local-authority-eng' => 'TEI',
      'name' => 'Teignbridge',
    })
  end
end
