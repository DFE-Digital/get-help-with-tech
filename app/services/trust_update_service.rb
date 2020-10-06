class TrustUpdateService
  def update_trusts
    # look at the trusts that have changed since the last update
    last_update = DataStage::DataUpdateRecord.last_update_for(:trusts)

    # simple updates for trusts that are open
    DataStage::Trust.updated_since(last_update).open.each do |staged_trust|
      trust = Trust.find_by(companies_house_number: staged_trust.companies_house_number)
      if trust
        update_trust(trust, staged_trust)
      else
        create_trust(staged_trust)
      end
    end

    DataStage::DataUpdateRecord.updated!(:trusts)
  end

private

  def update_trust(trust, staged_trust)
    # update trust details
    attrs = staged_attributes(staged_trust)
    trust.update!(attrs)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end

  def create_trust(staged_trust)
    Trust.create!(staged_attributes(staged_trust))
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end

  def staged_attributes(staged_trust)
    staged_trust.attributes.except('id', 'status', 'created_at', 'updated_at')
  end
end
