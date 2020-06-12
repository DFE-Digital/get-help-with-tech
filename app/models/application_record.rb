class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def translated_enum_values( enum )
      send(enum).keys.map do |k|
        OpenStruct.new(
          value: k,
          label: I18n.t(k, scope: enum_i18n_scope(enum))
        )
      end
    end


    def enum_i18n_scope(enum)
      [:activerecord, :attributes, name.underscore.to_sym, enum.to_sym]
    end
  end

  def translated_enum_value( enum )
    I18n.t(send(enum), scope: self.class.enum_i18n_scope(enum.to_s.pluralize))
  end
end
