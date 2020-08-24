class SummaryListComponent < ViewComponent::Base
  validates :rows, presence: true

  def initialize(rows:)
    rows = transform_hash(rows) if rows.is_a?(Hash)
    @rows = rows
  end

  def any_row_has_action_or_change?
    @rows.select { |row| row.key?(:action) || row.key?(:change_path) }.any?
  end

private

  attr_reader :rows

  def transform_hash(row_hash)
    row_hash.map do |key, value|
      {
        key: key,
        value: value,
      }
    end
  end
end
