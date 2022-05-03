class Computacenter::RawOrder < ApplicationRecord
  has_one :order, class_name: 'Computacenter::Order', inverse_of: :raw_order

  scope :processed, -> { where.not(processed_at: nil) }
  scope :unprocessed, -> { where(processed_at: nil) }
  scope :updated, -> { processed.where("processed_at < date_trunc('second', updated_at)") }

  def converted_order_date
    convert_date(order_date)
  end

  def converted_despatch_date
    convert_date(despatch_date)
  end

  def mark_as_processed!
    update!(processed_at: Time.zone.now)
  end

private

  def convert_date(date)
    Date.strptime(date, '%m/%d/%Y')
  end
end
