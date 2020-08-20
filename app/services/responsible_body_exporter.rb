require 'csv'
require 'string_utils'

class ResponsibleBodyExporter
  attr_reader :filename

  class ResponsibleBodyRow
    include StringUtils

    def initialize(responsible_body)
      @responsible_body = responsible_body
    end

    def to_a
      name_parts = split_string(computacenter_name, limit: 35)

      [
        computacenter_identifier,
        name_parts[0],
        name_parts[1][0...35],
        @responsible_body.address_1,
        @responsible_body.address_2,
        @responsible_body.address_3,
        @responsible_body.town,
        @responsible_body.postcode,
      ]
    end

  private

    def computacenter_identifier
      case @responsible_body.type
      when "LocalAuthority"
        "LEA#{@responsible_body.gias_id}"
      when "Trust"
        "t#{@responsible_body.companies_house_number.to_i}"
      end
    end

    def computacenter_name
      case @responsible_body.type
      when "LocalAuthority"
        @responsible_body.computacenter_name
      when "Trust"
        @responsible_body.name
      end
    end
  end

  def initialize(filename)
    @filename = filename
  end

  def export_responsible_bodies
    CSV.open(filename, 'w') do |csv|
      csv << headings
      responsible_bodies.each do |rb|
        csv << ResponsibleBodyRow.new(rb).to_a
      end
    end
    nil
  end

private

  def headings
    [
      'Responsible body URN',
      'Responsible Body Name',
      'Responsible Body Name (overflow)',
      'Address line 1',
      'Address line 2',
      'Address line 3',
      'Town/City',
      'Postcode',
    ]
  end

  def responsible_bodies
    ResponsibleBody
      .where.not(name: 'Department for Education')
      .order(type: :asc, name: :asc)
  end
end
