class StageTrustData
  attr_reader :datasource

  def initialize(trust_datasource = GetInformationAboutSchools)
    @datasource = trust_datasource
  end

  def import_trusts
    datasource.trusts do |trust_data|
      trust = DataStage::Trust.find_by(companies_house_number: trust_data[:companies_house_number])

      if trust
        trust.update!(trust_data)
      else
        DataStage::Trust.create!(trust_data)
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.message)
    end
    DataStage::DataUpdateRecord.staged!(:trusts)
  end
end
