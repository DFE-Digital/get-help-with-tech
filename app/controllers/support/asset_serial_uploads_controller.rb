class Support::AssetSerialUploadsController < Support::BaseController
  def new
    authorize :asset_serial_upload, policy_class: Support::AssetSerialUploadPolicy
  end

  def create
    @title = 'Serial number validation'
    @file_contents = params[:serial_numbers_file].read
    serial_numbers_to_search_for = read_column_of_serial_numbers_on_separate_lines(@file_contents).to_set
    @assets = policy_scope(Asset).where(serial_number: serial_numbers_to_search_for).order(:department, :location)
    @found_serial_numbers = @assets.pluck(:serial_number).to_set
    @missing_serial_numbers = serial_numbers_to_search_for - @found_serial_numbers

    authorize @assets, policy_class: Support::AssetSerialUploadPolicy
  end

private

  def read_column_of_serial_numbers_on_separate_lines(file_contents)
    file_contents.split(/[[:space:]]/)
  end
end
