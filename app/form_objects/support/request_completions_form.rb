class Support::RequestCompletionsForm
  include ActiveModel::Model

  attr_accessor :from, :to

  def initialize(params = {})
    Chronic.time_class = Time.zone
    @from = Chronic.parse params[:from]
    @to = Chronic.parse params[:to]
  end

  def dates_description
    if @from.present?
      if @to.present?
        "between #{localise_and_format(@from)} and #{localise_and_format(@to)}"
      else
        "since #{localise_and_format(@from)}"
      end
    else
      "up to #{localise_and_format(@to || Time.zone.now)}"
    end
  end

  def localise_and_format(datetime)
    datetime.localtime.to_s(:govuk_date_and_time)
  end
end
