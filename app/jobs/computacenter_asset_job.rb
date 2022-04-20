require 'csv'

class ComputacenterAssetJob < ApplicationJob
  queue_as :default

  IGNORE_HEADER_ROW_AND_FIX_INVALID_CHARACTER_ERRORS = { headers: true, encoding: 'UTF-8', col_sep: ';' }.freeze

  # Active Job expects a `perform` method
  def perform(path_to_csv, action_symbol)
    perform_on_csv_file_path(path_to_csv, action_symbol)
  end

  # the following methods are public for easier testing

  def perform_on_csv_file_path(path_to_csv, action_symbol)
    case action_symbol
    when :create
      create_assets(path_to_csv)
    when :update
      update_assets(path_to_csv)
    else
      Rails.logger.fatal("Unknown action :#{action_symbol}")
    end
  end

  def unix_word_count_output(path_to_csv)
    stdout, stderr = Open3.capture3('wc', '-l', path_to_csv)[0, 1]

    stderr.blank? ? stdout : raise("could not get file line count for #{path_to_csv}")
  end

  def log_progress(processed_asset_count, estimated_asset_count)
    Rails.logger.info("(#{percentage(processed_asset_count, estimated_asset_count)}) Processed #{processed_asset_count} of ~#{estimated_asset_count} asset(s) so far...")
  end

private

  def create_assets(path_to_csv)
    action = :create
    progress_interval = 5_000
    csv_asset_read_count = 0
    estimated_asset_count = estimate_assets_lines_in_file(path_to_csv)

    log_start(path_to_csv:, action:, estimated_asset_count:)

    CSV.foreach(path_to_csv, **IGNORE_HEADER_ROW_AND_FIX_INVALID_CHARACTER_ERRORS) do |row|
      import_csv_row(row)
      csv_asset_read_count += 1
      log_progress(csv_asset_read_count, estimated_asset_count) if (csv_asset_read_count % progress_interval).zero?
    end

    log_finish(path_to_csv:, action:, csv_asset_read_count:)
    Rails.logger.info("#{csv_asset_read_count} asset(s) added to the database")
    Rails.logger.info("There are now #{Asset.count} total asset(s) in the database")
  end

  def estimate_assets_lines_in_file(path)
    non_header_line_count_of_file(path)
  end

  # as an estimate of the number of assets in the CSV this could be wrong
  # if there are blank lines or a missing header line
  def non_header_line_count_of_file(path)
    total_line_count = line_count_of_file(path)
    total_line_count.zero? ? 0 : total_line_count - 1
  end

  def line_count_of_file(path)
    console_output = unix_word_count_output(path)
    console_output.to_i
  end

  def log_start(path_to_csv:, action:, estimated_asset_count:)
    Rails.logger.info("Started #{self.class} (#{path_to_csv}, :#{action}) ~#{estimated_asset_count} asset(s)")
  end

  def import_csv_row(row)
    Asset.create!(attributes_hash(row))
  end

  def attributes_hash(row)
    {
      tag: row['OrderNumber'],
      serial_number: row['SerialNumber'],
      model: row['MaterialDescription'],
      department: row['SoldToCustomer'],
      department_id: row['URN'],
      department_sold_to_id: row['SoldToAccountNo'],
      location: row['ShipToCustomer'],
      location_id: row['SchoolURN'],
      location_cc_ship_to_account: row['ShipToAccountNo'],
    }
  end

  def log_finish(path_to_csv:, action:, csv_asset_read_count:)
    Rails.logger.info("Finished #{self.class} (#{path_to_csv}, :#{action}) with #{csv_asset_read_count} asset(s) from CSV file")
  end

  def update_assets(path_to_csv)
    action = :update
    progress_interval = 500
    updated_asset_count = 0
    created_asset_count = 0
    csv_asset_read_count = 0
    estimated_asset_count = estimate_assets_lines_in_file(path_to_csv)

    log_start(path_to_csv:, action:, estimated_asset_count:)

    CSV.foreach(path_to_csv, **IGNORE_HEADER_ROW_AND_FIX_INVALID_CHARACTER_ERRORS) do |row|
      case update_asset(row)
      when :updated
        updated_asset_count += 1
      when :missing, :conflict, :secure_attribute_overwrite_attempt
        import_csv_row(row)
        created_asset_count += 1
      end

      csv_asset_read_count += 1
      log_progress(csv_asset_read_count, estimated_asset_count) if (csv_asset_read_count % progress_interval).zero?
    end

    log_finish(path_to_csv:, action:, csv_asset_read_count:)
    Rails.logger.info("#{updated_asset_count} asset(s) updated in the database")
    Rails.logger.info("#{created_asset_count} missing/conflicting/overwriting asset(s) added to the database")
  end

  def update_asset(row)
    asset_to_update_according_to_serial_number = find_asset(search_term_hash(:serial_number, row))
    asset_to_update_according_to_tag = find_asset(search_term_hash(:tag, row))

    if [asset_to_update_according_to_serial_number, asset_to_update_according_to_tag].all?(&:nil?)
      :missing
    elsif (asset_to_update_according_to_serial_number != asset_to_update_according_to_tag) && [asset_to_update_according_to_serial_number, asset_to_update_according_to_tag].all?(&:present?)
      :conflict
    else
      asset_to_update = [asset_to_update_according_to_serial_number, asset_to_update_according_to_tag].compact.first
      row_attributes_hash = attributes_hash(row)

      if overwriting_present_secure_attribute?(row_attributes_hash, asset_to_update)
        :secure_attribute_overwrite_attempt
      else
        asset_to_update.update!(row_attributes_hash)
        :updated
      end
    end
  end

  def search_term_hash(key, row)
    attributes_hash(row).slice(key)
  end

  def find_asset(search_term_hash)
    Asset.find_by(search_term_hash)
  end

  def overwriting_present_secure_attribute?(row_attributes_hash, asset)
    secure_attributes = %i[bios_password admin_password hardware_hash]

    secure_attributes.each do |secure_attribute|
      current_value = asset.send(secure_attribute)
      new_value = row_attributes_hash[secure_attribute]

      return true if current_value.present? && (new_value != current_value)
    end

    false
  end

  def percentage(numerator, denominator)
    (numerator * 100.0 / denominator).to_s(:percentage, precision: 2)
  end
end
