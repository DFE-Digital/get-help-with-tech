require 'csv'

# Service to export user data for the device supplier
module DeviceSupplier
  class ExportUsersService
    attr_reader :path
    attr_accessor :progress_percentage, :count, :per_user_percentage

    UPDATE_PROGRESS_DELAY = 200

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

    def initialize(path = nil)
      @path = path
      @progress_percentage = 0
      @count = 0
      @per_user_percentage = 100.0 / User.count
    end

    def call(target_path = path)
      raise 'No path specified' if target_path.nil?

      to_csv(target_path)
      Rails.logger.info "#{class_name}: Exported #{count} schools to #{target_path}"
    end

    def to_csv(path = nil)
      open_or_generate = path.nil? ? [:generate] : [:open, path, 'wb']
      CSV.send(*open_or_generate) do |csv|
        csv << self.class.headers
        User.relevant_to_device_supplier
            .includes(:schools, :responsible_body, :last_user_change, schools: :responsible_body)
            .find_each do |user|
          update_progress
          csv << csv_row(user)
        end
      end
    end

  private

    def class_name
      self.class.name.demodulize
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

    def update_progress
      @progress_percentage += @per_user_percentage
      @count += 1
      Rails.logger.info "#{class_name} percentage: #{@progress_percentage.to_i}%\n" if (@count % UPDATE_PROGRESS_DELAY).zero?
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
end
