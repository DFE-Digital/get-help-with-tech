class FeatureFlag
  PERMANENT_SETTINGS = %i[
    rate_limiting
    display_sign_in_token_links
    show_component_previews
    gias_data_stage_pause
  ].freeze

  TEMPORARY_FEATURE_FLAGS = %i[
    half_term_delivery_suspension
    donated_devices
    rb_level_access_notification
    notify_when_cap_usage_decreases
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

  def self.temporarily_activate(*feature_names)
    original_values = {}
    Array(feature_names).each do |name|
      original_values[name] = FeatureFlag.active?(name)
      activate(name)
    end
    return_value = yield
    feature_names.each { |name| FeatureFlag.deactivate(name) unless original_values[name] }
    return_value
  end

  def self.temporarily_deactivate(*feature_names)
    original_values = {}
    Array(feature_names).each do |name|
      original_values[name] = FeatureFlag.active?(name)
      deactivate(name)
    end
    return_value = yield
    feature_names.each { |name| FeatureFlag.activate(name) if original_values[name] }
    return_value
  end

  def self.set_temporary_flags(features = {})
    originally_active_status = features.map { |name, _| [name, FeatureFlag.active?(name)] }.to_h
    features.each do |name, value|
      FeatureFlag.activate(name) if value == 'active'
      FeatureFlag.deactivate(name) if value == 'inactive'
    end
    return_value = yield
    originally_active_status.each do |name, originally_active|
      originally_active ? FeatureFlag.activate(name) : FeatureFlag.deactivate(name)
    end
    return_value
  end
end
