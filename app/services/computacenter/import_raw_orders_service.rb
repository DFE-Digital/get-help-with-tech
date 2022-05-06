require 'csv'

# Service to import raw order data
class Computacenter::ImportRawOrdersService < ApplicationService
  def initialize(path:)
    @path = path
  end

  def call
    CSV.foreach(path, headers: true, header_converters: :symbol) do |row|
      Computacenter::RawOrder.create!(row.to_hash)
    end
  end

private

  attr_reader :path
end
