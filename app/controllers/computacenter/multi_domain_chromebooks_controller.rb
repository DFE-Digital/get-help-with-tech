require 'csv'

class Computacenter::MultiDomainChromebooksController < Computacenter::BaseController
  def index
    @responsible_bodies = ResponsibleBody.managing_multiple_chromebook_domains.order(type: :asc, name: :asc)
    respond_to do |format|
      format.html { @show_download_link = @responsible_bodies.any? }
      format.csv { send_data csv_generator, filename: make_filename }
    end
  end

private

  def make_filename
    "multi-chromebook-domain-responsible-bodies-#{Time.zone.now.strftime('%Y%m%d')}.csv"
  end

  def csv_generator
    CSV.generate(headers: true) do |csv|
      csv << ['RB Type', 'RB Name', 'RB URN', 'Sold To']
      @responsible_bodies.each do |responsible_body|
        csv << [
          responsible_body.humanized_type,
          responsible_body.computacenter_name,
          responsible_body.computacenter_identifier,
          responsible_body.computacenter_reference,
        ].map { |value| CsvValueSanitiser.new(value).sanitise }
      end
    end
  end
end
