module ActionView
  module Template::Handlers
    class Markdown
      def call(_template, source)
        @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(with_toc_data: true))
        "
        content_for :html_list_of_headings_links do
          #{wrap_in_a_div(rendered_table_of_contents_for(source)).inspect}.html_safe
        end
        #{wrap_in_a_div(@markdown.render(source)).inspect}.html_safe
        "
      end

    private

      def rendered_table_of_contents_for(source)
        @table_of_contents = Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC.new(nesting_level: 2))
        @table_of_contents
          .render(source)
          .html_safe
      end

      # this makes it easier to target the generated code with CSS
      def wrap_in_a_div(source)
        "<div class=\"app-styled-content\">#{source}</div>"
      end
    end
  end
end
