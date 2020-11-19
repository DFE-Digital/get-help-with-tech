module PageObjects
  module Support
    module Users
      class MatchingResponsibleBodiesPage < PageObjects::BasePage
        set_url '/support/users/{id}/responsible-bodies'

        element :associate_responsible_body_link, 'table.responsible-bodies tbody tr input[type=submit][value=Associate]'
        elements :responsible_bodies, 'table.responsible-bodies tbody tr'
        elements :responsible_body_names, 'table.responsible-bodies tbody tr td:first-child a'
      end
    end
  end
end
