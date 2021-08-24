module ExportableAsCsv
  extend ActiveSupport::Concern

  included do
    require 'csv'

    def self.exportable_attributes
      h = {}
      new.attributes.each_key do |key|
        h[key] = key
      end
      h
    end

    def self.to_csv
      # this removes the need for the CSV quote_char
      sanitise_converter = proc { |field| CsvValueSanitiser.new(field).sanitise }

      ::CSV.generate(quote_char: '', write_converters: [sanitise_converter], headers: true) do |csv|
        csv << exportable_attributes.values

        all.each do |item|
          csv << exportable_attributes.keys.map do |attr|
            item.send(attr)
          end
        end
      end
    end
  end
end
