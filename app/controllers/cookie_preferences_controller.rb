class CookiePreferencesController < ApplicationController
  def new
    @form = CookiePreferencesForm.new(cookie_consent_params)
  end

  def create
    @form = CookiePreferencesForm.new(cookie_consent_params)

    if @form.valid?
      cookies["consented-to-cookies"] = {
        value: cookie_consent_params[:cookie_consent],
        expires: Settings.cookie_consent.expiry_time_months.months.from_now
      }

      flash[:success] = I18n.t("cookie_preferences.success")
      redirect_to( params[:return_url] || '/' )
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def cookie_consent_params(opts = params)
    params.fetch(:cookie_preferences_form, {}).permit(:cookie_consent)
  end
end
