class DeviceCountComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :max_count, :ordered_count, :action, :show_action

  def initialize(max_count:, ordered_count:, show_action: true, action: {})
    @max_count = max_count
    @ordered_count = ordered_count
    @action = action
    @show_action = show_action
  end

private

  def available_count
    max_count - ordered_count
  end
end
