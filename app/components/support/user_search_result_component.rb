class Support::UserSearchResultComponent < ViewComponent::Base
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def unordered_list_of_orgs
    tag.ul(class: 'govuk-list') do
      safe_join(user.organisations.sort_by(&:name).map do |organisation|
        tag.li do
          organisation_link_or_text(organisation)
        end
      end)
    end
  end

private

  def organisation_link_or_text(organisation)
    case organisation
    when School
      govuk_link_to organisation.name, support_school_path(urn: organisation.urn)
    when ResponsibleBody
      govuk_link_to organisation.name, support_responsible_body_path(organisation)
    else
      organisation.name
    end
  end
end
