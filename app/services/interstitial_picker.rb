class InterstitialPicker
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def call
    @call ||= if user.associated_schools.where(increased_sixth_form_feature_flag: true).any? # (&:can_order_devices_right_now?) # enable after user research
                OpenStruct.new(
                  title: 'You can now order laptops and tablets for students in years 12 and 13',
                  partial: 'interstitials/increased_sixth_form_allocation',
                )
              elsif user.associated_schools.where(increased_fe_feature_flag: true).any? # (&:can_order_devices_right_now?) # enable after user research
                OpenStruct.new(
                  title: 'You can now order laptops and tablets for learners in further education',
                  partial: 'interstitials/increased_fe_allocation',
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
    i18n_key = user.is_school_user? || (user.is_responsible_body_user? && !user.is_a_single_academy_trust_user?) ? :related_organisation : :standard
    I18n.t(i18n_key, scope: %i[page_titles click_to_sign_in], organisation: user.organisation_name)
  end
end
