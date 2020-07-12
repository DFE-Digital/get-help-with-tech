class MarkdownPoweredPage
  attr_reader :page_id, :title, :description, :path
  attr_accessor :next, :previous

  def initialize(content_filename:, page_id: nil, title: nil, description: nil, path: nil)
    @page_id = page_id
    @title = title
    @description = description
    @path = path
    @content_filename = content_filename
  end

  def rendered_markdown
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(with_toc_data: true))
      .render(markdown_content)
      .html_safe
  end

  def rendered_table_of_contents
    renderer = Redcarpet::Render::HTML_TOC.new(nesting_level: 2)
    Redcarpet::Markdown.new(renderer)
      .render(markdown_content)
      .html_safe
  end

private

  def markdown_content
    @markdown_content ||= File.read(@content_filename)
  end
end
