require 'csv'

class ComputacenterAssetJob < ApplicationJob
  queue_as :default

  IGNORE_HEADER_ROW_AND_FIX_INVALID_CHARACTER_ERRORS = { headers: true, encoding: 'ISO-8859-1' }.freeze

  # Active Job expects a `perform` method
  def perform(path_to_csv, action_symbol)
    @dry_run = true

    Rails.logger.info('Running as dry run (so not really affecting database)') if @dry_run
    perform_on_csv_file_path(path_to_csv, action_symbol)
  end

  # the following methods are public for easier testing
  def perform_on_csv_file_path(path_to_csv, action_symbol)
    case action_symbol
    when :create
      create_assets(path_to_csv)
    when :update
      update_assets(path_to_csv, :serial_number) # :tag or :serial_number
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

    log_start(path_to_csv, action)

    CSV.foreach(path_to_csv, **IGNORE_HEADER_ROW_AND_FIX_INVALID_CHARACTER_ERRORS) do |row|
      import_csv_row(row)
      csv_asset_read_count += 1
      log_progress(csv_asset_read_count, estimated_asset_count) if (csv_asset_read_count % progress_interval).zero?
    end

    log_finish(path_to_csv, action, csv_asset_read_count)
    Rails.logger.info("#{csv_asset_read_count} asset(s) added to the database")
    Rails.logger.info("There are now #{Asset.count} total asset(s) in the database")
  end

  def log_start(path_to_csv, action_symbol)
    Rails.logger.info("Started #{self.class} (#{path_to_csv}, :#{action_symbol}) ~#{estimate_assets_lines_in_file(path_to_csv)} asset(s)")
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

  def import_csv_row(row)
    Asset.create!(attributes_hash(row)) unless @dry_run
  end

  def attributes_hash(row)
    # we don't store row[0] (`sys_id`) nor row[14] (`sys_updated_at`)
    { tag: row[1], serial_number: row[2], model: row[3], department: row[4], department_id: row[5], department_sold_to_id: row[6], location: row[7], location_id: row[8], location_cc_ship_to_account: row[9], bios_password: row[10], admin_password: row[11], hardware_hash: row[12], sys_created_at: row[13] }
  end

  def log_finish(path_to_csv, action_symbol, csv_asset_read_count)
    Rails.logger.info("Finished #{self.class} (#{path_to_csv}, :#{action_symbol}) with #{csv_asset_read_count} asset(s) from CSV file")
  end

  def update_assets(path_to_csv, id_tag)
    action = :update
    progress_interval = 500
    updated_asset_count = 0
    unchanged_asset_count = 0
    missing_asset_count = 0
    csv_asset_read_count = 0
    estimated_asset_count = estimate_assets_lines_in_file(path_to_csv)

    log_start(path_to_csv, action)

    CSV.foreach(path_to_csv, **IGNORE_HEADER_ROW_AND_FIX_INVALID_CHARACTER_ERRORS) do |row|
      case update_asset(id_tag, row)
      when :updated
        updated_asset_count += 1
      when :unchanged
        unchanged_asset_count += 1
      when :missing
        missing_asset_count += 1
      end

      csv_asset_read_count += 1
      log_progress(csv_asset_read_count, estimated_asset_count) if (csv_asset_read_count % progress_interval).zero?
    end

    log_finish(path_to_csv, action, csv_asset_read_count)
    Rails.logger.info("#{updated_asset_count} asset(s) updated in the database")
    Rails.logger.info("#{unchanged_asset_count} asset(s) found but unchanged in the database")
    Rails.logger.info("#{missing_asset_count} missing asset(s) could not be updated")
  end

  def update_asset(key, row)
    search_term_hash = search_term_hash(key, row)
    asset_to_update = find_asset(search_term_hash)

    if asset_to_update.present?
      attributes_for_row = attributes_hash(row)

      if changing?(asset_to_update, attributes_for_row)
        asset_to_update.update!(attributes_for_row) unless @dry_run
        :updated
      else
        :unchanged
      end
    else
      :missing
    end
  end

  def changing?(asset_to_update, new_attributes_hash)
    encrypted_new_attributes_hash = new_attributes_hash.except(:bios_password, :admin_password, :hardware_hash)

    encrypted_new_attributes_hash.store(:encrypted_bios_password, EncryptionService.encrypt(new_attributes_hash[:bios_password]))
    encrypted_new_attributes_hash.store(:encrypted_admin_password, EncryptionService.encrypt(new_attributes_hash[:admin_password]))
    encrypted_new_attributes_hash.store(:encrypted_hardware_hash, EncryptionService.encrypt(new_attributes_hash[:hardware_hash]))

    encrypted_relevant_record_attributes = asset_to_update.attributes.except(:id, :created_at, :updated_at)

    encrypted_new_attributes_hash != encrypted_relevant_record_attributes
  end

  def search_term_hash(key, row)
    attributes_hash(row).slice(key)
  end

  def find_asset(search_term_hash)
    relation = @dry_run ? Asset.readonly : Asset
    relation.find_by(search_term_hash)
  end

  def percentage(numerator, denominator)
    (numerator * 100.0 / denominator).to_s(:percentage, precision: 2)
  end
end
