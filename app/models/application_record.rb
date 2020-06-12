class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def translated_enum_values( enum )
      send(enum).keys.map do |k|
        OpenStruct.new(
          value: k,
          label: I18n.t(k, scope: %i[activerecord attributes recipient statuses])
        )
      end
    end
  end
end
