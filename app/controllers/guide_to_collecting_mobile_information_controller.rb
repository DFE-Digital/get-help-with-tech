class GuideToCollectingMobileInformationController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :set_guide_navigation

  def index
    render_content_page
  end

  def asking_for_network
    render_content_page
  end

  def asking_for_account_holder
    render_content_page
  end

  def telling_about_offer
    render_content_page
  end

  def privacy
    render_content_page
  end

private

  def render_content_page
    @converted_markdown = rendered_markdown
    render 'guide_page'
  end

  def rendered_markdown
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new())
      .render(File.read("app/views/guide_to_collecting_mobile_information/#{action_name}.md"))
      .html_safe
  end

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
        text: t('guide_to_collecting_mobile_information.overview'),
        path: guide_to_collecting_mobile_information_path,
      },
      {
        text: t('guide_to_collecting_mobile_information.asking_for_network'),
        path: guide_to_collecting_mobile_information_asking_for_network_path,
      },
      {
        text: t('guide_to_collecting_mobile_information.telling_about_offer'),
        path: guide_to_collecting_mobile_information_telling_about_offer_path,
      },
      {
        text: t('guide_to_collecting_mobile_information.privacy'),
        path: guide_to_collecting_mobile_information_privacy_path,
      },
      {
        text: t('guide_to_collecting_mobile_information.asking_for_account_holder'),
        path: guide_to_collecting_mobile_information_asking_for_account_holder_path,
      },
    ]
  end
end
