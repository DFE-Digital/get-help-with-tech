require 'csv'

class ResponsibleBodyExporter
  attr_reader :filename

  EXPORT_ATTRS = %i[
    name
    type
    local_authority_official_name
    local_authority_eng
    companies_house_number
  ].freeze

  def initialize(filename)
    @filename = filename
  end

  def export_responsible_bodies
    CSV.open(filename, 'w') do |csv|
      csv << headings
      responsible_bodies.each do |rb|
        csv << EXPORT_ATTRS.map do |attr|
          if attr == :type && rb.type == 'LocalAuthority'
            'Local Authority'
          else 
            rb.send(attr)
          end
        end
      end
    end
    nil
  end

private

  def headings
    EXPORT_ATTRS.map { |s| s.to_s.humanize.titlecase }
  end

  def responsible_bodies
    ResponsibleBody.where.not(name: 'Department for Education').order(type: :asc, name: :asc)
  end
end
