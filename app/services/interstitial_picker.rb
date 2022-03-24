class InterstitialPicker
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def call
    @call ||= if user.responsible_body_user?
                OpenStruct.new(
                  title: title_for_default,
                  partial: 'interstitials/responsible_body_user',
                )
              elsif user.is_school_user?
                OpenStruct.new(
                  title: title_for_default,
                  partial: 'interstitials/school_user',
                )
              else
                OpenStruct.new(
                  title: title_for_default,
                  partial: 'interstitials/default',
                )
              end
  end

private

  def title_for_default
    i18n_key = :related_organisation if user.is_school_user?
    i18n_key ||= :related_organisation if user.responsible_body_user? && !user.single_school_user?
    organisation_name = user.organisation_name if i18n_key == :related_organisation
    i18n_key = :standard unless organisation_name

    I18n.t(i18n_key, scope: %i[page_titles click_to_sign_in], organisation: organisation_name)
  end
end
