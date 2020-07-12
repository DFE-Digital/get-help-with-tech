class DevicesGuidance
  include Rails.application.routes.url_helpers

  def initialize
    pages_metadata = I18n.t!('devices_guidance')
    @pages = pages_metadata.map do |page_id, page_metadata|
      page_from(page_id, page_metadata)
    end
  end

  def find_by_slug(page_slug)
    page_id = page_slug.to_s.underscore.to_sym
    @pages.detect { |page| page.page_id == page_id }
  end

  def page_exists?(page_slug)
    page_id = page_slug.to_s.underscore.to_sym
    page_id.in?(@pages.map(&:page_id))
  end

private

  def page_from(page_id, metadata)
    MarkdownPoweredPage.new(
      page_id: page_id,
      title: metadata[:title],
      description: metadata[:description],
      path: path_given(page_id),
      content_filename: "app/views/devices_guidance/#{page_id}.md",
    )
  end

  def path_given(page_id)
    devices_guidance_subpage_path(subpage_slug: page_id.to_s.dasherize)
  end
end
