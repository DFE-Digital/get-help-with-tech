class AssetsService
  attr_accessor :setting, :serial_numbers

  def initialize(user:, setting: nil, serial_numbers: nil)
    @user = user
    @setting = setting
    @serial_numbers = serial_numbers
    @assets = nil
  end

  def assets
    return @assets if @assets
    return @assets = Pundit.policy_scope(@user, Asset).search_by_serial_numbers(@serial_numbers) if @serial_numbers

    @assets = Pundit.policy_scope(@user, Asset).owned_by(@setting)
  end

  def assets_csv
    csv_data = nil
    Asset.transaction do
      csv_data = support_user? ? assets.to_support_csv : assets.to_non_support_csv
      assets_requiring_updated_viewed_at = assets.select { |asset| should_update_first_viewed_at?(asset) }
      Pundit.policy_scope(@user, Asset).where(id: assets_requiring_updated_viewed_at.pluck(:id)).update_all(first_viewed_at: Time.zone.now)
    end

    csv_data
  end

  def assets_csv_via_email
    params = { user_id: @user.id }
    params.merge!({ serial_numbers: @serial_numbers.join(',') }) if @serial_numbers
    params.merge!({ setting_clazz: @setting.class.to_s, setting_id: @setting.id }) if @setting

    AssetExportJob.perform_later(**params)
  end

private

  def support_user?
    @user.is_support?
  end

  def should_update_first_viewed_at?(asset)
    !support_user? && !asset.viewed?
  end
end
