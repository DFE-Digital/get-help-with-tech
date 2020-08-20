require 'csv'

class LocalAuthority < ResponsibleBody
  enum organisation_type: {
    borough: 'BGH',
    city: 'CIT',
    city_corporation: 'CC',
    combined_authority: 'COMB',
    council_area: 'CA',
    county: 'CTY',
    district: 'DIS',
    london_borough: 'LBO',
    metropolitan_district: 'MD',
    non_metropolitan_district: 'NMD',
    strategic_regional_authority: 'SRA',
    unitary_authority: 'UA',
  }

  validates :organisation_type, presence: true

  def address_1
    enriched_data['Address Line 1']
  end

  def address_2
    enriched_data['Address Line 2']
  end

  def address_3
    enriched_data['Address Line 3']
  end

  def town
    enriched_data['Town/City']
  end

  def postcode
    enriched_data['Postcode']
  end

  def gias_id
    enriched_data['Local Authority GIAS ID']
  end

private

  def enriched_data
    (@@enriched_data ||= load_enriched_data) # rubocop:disable Style/ClassVars
      .detect { |row| row['Local Authority ENG'] == local_authority_eng }
  end

  def load_enriched_data
    CSV.read('config/local_authority_data.csv', headers: true)
  end
end
