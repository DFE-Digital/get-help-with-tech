class UserCanOrderEvent < Event
  def message
    I18n.t(
      "#{@params[:type]}_event".to_sym,
      scope: [:events],
      school: @params[:school].name,
    )
  end
end
