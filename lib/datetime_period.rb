class DatetimePeriod
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :start_at_string, :end_at_string

  validates :start_at_string, :end_at_string, presence: true
  validate :parseable_strings, :start_at_must_be_before_end_at

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def to_s
    "#{human_readable_datetime(range.first)}--#{human_readable_datetime(range.last)}"
  end

  def range
    start_at..end_at
  end

private

  def parseable_strings
    errors.add(:start_at_string) if start_at.nil?
    errors.add(:end_at_string) if end_at.nil?
  end

  def start_at_must_be_before_end_at
    errors.add(:start_at_string) unless start_at&.before?(end_at)
  end

  def start_at
    defined?(@start_at) ? @start_at : @start_at = parse_datetime_string_or_nil(start_at_string)
  end

  def end_at
    defined?(@end_at) ? @end_at : @end_at = parse_datetime_string_or_nil(end_at_string)
  end

  def parse_datetime_string_or_nil(string)
    Chronic.time_class = Time.zone
    Chronic.parse(string)
  end

  def human_readable_datetime(datetime)
    datetime.strftime('%FT%R')
  end
end
