class CollectingMobileInfoGuideController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :set_guide_navigation

  def index; end

  def asking_for_network; end

  def asking_for_account_holder; end

  def telling_about_offer; end

  def privacy; end

private

  def set_guide_navigation
    @contents = contents
    current_index = @contents.find_index { |item| item[:path] == request.path }

    @contents[current_index][:active] = true
    @next_page = contents[current_index + 1] || false
    @prev_page = contents[current_index - 1] || false
    @title = contents[current_index][:text]
  end

  def contents
    [
      {
        text: t('collecting_mobile_info_guide.overview'),
        path: collecting_mobile_info_guide_path,
      },
      {
        text: t('collecting_mobile_info_guide.asking_for_network'),
        path: collecting_mobile_info_guide_asking_for_network_path,
      },
      {
        text: t('collecting_mobile_info_guide.telling_about_offer'),
        path: collecting_mobile_info_guide_telling_about_offer_path,
      },
      {
        text: t('collecting_mobile_info_guide.asking_for_account_holder'),
        path: collecting_mobile_info_guide_asking_for_account_holder_path,
      },
      {
        text: t('collecting_mobile_info_guide.privacy'),
        path: collecting_mobile_info_guide_privacy_path,
      },
    ]
  end
end
