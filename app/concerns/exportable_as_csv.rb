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
      ::CSV.generate(headers: true) do |csv|
        csv << exportable_attributes.values

        all.each do |item|
          csv << exportable_attributes.keys.map do |attr|
            safe_value = prevent_csv_code_injection(item.send(attr))
            safe_value
          end
        end
      end
    end

    def self.prevent_csv_code_injection(value)
      value.to_s.starts_with?(/[\-+=@]/) ? value.gsub(/^([\-+=@].*)/, '.\1') : value
    end
  end
end
