class InterstitialPicker
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def call
    @call ||= if user.is_support? || user.is_mno_user?
                OpenStruct.new(
                  title: title_for_default,
                  partial: 'interstitials/default',
                )
              else
                OpenStruct.new(
                  title: title_for_default,
                  partial: 'interstitials/school_user',
                )
              end
  end

private

  def title_for_default
    i18n_key = user.is_school_user? || (user.is_responsible_body_user? && !user.is_a_single_school_user?) ? :related_organisation : :standard
    I18n.t(i18n_key, scope: %i[page_titles click_to_sign_in], organisation: user.organisation_name)
  end
end
