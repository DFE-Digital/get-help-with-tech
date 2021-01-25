class Mno::FindRequestsForm
  include ActiveModel::Model

  attr_accessor :phone_numbers

  validates :phone_numbers, presence: { message: 'Enter the telephone numbers, one per line' }

  def initialize(args = {})
    @phone_numbers = args[:phone_numbers]
  end

  def phone_number_list
    @phone_number_list ||= parse_phone_numbers
  end

private

  def parse_phone_numbers
    return [] if phone_numbers.blank?
    phone_numbers.split("\r\n").map(&:strip).reject(&:blank?).map { |num| Phonelib.parse(num).national(false) }
  end
end
