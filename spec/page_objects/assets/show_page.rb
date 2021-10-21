module PageObjects
  module Assets
    class ShowPage < PageObjects::BasePage
      set_url '/assets/{id}'

      element :home_breadcrumb, 'li a.govuk-breadcrumbs__link[href="/"]'
      element :assets_breadcrumb, 'li a.govuk-breadcrumbs__link[href="/assets"]'

      element :title_header, 'h1.govuk-heading-xl'

      elements :asset_detail_labels, 'table.asset-details th'
      elements :asset_secrets_labels, 'table.asset-secrets th'
      elements :asset_hardware_labels, 'table.asset-hardware th'

      elements :asset_detail_values, 'table.asset-details td'
      elements :asset_secrets_values, 'table.asset-secrets td'
      elements :asset_hardware_values, 'table.asset-hardware td'

      element :download_bios_unlocker_link, 'table.asset-secrets a.govuk-link'
    end
  end
end
