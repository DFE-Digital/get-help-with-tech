class SearchSerialNumberParser
  attr_reader :serial_numbers

  def initialize(serial_numbers_string)
    @serial_numbers = serial_numbers_string.blank? ? [] : serial_numbers_string.split(/,|,\s+|\s+/).reject(&:blank?)
  end
end
