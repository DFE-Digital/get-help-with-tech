require 'csv'

class Computacenter::MultiDomainChromebooksIssSclController < Computacenter::BaseController
  def index
    @schools = School
      .includes(:responsible_body)
      .gias_status_open
      .la_funded_provision
      .where(provision_type: %w[iss scl],
             will_need_chromebooks: %w[yes i_dont_know])
      .sort_by { |s| s.responsible_body.name }

    respond_to do |format|
      format.html { @show_download_link = @schools.any? }
      format.csv { send_data csv_generator, filename: make_filename }
    end
  end

private

  def make_filename
    "multi-chromebook-domain-responsible-bodies-iss-scl-#{Time.zone.now.strftime('%Y%m%d')}.csv"
  end

  def csv_generator
    CSV.generate(headers: true) do |csv|
      csv << ['RB Type', 'RB Name', 'RB URN', 'School URN', 'Sold To']
      @schools.each do |s|
        csv << [
          s.responsible_body.humanized_type,
          s.responsible_body.computacenter_name,
          s.responsible_body.computacenter_identifier,
          s.urn,
          s.responsible_body.computacenter_reference,
        ]
      end
    end
  end
end
