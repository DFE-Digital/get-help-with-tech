class GuideToCollectingMobileInformationController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :set_guide_navigation

  def privacy; end

private

  def set_guide_navigation
    @contents = contents
    current_index = @contents.find_index { |item| item[:path] == request.path }

    @contents[current_index][:active] = true
    @title = contents[current_index][:text]
  end

  def contents
    [
      {
        text: t('guide_to_collecting_mobile_information.privacy'),
        path: guide_to_collecting_mobile_information_privacy_path,
      },
    ]
  end
end
