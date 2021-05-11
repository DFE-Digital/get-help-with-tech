module Computacenter
  module ServiceNowUserImportAPI
    class ImportUserChangeRequest
      attr_accessor :endpoint, :username, :password, :timestamp, :logger, :response, :user_change

      def initialize(args = {})
        @endpoint       = args[:endpoint] || setting(:endpoint)
        @username       = args[:username] || setting(:username)
        @password       = args[:password] || setting(:password)
        @timestamp      = args[:timestamp] || Time.zone.now
        @user_change    = args[:user_change]
        @logger         = args[:logger] || Rails.logger
      end

      def post!
        @body = construct_body

        @logger.info("POSTing to Computacenters' ServiceNow, endpoint: #{@endpoint}, body: \n#{@body}")
        @response = HTTP.basic_auth(user: @username, pass: @password)
                        .post(@endpoint, body: @body)
        handle_response!
      end

      def parsed_response_body
        JSON.parse(response.body.to_s)
      end

      def cc_transaction_id
        response.headers['X-Transaction-Id']
      end

    private

      def handle_response!
        response_body = @response.body.to_s
        @logger.info("Response from Computacenter: \n#{response_body}")
        unless success?
          raise(
            Computacenter::ServiceNowUserImportAPI::Error.new(import_user_change_request: self),
            "Computacenter responded with #{@response.status}, response_body: #{response_body}",
          )
        end

        @response
      end

      def construct_body
        body = {
          u_email: user_change.email_address,
          u_type_of_update: user_change.type_of_update,
          u_cc_sold_to_number: user_change.cc_sold_to_number,
          u_first_name: user_change.first_name,
          u_last_name: user_change.last_name,
          u_responsible_body: user_change.responsible_body,
          u_responsible_body_urn: user_change.responsible_body_urn,
          u_cc_ship_to_number: user_change.cc_ship_to_number,
          u_date_of_update: user_change.updated_at_timestamp.utc.strftime('%d/%m/%Y'),
          u_school: user_change.school,
          u_school_urn: user_change.school_urn,
          u_telephone: user_change.telephone,
          u_timestamp_of_update: user_change.updated_at_timestamp.utc.iso8601,
          u_time_of_update: user_change.updated_at_timestamp.utc.strftime('%R %z'),
          u_original_email: user_change.original_email_address,
          u_original_cc_sold_to_number: user_change.original_cc_sold_to_number,
          u_original_first_name: user_change.original_first_name,
          u_original_last_name: user_change.original_last_name,
          u_original_responsible_body: user_change.original_responsible_body,
          u_original_responsible_body_urn: user_change.original_responsible_body_urn,
          u_original_cc_ship_to_number: user_change.original_cc_ship_to_number,
          u_original_school: user_change.original_school,
          u_original_school_urn: user_change.original_school_urn,
          u_original_telephone: user_change.original_telephone,
        }

        if FeatureFlag.active?(:rb_level_access_notification)
          body.merge!({
            u_rb_user: user_change.cc_rb_user,
            u_original_rb_user: user_change.original_cc_rb_user,
          })
        end

        body.to_json
      end

      def setting(name)
        Settings.computacenter.service_now_user_import_api.send(name)
      end

      def success?
        response.status.success? && parsed_result_indicates_success?
      end

      def parsed_result_indicates_success?
        parsed_response_body['result']&.first&.fetch('status') != 'error'
      end
    end
  end
end
