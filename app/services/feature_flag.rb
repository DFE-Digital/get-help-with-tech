class FeatureFlag
  PERMANENT_SETTINGS = %i[
    static_guidance_only
  ].freeze

  TEMPORARY_FEATURE_FLAGS = %i[

  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    ENV["FEATURES[#{feature_name}]"] = 'active'
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    ENV["FEATURES[#{feature_name}]"] = 'inactive'
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    ENV["FEATURES[#{feature_name}]"] == 'active'
  end
end
