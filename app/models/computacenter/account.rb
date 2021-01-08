module Computacenter
  class Account
    include ActiveModel::Model
    include Computacenter::ResponsibleBodyUrns::InstanceMethods

    attr_accessor :id, :name, :type,
      :address_1, :address_2, :address_3, :town, :county, :postcode,
      :computacenter_reference, :computacenter_change,
      :companies_house_number, :gias_id, :local_authority_official_name, :ukprn, :klass

    def self.requiring_computacenter_reference
      responsible_bodies_table = ResponsibleBody.arel_table
      fe_schools_table = FurtherEducationSchool.arel_table

      rb_columns = ["'ResponsibleBody' as klass", 'id', 'name', 'type', 'address_1', 'address_2', 'address_3', 'town', 'county', 'postcode', 'computacenter_reference', 'computacenter_change', 'companies_house_number', 'gias_id', 'local_authority_official_name', 'NULL as ukprn']
      fe_columns = ["'FurtherEducationSchool' as klass", 'id', 'name', 'type', 'address_1', 'address_2', 'address_3', 'town', 'county', 'postcode', 'computacenter_reference', 'computacenter_change', 'NULL as companies_house_number', 'NULL as gias_id', 'NULL as local_authority_official_name', 'ukprn']

      rb_query = responsible_bodies_table.project(*rb_columns)
      fe_query = fe_schools_table.project(*fe_columns).where(fe_schools_table[:type].eq('FurtherEducationSchool'))

      query = rb_query.union(fe_query)

      rows = ActiveRecord::Base.connection.select_all(query.to_sql)

      rows.map do |row|
        Account.new(row)
      end
    end

    def address
      [address_1, address_2, address_3, town, postcode].reject(&:blank?).join(', ')
    end
  end
end
