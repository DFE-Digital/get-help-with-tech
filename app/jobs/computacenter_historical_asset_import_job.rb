# One-off import job to capture historical asset information from Computacenter
class ComputacenterHistoricalAssetImportJob < ApplicationJob
  queue_as :default

  def perform(path_to_csv)
    perform_on_csv_file_path(path_to_csv)
  end

  # the following methods are public for easier testing

  def perform_on_csv_file_path(path_to_csv)
    job_class_name = self.class
    progress_interval = 5_000
    created_asset_count = 0
    asset_row_count = estimate_assets_lines_in_file(path_to_csv)

    Rails.logger.info("Started #{job_class_name} for #{path_to_csv} with ~#{asset_row_count} asset(s)")

    # options ignore first (header) row and fix invalid character errors
    CSV.foreach(path_to_csv, headers: true, encoding: 'ISO-8859-1') do |row|
      import_csv_row(row)
      created_asset_count += 1
      log_progress(created_asset_count, asset_row_count) if (created_asset_count % progress_interval).zero?
    end

    Rails.logger.info("Finished #{job_class_name} for #{path_to_csv} with #{created_asset_count} asset(s) imported")
    Rails.logger.info("There are now #{Asset.count} total asset(s) in the database")
  end

  def unix_word_count_output(path_to_csv)
    stdout, stderr = Open3.capture3('wc', '-l', path_to_csv)[0, 1]

    stderr.blank? ? stdout : raise("could not get file line count for #{path_to_csv}")
  end

  def log_progress(created_asset_count, asset_row_count)
    Rails.logger.info("(#{percentage(created_asset_count, asset_row_count)}) This job has written #{created_asset_count} of ~#{asset_row_count} asset(s) so far...")
  end

private

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
    Asset.create!(tag: row[1], serial_number: row[2], model: row[3], department: row[4], department_id: row[5], department_sold_to_id: row[6], location: row[7], location_id: row[8], location_cc_ship_to_account: row[9], bios_password: row[10], admin_password: row[11], hardware_hash: row[12], sys_created_at: row[13])
  end

  def percentage(numerator, denominator)
    (numerator * 100.0 / denominator).to_s(:percentage, precision: 2)
  end
end
