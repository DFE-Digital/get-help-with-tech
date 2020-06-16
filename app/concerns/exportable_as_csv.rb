module ExportableAsCsv
  extend ActiveSupport::Concern

  included do
    require 'csv'

    def self.exportable_attributes
      h = {}
      new.attributes.keys.each do |key|
        h[key] = key
      end
      h
    end

    def self.to_csv
      ::CSV.generate(headers: true) do |csv|
        csv << exportable_attributes.values

        all.each do |item|
          csv << exportable_attributes.keys.map{ |attr| item.send(attr) }
        end
      end
    end
  end
end
