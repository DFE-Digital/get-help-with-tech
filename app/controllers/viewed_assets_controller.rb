require 'datetime_period'

class ViewedAssetsController < ApplicationController
  before_action :require_sign_in!

  def new
    @title = 'Viewed devices CSV download'
    @datetime_period = DatetimePeriod.new
  end

  def index
    @datetime_period = DatetimePeriod.new(datetime_period_params)

    if @datetime_period.valid?
      @filename = filename(@datetime_period)
      @viewed_assets = policy_scope(Asset).first_viewed_during_period(@datetime_period.range)

      respond_to do |format|
        format.csv { send_data @viewed_assets.to_viewed_csv, filename: @filename }
      end
    end
  end

private

  def filename(period)
    "assets_first_viewed_during_#{period}.csv"
  end

  def datetime_period_params
    params.require(:datetime_period).permit(:start_at_string, :end_at_string)
  end
end
