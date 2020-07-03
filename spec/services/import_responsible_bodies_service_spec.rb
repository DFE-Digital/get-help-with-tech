require 'rails_helper'

RSpec.describe ImportResponsibleBodiesService, type: :model do
  it 'imports each local authority only once' do
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

    ImportResponsibleBodiesService.new.import_local_authorities

    expect(LocalAuthority.count).to eq(2)

    local_authorities = LocalAuthority.all.order('local_authority_eng asc')
    expect(local_authorities.first.organisation_type).to eq('metropolitan_district')
    expect(local_authorities.first.local_authority_official_name).to eq('City of Bradford Metropolitan District Council')
    expect(local_authorities.first.local_authority_eng).to eq('BRD')
    expect(local_authorities.first.name).to eq('Bradford')

    expect(local_authorities.second.organisation_type).to eq('non_metropolitan_district')
    expect(local_authorities.second.local_authority_official_name).to eq('Teignbridge District Council')
    expect(local_authorities.second.local_authority_eng).to eq('TEI')
    expect(local_authorities.second.name).to eq('Teignbridge')

    # re-run import again to check idempotence
    ImportResponsibleBodiesService.new.import_local_authorities
    expect(LocalAuthority.count).to eq(2)
  end

  it 'imports single- and multi-academy trusts only once' do
    data = [
      'Group Name,Companies House Number,Group Type',
      'AAA,12345,Federation',
      'AA TRUST,67890,Single-academy trust',
      'ABC MAT,13579,Multi-academy trust',
    ].join("\n")

    stub_request(:get, GetInformationAboutSchools::URL)
      .to_return(body: data)

    ImportResponsibleBodiesService.new.import_trusts

    expect(Trust.count).to eq(2)

    trusts = Trust.all.order('name asc')
    expect(trusts.first.name).to eq('AA TRUST')
    expect(trusts.first.companies_house_number).to eq('67890')
    expect(trusts.first.organisation_type).to eq('single_academy_trust')

    expect(trusts.second.name).to eq('ABC MAT')
    expect(trusts.second.companies_house_number).to eq('13579')
    expect(trusts.second.organisation_type).to eq('multi_academy_trust')

    # re-run import again to check idempotence
    ImportResponsibleBodiesService.new.import_trusts
    expect(Trust.count).to eq(2)
  end
end
