module ActionView
  module Template::Handlers
    class Markdown
      def call(template, source)
        compiled_source = erb.call(template, source)

        <<~CODE
          content_for :html_list_of_headings_links do
            ('<div class="app-styled-content">' +
              #{rendered_table_of_contents_for(compiled_source).inspect} +
            '</div>').html_safe
          end
          '<div class="app-styled-content">' +
            Redcarpet::Markdown.new(
              Redcarpet::Render::HTML.new(with_toc_data: true)
            ).render(
              begin;#{compiled_source};end
            ).html_safe +
          '</div>'
        CODE
      end

    private

      def erb
        @erb ||= ActionView::Template.registered_template_handler(:erb)
      end

      def rendered_table_of_contents_for(compiled_source)
        @output_buffer = ActionView::OutputBuffer.new # needed for the eval
        erb_output = instance_eval(compiled_source)

        Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC.new(nesting_level: 2))
          .render(erb_output)
          .html_safe
      end
    end
  end
end
