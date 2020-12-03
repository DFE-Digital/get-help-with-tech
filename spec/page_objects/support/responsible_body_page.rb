module PageObjects
  module Support
    class ResponsibleBodyPage < PageObjects::BasePage
      set_url '/support/responsible-bodies{/id}'

      elements :users, '.user'
      elements :school_rows, '#responsible-body-schools tbody tr'
      elements :centrally_managed_stats, '#responsible-body-centrally-managed-stats li'
    end
  end
end
