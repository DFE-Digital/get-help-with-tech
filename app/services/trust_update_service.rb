class TrustUpdateService
  def update_trusts(last_update: nil)
    # look at the trusts that have changed since the last update
    last_update ||= DataStage::DataUpdateRecord.last_update_for(:trusts)

    # create new trusts
    create_trusts

    # simple updates for trusts that are open
    update_open_trusts(last_update)

    # auto close trusts that have no schools
    # skip and notify sentry when a trust is closed and still has schools - needs investigation
    close_trusts(last_update)

    DataStage::DataUpdateRecord.updated!(:trusts)
  end

private

  def create_trusts
    existing_trust_ids = Trust.pluck(:companies_house_number)
    DataStage::Trust.where.not(companies_house_number: existing_trust_ids).find_each do |staged_trust|
      create_trust(staged_trust)
    end
  end

  def update_open_trusts(last_update)
    DataStage::Trust.updated_since(last_update).gias_status_open.each do |staged_trust|
      trust = Trust.find_by(companies_house_number: staged_trust.companies_house_number)

      next unless trust

      update_trust(trust, staged_trust)
    end
  end

  def close_trusts(last_update)
    trusts_with_schools = []

    DataStage::Trust.updated_since(last_update).gias_status_closed.each do |staged_trust|
      trust = Trust.find_by(companies_house_number: staged_trust.companies_house_number)

      next if !trust || trust.status == 'closed'

      if trust.schools.size.positive?
        trusts_with_schools << trust.id
        next
      end

      close_trust(trust)
    end

    return if trusts_with_schools.empty?

    Sentry.configure_scope do |scope|
      scope.set_context('TrustUpdateService#close_trusts', { trust_ids: trusts_with_schools })

      Sentry.capture_message('Skipped auto-closing Trusts as schools.size > 0')
    end
  end

  def update_trust(trust, staged_trust)
    attrs = staged_attributes(staged_trust)
    trust.update!(attrs)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end

  def create_trust(staged_trust)
    attrs = staged_attributes(staged_trust)
    Trust.create!(attrs)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end

  def close_trust(trust)
    trust.update!({ status: 'closed', computacenter_change: 'closed' })
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end

  def staged_attributes(staged_trust)
    staged_trust.attributes.except('id', 'created_at', 'updated_at')
  end
end
