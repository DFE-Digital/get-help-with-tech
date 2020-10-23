class LandingPagesController < ApplicationController
  layout 'page_with_toc'

  def edtech_demonstrator_programme
    @title = I18n.t!('landing_pages.edtech_demonstrator_programme.title')
    render
  end
end
