module PageObjects
  module SupportTicket
    class App
      def check_your_request
        PageObjects::SupportTicket::CheckYourRequestPage.new
      end

      def contact_details
        PageObjects::SupportTicket::ContactDetailsPage.new
      end

      def describe_yourself
        PageObjects::SupportTicket::DescribeYourselfPage.new
      end

      def load_check_your_request_page
        load_support_details_page.enter_dummy_support_details_and_continue
        check_your_request.load
        check_your_request
      end

      def load_contact_details_page
        load_school_details_page.enter_dummy_school_details_and_continue
        contact_details.load
        contact_details
      end

      def load_school_details_page
        describe_yourself.load_then_select_anything_and_continue
        school_details.load
        school_details
      end

      def load_support_details_page
        load_support_needs_page.select_anything_and_continue
        support_details.load
        support_details
      end

      def load_support_needs_page
        load_contact_details_page.enter_dummy_contact_details_and_continue
        support_needs.load
        support_needs
      end

      def school_details
        PageObjects::SupportTicket::SchoolDetailsPage.new
      end

      def support_details
        PageObjects::SupportTicket::SupportDetailsPage.new
      end

      def support_needs
        PageObjects::SupportTicket::SupportNeedsPage.new
      end

      def thank_you
        PageObjects::SupportTicket::ThankYouPage.new
      end
    end
  end
end
