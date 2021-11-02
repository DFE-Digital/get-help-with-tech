class SearchSerialNumberParser
  attr_reader :serial_numbers

  def initialize(serial_numbers_string:, multiple:)
    @serial_numbers = if serial_numbers_string.blank?
                        []
                      else
                        multiple ? serial_numbers_string.split(/,|,\s+|\s+/).reject(&:blank?) : [serial_numbers_string.strip]
                      end
  end
end
