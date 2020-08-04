module Govuk
  class MarkdownRenderer < ::Redcarpet::Render::HTML
    def header(text, header_level)
      heading_size = case header_level
                     when 1 then 'xl'
                     when 2 then 'l'
                     when 3 then 'm'
                     else 's' end

      id_attribute = @options[:with_toc_data] ? " id=\"#{text.parameterize}\"" : ''

      <<~HTML
        <h#{header_level}#{id_attribute} class="govuk-heading-#{heading_size}">#{text}</h#{header_level}>
      HTML
    end

    def paragraph(text)
      <<~HTML
        <p class="govuk-body-m">#{text}</p>
      HTML
    end

    def list(contents, list_type)
      if list_type == :unordered
        <<~HTML
          <ul class="govuk-list govuk-list--bullet">
            #{contents}
          </ul>
        HTML
      elsif list_type == :ordered
        <<~HTML
          <ol class="govuk-list govuk-list--number">
            #{contents}
          </ol>
        HTML
      else
        raise "Unexpected type #{list_type.inspect}"
      end
    end

    def link(link, title, content)
      title_attribute = title.present? ? " title=\"#{title}\"" : ''
      <<~HTML
        <a href="#{link}" class="govuk-link"#{title_attribute}>#{content}</a>
      HTML
    end

    def hrule
      <<~HTML
        <hr class="govuk-section-break govuk-section-break--xl govuk-section-break--visible">
      HTML
    end
  end
end
