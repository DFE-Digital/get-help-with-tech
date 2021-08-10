class TrustUpsertService
  ID_KEY = :companies_house_number

  attr_reader :attributes

  def initialize(attributes)
    @attributes = attributes
  end

  def call
    ActiveRecord::Base.transaction do
      upsert!(DataStage::Trust)
      upsert!(Trust)
    end
  rescue StandardError => e
    Rails.logger.error(e.message)
  end

private

  def identification
    { ID_KEY => attributes[ID_KEY] }
  end

  def upsert!(model)
    model.find_or_initialize_by(identification).update!(attributes)
  end
end
