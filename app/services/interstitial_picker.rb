class InterstitialPicker
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def call
    @call ||= if user.la_funded_user? && user.is_responsible_body_user? && user.responsible_body.iss_provision&.device_allocations&.can_order_std_devices_now.present?
                OpenStruct.new(
                  title: 'Laptops and internet access for state-funded pupils in independent settings',
                  partial: 'interstitials/la_funded_rb_user',
                )
              elsif user.la_funded_user? && user.schools.iss_provision.first&.device_allocations&.can_order_std_devices_now.present?
                OpenStruct.new(
                  title: 'Get laptops for state-funded pupils at independent settings',
                  partial: 'interstitials/la_funded_user',
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
    i18n_key = user.is_school_user? || (user.is_responsible_body_user? && !user.is_a_single_school_user?) ? :related_organisation : :standard
    I18n.t(i18n_key, scope: %i[page_titles click_to_sign_in], organisation: user.organisation_name)
  end
end
