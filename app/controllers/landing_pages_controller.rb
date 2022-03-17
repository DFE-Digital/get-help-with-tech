class LandingPagesController < ApplicationController
  layout 'page_with_toc'

  def digital_platforms
    @title = I18n.t!('landing_pages.digital_platforms.title')
    render
  end
end
