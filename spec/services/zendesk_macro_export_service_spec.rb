require 'rails_helper'

RSpec.describe ZendeskMacroExportService, type: :model do
  subject(:service) { ZendeskMacroExportService.new }

  let(:ticket) do
    {
      'full_name' => 'Joe Blogg',
      'email_address' => 'joe@bloggs.com',
      'user_type' => 'parent',
      'telephone_number' => '0207 333 4444',
      'subject' => 'My query',
      'message' => 'This is my query',
      'support_topics' => %w[hello world],
    }
  end

  describe '#filename' do
    it 'returns a formatted string which will be used for the csv file' do
      @time_now = Time.zone.now
      allow(Time.zone).to receive(:now).and_return(@time_now)
      expect(service.filename).to eq("zendesk-macros-#{@time_now.strftime('%Y%m%d_%H%M')}.csv")
    end
  end

  describe '#csv_generator' do
    let(:created_time) { Time.zone.now - 10.minutes }
    let(:updated_time) { Time.zone.now }
    let(:mocked_data) do
      OpenStruct.new(
        {
          active: true,
          title: '[CATEGORY 1]:: Title name',
          description: 'This is a macro',
          usage_1h: 1,
          usage_24h: 2,
          usage_7d: 3,
          usage_30d: 4,
          created_at: created_time,
          updated_at: updated_time,
          actions: [
            OpenStruct.new({ field: 'set_tags', value: 'set_tag1 set_tag2' }),
            OpenStruct.new({ field: 'current_tags', value: 'current_tag1 current_tag2' }),
            OpenStruct.new({ field: 'remove_tags', value: 'remove_tag1 remove_tag2' }),
            OpenStruct.new({ field: 'comment_value_html', value: 'Dear customer' }),
          ],
        },
      )
    end

    it 'generates csv file contents' do
      allow(service.macro_collection).to receive(:all!).and_yield(mocked_data)

      stub_request(:get, 'https://get-help-with-tech-education.zendesk.com/api/v2/macros?include=usage_1h,usage_24h,usage_7d,usage_30d')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Basic Og==',
            'User-Agent' => 'ZendeskAPI Ruby 1.28.0',
          },
        )
        .to_return(status: 200, body: '', headers: {})
      service.csv_generator
      expect(service.data).to eq("Category,Title,Description,Content,Usage 1hr,Usage 24hr,Usage 7d,Usage 30d,Created,Last updated,Set tags,Add tags,Remove tags\nCATEGORY 1,Title name,This is a macro,Dear customer,1,2,3,4,#{created_time.strftime('%d/%m/%Y %H:%M')},#{updated_time.strftime('%d/%m/%Y %H:%M')},\"[set_tag1], [set_tag2]\",\"[current_tag1], [current_tag2]\",\"[remove_tag1], [remove_tag2]\"\n")
    end

    describe 'unhappy paths' do
      describe 'when macro titles not in the correct format' do
        it 'sets valid to false' do
          mocked_data.title = '[CATEGORY 1]: Title name'

          allow(service.macro_collection).to receive(:all!).and_yield(mocked_data)

          stub_request(:get, 'https://get-help-with-tech-education.zendesk.com/api/v2/macros?include=usage_1h,usage_24h,usage_7d,usage_30d')
            .with(
              headers: {
                'Accept' => 'application/json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization' => 'Basic Og==',
                'User-Agent' => 'ZendeskAPI Ruby 1.28.0',
              },
            )
            .to_return(status: 200, body: '', headers: {})
          service.csv_generator
          expect(service.valid?).to eq(false)
        end
      end
    end
  end
end
