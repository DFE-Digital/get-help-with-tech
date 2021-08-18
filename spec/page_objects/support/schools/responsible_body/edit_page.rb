module PageObjects
  module Support
    module School
      module ResponsibleBody
        class EditPage < PageObjects::BasePage
          set_url '/support/schools/{urn}/responsible-body/edit'

          element :school_name_header, 'h1.govuk-heading-xl span.govuk-caption-xl'

          element :new_responsible_body_selector_label, 'form#new_support_school_change_responsible_body_form label[for=support-school-change-responsible-body-form-responsible-body-id-field]'
          element :new_responsible_body_selector, 'select#support-school-change-responsible-body-form-responsible-body-id-field'

          element :submit, 'button[type=submit]'
        end
      end
    end
  end
end
