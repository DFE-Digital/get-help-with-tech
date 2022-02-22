class AnonymiseExtraMobileDataRequestsJob < ApplicationJob
  queue_as :default

  # Running:
  # * ExtraMobileDataRequest.all.group('account_holder_name').count
  # * ExtraMobileDataRequest.all.group('device_phone_number').count
  # on production shows that the same device_phone_number (and account_holder_name)
  # are found multiple times. This might mean the same name and the same number
  # should get the same anonymised value to preserve the fact that a person
  # had multiple ExtraMobileDataRequests for statistical purposes
  #
  # There are also `hashed_account_holder_name`, `hashed_normalised_name` and
  # `hashed_device_phone_number` which are passed via CSV to our supplier.
  # They are hashed with a one-way function (md5sum) and are used as an
  # identifier by our supplier so we've left those untouched.
  #
  # Separately, we need to delete old Papertrail information on
  # ExtraMobileDataRequests using:
  #
  # PaperTrail::Version.where(item_type: 'ExtraMobileDataRequest').delete_all

  def perform(*_args)
    generate_deterministic_output_to_gauge_progress
    make_unique_values_more_likely

    anonymise_all_extra_mobile_data_requests
  end

private

  def generate_deterministic_output_to_gauge_progress
    Faker::Config.random = Random.new(17)
  end

  def make_unique_values_more_likely
    Faker::UniqueGenerator.clear
  end

  def anonymise_all_extra_mobile_data_requests
    # ExtraMobileDataRequest normalises account_holder_name and device_phone_number before saving
    real_name_to_normalised_anonymised_name = {}
    real_number_to_normalised_anonymised_number = {}

    ExtraMobileDataRequest.find_each do |request|
      anonymised_account_holder_name = reuse_anonymised_value_or_generate_new_one(real_value: request.account_holder_name, real_to_anonymised_map: real_name_to_normalised_anonymised_name, all_real_values: existing_names, generator_method_symbol: :generate_fake_name, normaliser_method_symbol: :normalised_name_value)
      anonymised_device_phone_number = reuse_anonymised_value_or_generate_new_one(real_value: request.device_phone_number, real_to_anonymised_map: real_number_to_normalised_anonymised_number, all_real_values: existing_phone_numbers, generator_method_symbol: :generate_fake_uk_mobile_number, normaliser_method_symbol: :normalised_device_phone_number_value)
      request.update!(account_holder_name: anonymised_account_holder_name, device_phone_number: anonymised_device_phone_number)
    end
  end

  def reuse_anonymised_value_or_generate_new_one(real_value:, real_to_anonymised_map:, all_real_values:, generator_method_symbol:, normaliser_method_symbol:)
    normalised_real_value = ExtraMobileDataRequest.new.send(normaliser_method_symbol, real_value)

    if real_to_anonymised_map.key?(normalised_real_value)
      real_to_anonymised_map.fetch(normalised_real_value)
    else
      real_to_anonymised_map[normalised_real_value] = value_which_is_not_a_real_value(all_real_values:, generator_method_symbol:)
    end
  end

  def value_which_is_not_a_real_value(all_real_values:, generator_method_symbol:)
    candidate = nil

    loop do
      candidate = send(generator_method_symbol)

      break unless candidate.in?(all_real_values)
    end

    candidate
  end

  def existing_names
    ExtraMobileDataRequest.pluck(:account_holder_name)
  end

  def existing_phone_numbers
    ExtraMobileDataRequest.pluck(:device_phone_number)
  end

  def generate_fake_name
    Faker::Name.unique.name
  end

  def generate_fake_uk_mobile_number
    Faker::PhoneNumber.unique.cell_phone
  end
end
