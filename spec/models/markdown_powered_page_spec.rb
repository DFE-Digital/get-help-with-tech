require 'rails_helper'

RSpec.describe MarkdownPoweredPage, type: :model do
  let(:example_markdown) do
    <<~MARKDOWN
      # My page
      ## Heading A
      Some text
      ### Subheading i
      More text
      ## Heading B
      Even more text
    MARKDOWN
  end

  before do
    @markdown_file = Tempfile.new
    @markdown_file.write(example_markdown)
    @markdown_file.close
  end

  after do
    @markdown_file.unlink
  end

  subject(:page) do
    MarkdownPoweredPage.new(content_filename: @markdown_file.path)
  end

  it 'renders markdown into HTML with element ids' do
    expect(page.rendered_markdown).to include('<h1 id="my-page">My page</h1>')
    expect(page.rendered_markdown).to include('<h2 id="heading-a">Heading A</h2>')
    expect(page.rendered_markdown).to include('<h3 id="subheading-i">Subheading i</h3>')
    expect(page.rendered_markdown).to include('<h2 id="heading-b">Heading B</h2>')
  end

  it 'renders a table of contents with h1 and h2 elements' do
    expect(page.rendered_table_of_contents).to include('<a href="#my-page">My page</a>')
    expect(page.rendered_table_of_contents).to include('<a href="#heading-a">Heading A</a>')
    expect(page.rendered_table_of_contents).to include('<a href="#heading-b">Heading B</a>')
    expect(page.rendered_table_of_contents).not_to include('<a href="#subheading-i">Subheading i</a>')
  end
end
