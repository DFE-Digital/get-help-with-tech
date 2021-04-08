class Support::RequestCompletionsForm
  include ActiveModel::Model

  attr_accessor :from, :to

  def initialize(params = {})
    @from = Chronic.parse params[:from]
    @to = Chronic.parse params[:to]
  end

  def dates_description
    if @from.present?
      if @to.present?
        "between #{@from.to_s(:govuk_date_and_time)} and #{@to.to_s(:govuk_date_and_time)}"
      else
        "since #{@from.to_s(:govuk_date_and_time)}"
      end
    else
      "up to #{(@to || Time.zone.now).to_s(:govuk_date_and_time)}"
    end
  end
end
