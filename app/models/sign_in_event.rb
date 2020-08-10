class SignInEvent < Event
  def notifiable?
    FeatureFlag.active?(:sign_in_slack_notifications) \
      && (@params[:user].is_mno_user? || @params[:user].is_responsible_body_user?)
  end

  def message
    I18n.t(
      :sign_in_event,
      scope: [:events],
      organisation: organisation_name(@params[:user]),
    )
  end
end
