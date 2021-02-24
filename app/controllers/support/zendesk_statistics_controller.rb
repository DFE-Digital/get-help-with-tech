class Support::ZendeskStatisticsController < Support::BaseController
  before_action { authorize :support }

  def index; end

  def macros
    service = ZendeskMacroExportService.new
    service.csv_generator

    if service.valid?
      respond_to do |format|
        format.csv { send_data service.data, filename: service.filename }
      end
    else
      flash[:warning] = service.message
      redirect_to support_zendesk_statistics_path
    end
  end
end
