class Computacenter::ServiceNowUserImportAPI::Error < StandardError
  attr_accessor :import_user_change_request

  def initialize(params = {})
    @import_user_change_request = params[:import_user_change_request]
    super
  end
end
