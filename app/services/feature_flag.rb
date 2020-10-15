class FeatureFlag
  PERMANENT_SETTINGS = %i[
    rate_limiting
    slack_notifications
  ].freeze

  TEMPORARY_FEATURE_FLAGS = %i[
    mno_offer
    notify_can_place_orders
    reduced_allocations
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
