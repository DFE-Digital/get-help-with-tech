class SummaryListComponent < ViewComponent::Base
  validates :rows, presence: true

  def initialize(rows:)
    rows = transform_hash(rows) if rows.is_a?(Hash)
    @rows = rows
  end

  # If there is a mix of rows with and without an action
  def has_mix_rows_with_and_without_actions?
    @rows.select { |row| row.key?(:action) || row.key?(:change_path) }.any?
  end

  def change_path?(row)
    row[:change_path]
  end

  def action_path?(row)
    row[:action_path]
  end

  # For rows without an action, but at least one other row does
  def no_action?(row)
    has_mix_rows_with_and_without_actions? && !(change_path?(row) || action_path?(row))
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
