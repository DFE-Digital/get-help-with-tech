class LandingPagesController < ApplicationController
  before_action :show_parent_carer_pupil_banner?

  layout 'page_with_toc'

  def digital_platforms
    @title = I18n.t!('landing_pages.digital_platforms.title')
    render
  end

  def edtech_demonstrator_programme
    @title = I18n.t!('landing_pages.edtech_demonstrator_programme.title')
    render
  end
end
