require 'csv'

class ZendeskMacroExportService
  include ActionView::Helpers::SanitizeHelper

  attr_reader :data, :message

  class << self
    delegate :send!, to: :new
  end

  def csv_generator
    @data = CSV.generate(headers: true) do |csv|
      csv << ['Category',
              'Title',
              'Description',
              'Content',
              'Usage 1hr',
              'Usage 24hr',
              'Usage 7d',
              'Usage 30d',
              'Created',
              'Last updated',
              'Set tags',
              'Add tags',
              'Remove tags']

      macro_collection.all! do |macro|
        next if @valid == false

        if macro.active
          csv << [
            format_category(macro.title),
            format_title(macro.title),
            macro.description,
            macro.actions.select { |action| action.field == 'comment_value_html' }.first.value,
            macro.usage_1h,
            macro.usage_24h,
            macro.usage_7d,
            macro.usage_30d,
            macro.created_at.strftime('%d/%m/%Y %H:%M'),
            macro.updated_at.strftime('%d/%m/%Y %H:%M'),
            tags(macro.actions, 'set_tags'),
            tags(macro.actions, 'current_tags'),
            tags(macro.actions, 'remove_tags'),
          ].map { |value| CsvValueSanitiser.new(value).sanitise }
        end
      end
    end
    @valid = true if @valid.nil?
  end

  def valid?
    @valid
  end

  def filename
    "zendesk-macros-#{Time.zone.now.strftime('%Y%m%d_%H%M')}.csv"
  end

  def macro_collection
    # Returns ZendeskAPI::Collection (https://www.rubydoc.info/gems/zendesk_api/0.0.9/ZendeskAPI/Collection)
    # Lazily loaded, resources aren't actually fetched until explicitly needed
    @macro_collection ||= client.macros.include(:usage_1h).include(:usage_24h).include(:usage_7d).include(:usage_30d)
  end

  def client
    @client ||= ZendeskAPI::Client.new do |config|
      config.url = Settings.zendesk.url
      config.username = Settings.zendesk.username
      config.token = Settings.zendesk.token
    end
  end

private

  def format_category(title)
    return if title.nil? || @valid == false

    category_format_lookup_index = title.index(']::')

    if category_format_lookup_index.present?
      title[1, category_format_lookup_index - 1].strip
    else
      @message = "Macro title `#{sanitize(title)}` is not in correct format eg:`[Category name]:: Title`. Please correct this in zendesk"
      @valid = false
    end
  end

  def format_title(title)
    return if @valid == false

    title[title.index(']::') + 3, title.length].strip
  end

  def tags(actions, tag)
    return if actions.blank? || actions.select { |action| action[:field] == tag }.blank?

    tags = actions.select { |action| action[:field] == tag }.first.value
    "[#{tags.split.join('], [')}]"
  end
end
