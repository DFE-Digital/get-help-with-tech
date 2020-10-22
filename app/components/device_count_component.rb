class DeviceCountComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :max_count, :ordered_count, :action, :show_action, :show_availability, :body_i18n_key

  def initialize(max_count:,
                 ordered_count:,
                 show_action: true,
                 action: {},
                 show_availability: true,
                 body_i18n_key: 'components.device_count_component.default_body')
    @max_count = max_count
    @ordered_count = ordered_count
    @action = action
    @show_action = show_action
    @show_availability = show_availability
    @body_i18n_key = body_i18n_key
  end

  def show_availability?
    show_availability
  end

private

  def available_count
    max_count - ordered_count
  end
end
