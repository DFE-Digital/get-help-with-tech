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

  def update_assets(path_to_csv)
    action = :update
    progress_interval = 500
    updated_asset_count = 0
    unchanged_asset_count = 0
    missing_asset_count = 0
    conflict_asset_count = 0
    csv_asset_read_count = 0
    estimated_asset_count = estimate_assets_lines_in_file(path_to_csv)
    @updated_attribute_keys = Set.new

    log_start(path_to_csv, action)

    CSV.foreach(path_to_csv, **IGNORE_HEADER_ROW_AND_FIX_INVALID_CHARACTER_ERRORS) do |row|
      case update_asset(row)
      when :updated
        updated_asset_count += 1
      when :unchanged
        unchanged_asset_count += 1
      when :missing
        missing_asset_count += 1
      when :conflict
        conflict_asset_count += 1
      end

      csv_asset_read_count += 1
      log_progress(csv_asset_read_count, estimated_asset_count) if (csv_asset_read_count % progress_interval).zero?
    end

    log_finish(path_to_csv, action, csv_asset_read_count)
    Rails.logger.info("#{updated_asset_count} asset(s) updated in the database")
    Rails.logger.info("#{unchanged_asset_count} asset(s) found but unchanged in the database")
    Rails.logger.info("#{missing_asset_count} missing asset(s) could not be updated")
    Rails.logger.info("#{conflict_asset_count} conflicting asset match(es) could not be updated")
    Rails.logger.info("This file updated #{@updated_attribute_keys} asset attribute(s)")
  end

  def update_asset(row)
    serial_number_search_term = search_term_hash(:serial_number, row)
    tag_search_term = search_term_hash(:tag, row)
    asset_to_update_according_to_serial_number = find_asset(serial_number_search_term)
    asset_to_update_according_to_tag = find_asset(tag_search_term)

    if [asset_to_update_according_to_serial_number, asset_to_update_according_to_tag].all?(&:nil?)
      Rails.logger.info("No matches for (serial_number: #{serial_number_search_term.values.first}) or (tag: #{tag_search_term.values.first})")
      return :missing
    end

    if asset_to_update_according_to_serial_number != asset_to_update_according_to_tag
      Rails.logger.info("Conflicting matches. (serial_number: #{asset_to_update_according_to_serial_number&.attributes}) (tag: #{asset_to_update_according_to_tag&.attributes})")
      return :conflict
    end

    asset_to_update = asset_to_update_according_to_serial_number # could use either at this point
    attributes_for_row = attributes_hash(row)
    differing_attribute_keys = differing_attribute_keys(asset_to_update, attributes_for_row)

    if differing_attribute_keys.any?
      @updated_attribute_keys.merge(differing_attribute_keys)
      asset_to_update.update!(attributes_for_row.slice(*differing_attribute_keys)) unless @dry_run
      :updated
    else
      :unchanged
    end
  end

  def differing_attribute_keys(asset, row_attributes)
    attribute_intersection = asset.attributes.symbolize_keys.slice(*row_attributes.keys)
    differing_keys(attribute_intersection, row_attributes)
  end

  def differing_keys(hash, other_hash)
    differing_keys = []

    hash.each { |key, value| differing_keys << key if other_hash.fetch(key) != value }

    differing_keys
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
