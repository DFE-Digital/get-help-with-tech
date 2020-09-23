class LandingPagesController < ApplicationController
  layout 'page_with_toc', only: [:get_support, :get_internet_access]

  def get_laptops_and_tablets; end

  def get_support;
    @title = I18n.t!('second_level_content.get_support.title')
    render
  end

  def get_internet_access
    @title = I18n.t!('second_level_content.get_internet_access.title')
    render
  end

  def digital_platforms; end

  def edtech_demonstrator_programme; end

private

  def get_page_meta_data
    I18n.t!('second_level_content').map do |page_id, page_metadata|
      {
        page_id: page_id,
        # path: devices_guidance_subpage_path(subpage_slug: page_id.to_s.dasherize),
        title: page_metadata[:title],
        # description: page_metadata[:description],
        # audience: page_metadata[:audience],
      }
    end
  end
end
