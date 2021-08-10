class StageTrustData
  attr_reader :datasource

  def initialize(trust_datasource = GetInformationAboutSchools)
    @datasource = trust_datasource
  end

  def import_trusts
    datasource.trusts do |trust_data|
      TrustUpsertService.new(trust_data).call
    end
    DataStage::DataUpdateRecord.staged!(:trusts)
  end
end
