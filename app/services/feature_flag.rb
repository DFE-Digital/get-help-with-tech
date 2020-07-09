class FeatureFlag
  PERMANENT_SETTINGS = %i[
    http_basic_auth
    show_debug_info
    dfe_admin_ui
    rate_limiting
    public_account_creation
  ].freeze

  TEMPORARY_FEATURE_FLAGS = %i[
    static_guidance_only
    extra_mobile_data_offer
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
