require 'rails_helper'

RSpec.describe ActionView::Template::Handlers::Markdown, type: :model do
  subject(:handler) { described_class.new }

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

  let(:test_view_class) do
    Class.new do
      def initialize
        @content_for = {}
        @output_buffer = ActionView::OutputBuffer.new
      end

      def content_for(key)
        if block_given?
          @content_for[key] = yield
        else
          @content_for[key]
        end
      end
    end
  end

  let(:test_view) { test_view_class.new }
  let(:result) { test_view.instance_eval subject.call(ActionView::Template::Text.new(''), example_markdown) }

  it 'generates ruby code that renders markdown as HTML' do
    expect(result).to include('<p>Some text</p>')
    expect(result).to include('<p>More text</p>')
    expect(result).to include('<p>Even more text</p>')
  end

  it 'generates ruby code that renders markdown with headings as HTML headings with ids' do
    expect(result).to include('<h1 id="my-page">My page</h1>')
    expect(result).to include('<h2 id="heading-a">Heading A</h2>')
    expect(result).to include('<h3 id="subheading-i">Subheading i</h3>')
    expect(result).to include('<h2 id="heading-b">Heading B</h2>')
  end

  it 'generates ruby code that wraps the generated markdown in a div that can be targetted by CSS' do
    expect(result).to match(/<div class="app-styled-content">.*<\/div>/m)
  end

  it 'generates ruby code that sets the content_for block with a div-wrapped HTML list of links to the H1s and H2s' do
    result

    headings_links = test_view.content_for(:html_list_of_headings_links)

    expect(headings_links).to match(/<div class="app-styled-content">.*<\/div>/m)
    expect(headings_links).to include('<a href="#my-page">My page</a>')
    expect(headings_links).to include('<a href="#heading-a">Heading A</a>')
    expect(headings_links).to include('<a href="#heading-b">Heading B</a>')
    expect(headings_links).not_to include('<a href="#subheading-i">Subheading i</a>')
  end

  context 'when the markdown has ERB in it' do
    let(:example_markdown) do
      <<~MARKDOWN
        # My page
        ## Heading A
        Even more text <%= 1+2 %>
      MARKDOWN
    end

    it 'generates ruby code that evaluates ERB expressions in the markdown' do
      expect(result).to include('<h1 id="my-page">My page</h1>')
      expect(result).to include('<h2 id="heading-a">Heading A</h2>')
      expect(result).to include('<p>Even more text 3</p>')
    end

    it 'generates ruby code that sets the content_for block with a div-wrapped HTML list of links to the H1s and H2s' do
      result

      headings_links = test_view.content_for(:html_list_of_headings_links)

      expect(headings_links).to match(/<div class="app-styled-content">.*<\/div>/m)
      expect(headings_links).to include('<a href="#my-page">My page</a>')
      expect(headings_links).to include('<a href="#heading-a">Heading A</a>')
    end
  end
end
