# There's an issue with fieldsets & legends in GOVUKDesignSystemFormBuilder
# whereby legends go missing. This monkeypatch fixes the issue temporarily
# while they investigate
GOVUKDesignSystemFormBuilder::Containers::Fieldset.class_eval do
  def html(&block)
    content_tag('fieldset', class: fieldset_classes, aria: { describedby: @described_by }) do
      safe_join([build_legend, capture(&block)])
    end
  end
end
