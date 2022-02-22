class SummaryListComponentPreview < ViewComponent::Preview
  def one_row
    rows = [
      key: 'Name',
      value: 'Lando Calrissian',
      action: 'Name',
      change_path: '/some/url',
    ]

    render(SummaryListComponent.new(rows:))
  end

  def multiple_rows
    rows = []

    rows << {
      key: 'Name',
      value: 'Lando Calrissian',
      action: 'Name',
      change_path: '/some/url',
    }

    rows << {
      key: 'Email',
      value: 'lando@example.com',
      action: 'Email',
      change_path: '/some/url',
    }

    render(SummaryListComponent.new(rows:))
  end
end
