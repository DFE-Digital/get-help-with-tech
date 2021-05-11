class GuideToResettingWindowsLaptopsAndTabletsController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :set_guide_navigation

  def index; end

  def get_local_admin_and_bios_passwords; end

  def reset_the_bios_password; end

  def unlock_recovery_mode; end

  def reset_the_device; end

  def apply_your_own_settings; end

  def additional_support; end

private

  def set_guide_navigation
    @contents = contents
    current_index = @contents.find_index { |item| item[:path] == request.path }

    @contents[current_index][:active] = true
    @next_page = contents[current_index + 1] || false
    @prev_page = current_index.positive? ? contents[current_index - 1] : false
    @title = contents[current_index][:text]
  end

  def contents
    [
      {
        text: t('guide_to_resetting_windows_laptops_and_tablets.before_you_start'),
        path: guide_to_resetting_windows_laptops_and_tablets_path,
      },
      {
        text: t('guide_to_resetting_windows_laptops_and_tablets.get_local_admin_and_bios_passwords'),
        path: guide_to_resetting_windows_laptops_and_tablets_get_local_admin_and_bios_passwords_path,
      },
      {
        text: t('guide_to_resetting_windows_laptops_and_tablets.reset_the_bios_password'),
        path: guide_to_resetting_windows_laptops_and_tablets_reset_the_bios_password_path,
      },
      {
        text: t('guide_to_resetting_windows_laptops_and_tablets.unlock_recovery_mode'),
        path: guide_to_resetting_windows_laptops_and_tablets_unlock_recovery_mode_path,
      },
      {
        text: t('guide_to_resetting_windows_laptops_and_tablets.reset_the_device'),
        path: guide_to_resetting_windows_laptops_and_tablets_reset_the_device_path,
      },
      {
        text: t('guide_to_resetting_windows_laptops_and_tablets.apply_your_own_settings'),
        path: guide_to_resetting_windows_laptops_and_tablets_apply_your_own_settings_path,
      },
      {
        text: t('guide_to_resetting_windows_laptops_and_tablets.additional_support'),
        path: guide_to_resetting_windows_laptops_and_tablets_additional_support_path,
      },
    ]
  end
end
