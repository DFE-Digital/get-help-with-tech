module PageObjects
  module Support
    class ResponsibleBodyPage < PageObjects::BasePage
      set_url '/support/responsible-bodies{/id}'

      elements :users, '.user'
      elements :school_rows, '#responsible-body-schools tbody tr'
      elements :closed_school_rows, '#responsible-body-closed-schools tbody tr'
      elements :centrally_managed_stats, '#responsible-body-centrally-managed-stats li'
      element :invite_a_new_user_link, 'a[text()="Invite a new user"]'
    end
  end
end
