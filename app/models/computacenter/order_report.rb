class Computacenter::OrderReport < TemplateClassCsv
  def self.headers
    %w[order_number
       order_date
       quantity_completed
       device_type
       school_name]
  end

private

  def add_headers
    csv << self.class.headers
  end

  def add_report_rows
    Computacenter::Order.where(id: scope_ids).find_each do |order|
      add_order_to_csv(csv, order)
    end
  end

  def add_order_to_csv(csv, order)
    csv << csv_row(order)
  end

  def csv_row(order)
    [order.customer_order_number,
     order.order_date,
     order.quantity_completed,
     order.persona,
     order.school_name]
  end
end
