class InterstitialPicker
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def call
    @call ||= if rb_user_with_la_funded_place_with_available_devices? || user_with_multiple_la_funded_places_with_available_devices?
                OpenStruct.new(
                  title: 'Laptops and internet access are available for more children and young people',
                  partial: 'interstitials/la_funded_user',
                )
              elsif iss_provision_user_with_available_devices?
                OpenStruct.new(
                  title: 'Get laptops and internet access',
                  partial: 'interstitials/iss_provision_user',
                )
              elsif scl_provision_user_with_available_devices?
                OpenStruct.new(
                  title: 'Get laptops and internet access',
                  partial: 'interstitials/scl_provision_user',
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

  def rb_user_with_la_funded_place_with_available_devices?
    user.la_funded_user? && user.responsible_body_user? && user.responsible_body.schools.la_funded_provision.any?(&:has_not_fully_ordered_laptops_now?)
  end

  def user_with_multiple_la_funded_places_with_available_devices?
    user.schools.la_funded_provision.count > 1 && user.schools.la_funded_provision.any?(&:has_not_fully_ordered_laptops_now?)
  end

  def iss_provision_user_with_available_devices?
    user.iss_provision_user? && user.schools.iss_provision.first&.has_not_fully_ordered_laptops_now?
  end

  def scl_provision_user_with_available_devices?
    user.scl_provision_user? && user.schools.scl_provision.first&.has_not_fully_ordered_laptops_now?
  end

  def title_for_default
    i18n_key = :related_organisation if user.is_school_user?
    i18n_key ||= :related_organisation if user.responsible_body_user? && !user.single_school_user?
    organisation_name = user.organisation_name if i18n_key == :related_organisation
    i18n_key = :standard unless organisation_name

    I18n.t(i18n_key, scope: %i[page_titles click_to_sign_in], organisation: organisation_name)
  end
end
