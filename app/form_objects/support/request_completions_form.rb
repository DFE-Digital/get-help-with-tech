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
        "between #{format_datetime(@from)} and #{format_datetime(@to)}"
      else
        "since #{format_datetime(@from)}"
      end
    else
      "up to #{format_datetime(@to || Time.zone.now)}"
    end
  end

  def format_datetime(d)
    d.localtime.to_s(:govuk_date_and_time)
  end
end
