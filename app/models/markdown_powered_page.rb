class MarkdownPoweredPage
  attr_reader :page_id, :title, :description, :path
  attr_accessor :next, :previous

  def initialize(page_id: nil, title: nil, description: nil, path: nil)
    @page_id = page_id
    @title = title
    @description = description
    @path = path
  end
end
