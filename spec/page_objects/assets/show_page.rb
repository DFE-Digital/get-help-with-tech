module PageObjects
  module Assets
    class ShowPage < PageObjects::BasePage
      set_url '/assets/{id}'

      element :home_breadcrumb, 'li a.govuk-breadcrumbs__link[href="/"]'
      element :assets_breadcrumb, 'li a.govuk-breadcrumbs__link[href="/assets"]'

      element :title_header, 'h1.govuk-heading-xl'

      element :download_unlocker, 'dd.govuk-summary-list__value a.govuk-link'

      elements :attr_labels, 'dt.govuk-summary-list__key'
      elements :attr_values, 'dd.govuk-summary-list__value'
    end
  end
end
