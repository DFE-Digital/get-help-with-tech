class Support::ZendeskStatisticsController < Support::BaseController
  before_action { authorize :support }

  def index; end

  def macros
    service = ZendeskMacroExportService.new
    respond_to do |format|
      format.csv { send_data service.csv_generator, filename: service.filename }
    end
  end
end
