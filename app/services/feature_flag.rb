class FeatureFlag
  PERMANENT_SETTINGS = %i[
    show_debug_info
    rate_limiting
    public_account_creation
    sign_in_slack_notifications
    who_will_order_slack_notifications
    invite_slack_notifications
    rbs_can_manage_users
  ].freeze

  TEMPORARY_FEATURE_FLAGS = %i[
    update_computacenter_user_change
  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    ENV["FEATURES_#{feature_name}"] = 'active'
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    ENV["FEATURES_#{feature_name}"] = 'inactive'
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    ENV["FEATURES_#{feature_name}"] == 'active'
  end

  def self.inactive?(feature_name)
    !active?(feature_name)
  end
end
