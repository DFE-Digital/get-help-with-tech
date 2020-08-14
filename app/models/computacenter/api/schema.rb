class Computacenter::API::Schema
  attr_accessor :schema

  def initialize(schema_name)
    @schema = self.class.load_schema(schema_name)
  end

  def validate(xml_doc)
    schema.validate(xml_doc)
  end

  def self.schema_path(schema_name)
    Rails.root.join("config/computacenter/api/schema/#{schema_name}")
  end

  def self.load_schema(schema_name)
    Nokogiri::XML::Schema(File.read(schema_path(schema_name)))
  end
end
