module CapybaraHelper
  def basic_auth!(username:, password:)
    encoded_login = ["#{username}:#{password}"].pack('m*')
    page.driver.header 'Authorization', "Basic #{encoded_login}"
  end

  def sign_in_as(user)
    visit validate_token_url_for(user)
    click_on 'Continue'
  end

  def validate_token_url_for(user)
    token = user.generate_token!
    identifier = user.sign_in_identifier(token)
    validate_sign_in_token_url(token: token, identifier: identifier)
  end

  # from https://makandracards.com/makandra/15183-cucumber-step-to-set-cookies-in-your-capybara-session
  def set_cookie(key, value)
    headers = {}
    Rack::Utils.set_cookie_header!(headers, key, value)
    cookie_string = headers['Set-Cookie']

    Capybara.current_session.driver.browser.set_cookie(cookie_string)
  end

  # from https://makandracards.com/makandra/16117-how-to-clear-cookies-in-capybara-tests-both-selenium-and-rack-test
  def clear_all_cookies!
    browser = Capybara.current_session.driver.browser
    if browser.respond_to?(:clear_cookies)
      # Rack::MockSession
      browser.clear_cookies
    elsif browser.respond_to?(:manage) and browser.manage.respond_to?(:delete_all_cookies)
      # Selenium::WebDriver
      browser.manage.delete_all_cookies
    else
      raise "Don't know how to clear cookies. Weird driver?"
    end
  end
end
