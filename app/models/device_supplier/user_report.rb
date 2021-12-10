class DeviceSupplier::UserReport < TemplateClassCsv
  def self.headers
    %w[user_id
       title
       first_name
       last_name
       telephone
       email_address
       sold_to
       default_sold_to
       dfe_timestamp]
  end

private

  def add_headers
    csv << self.class.headers
  end

  def add_report_rows
    User.where(id: scope_ids)
        .relevant_to_device_supplier
        .includes(:schools, :responsible_body, :last_user_change, schools: :responsible_body)
        .find_each do |user|
      csv << csv_row(user)
    end
  end

  def csv_row(user)
    [user.email_address,
     nil,
     user.first_name,
     user.last_name,
     user.telephone,
     user.email_address,
     user_sold_tos_text(user),
     user_default_sold_to_text(user),
     device_supplier_user_updated_at_timestamp_string(user)].map { |value| CsvValueSanitiser.new(value).sanitise }
  end

  def device_supplier_latest_user_change(user)
    user.last_user_change
  end

  def device_supplier_user_updated_at(user)
    device_supplier_latest_user_change(user)&.updated_at_timestamp
  end

  def device_supplier_user_updated_at_timestamp(user)
    device_supplier_user_updated_at(user)&.utc
  end

  def device_supplier_user_updated_at_timestamp_string(user)
    device_supplier_user_updated_at_timestamp(user)&.iso8601
  end

  def user_default_sold_to_text(user)
    return user.rb.sold_to if user.rb.present?

    return user.schools_sold_tos.first.to_s if user.schools_sold_tos.one?

    user_most_recently_used_sold_to(user)
  end

  def user_most_recently_used_ship_to(user)
    Computacenter::DevicesOrderedUpdate.where(ship_to: user.ship_tos).order(created_at: :desc).limit(1).first
  end

  def user_most_recently_used_sold_to(user)
    ship_to = user_most_recently_used_ship_to(user)
    return if ship_to.nil?

    school = School.find_by(computacenter_reference: ship_to)
    return if school.nil?

    school.sold_to
  end

  def user_sold_tos_text(user)
    user.sold_tos.join('|')
  end
end
