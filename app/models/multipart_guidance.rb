require 'ostruct'

class MultipartGuidance
  def initialize(pages_metadata)
    @pages = pages_metadata.map { |page_metadata| OpenStruct.new(page_metadata) }
    interlink_pages
  end

  def all_pages
    @pages
  end

  def pages_for(audience:)
    all_pages.select { |page| page.audience.to_sym == audience.to_sym }
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

  def interlink_pages
    @pages.each_cons(2) do |p1, p2|
      p1.next = p2
      p2.previous = p1
    end
  end
end
