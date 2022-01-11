class FeatureFlag
  FEATURES = %i[
    display_sign_in_token_links
    gias_data_stage_pause
    half_term_delivery_suspension
    notify_cc_about_user_changes
    notify_when_cap_usage_decreases
    rate_limiting
    rb_level_access_notification
    show_component_previews
  ].freeze

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
