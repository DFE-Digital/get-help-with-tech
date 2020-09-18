class Computacenter::ChromebooksController < Computacenter::BaseController
  def index
    respond_to do |format|
      format.csv do
        render csv: Computacenter::ChromebookDetails.to_csv, filename: "computacenter-chromebooks-#{Time.zone.now.iso8601}"
      end
    end
  end
end
