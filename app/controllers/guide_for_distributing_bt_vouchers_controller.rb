class GuideForDistributingBTVouchersController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :set_guide_navigation

  def index; end

  def who_to_give_vouchers_to; end

  def what_to_do_with_the_vouchers; end

  def not_offered_vouchers_yet; end

private

  def set_guide_navigation
    @contents = contents
    current_index = @contents.find_index { |item| item[:path] == request.path }

    @contents[current_index][:active] = true
    @next_page = contents[current_index + 1] || false
    @prev_page = current_index.positive? ? contents[current_index - 1] : false
    @title = contents[current_index][:text]
  end

  def page_title(key)
    t("guide_for_distributing_bt_vouchers.#{key}")
  end

  def contents
    [
      {
        text: page_title('overview'),
        path: guide_for_distributing_bt_vouchers_path,
      },
      {
        text: page_title('who_to_give_vouchers_to'),
        path: guide_for_distributing_bt_vouchers_who_to_give_vouchers_to_path,
      },
      {
        text: page_title('what_to_do_with_the_vouchers'),
        path: guide_for_distributing_bt_vouchers_what_to_do_with_the_vouchers_path,
      },
      {
        text: page_title('not_offered_vouchers_yet'),
        path: guide_for_distributing_bt_vouchers_not_offered_vouchers_yet_path,
      },
    ]
  end
end
