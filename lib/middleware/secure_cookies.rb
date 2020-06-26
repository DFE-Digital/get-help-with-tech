# from https://makandracards.com/makandra/53693-rails-flagging-all-cookies-as-secure-only-to-pass-a-security-audit

# > For a page that exclusively uses https:// with HSTS, it is not necessary to set the secure flag on your cookies. There is simply no case when the browser would talk to the server via unencrypted http:// requests.
# >
# > Why you might need secure-only cookies anyway
# > A security audit will still raise missing "secure" flags as an issue that needs to be fixed.'

# On HTTPS requests, we flag all cookies sent by the application to be "Secure".
#
module Middleware
  class SecureCookies
    COOKIE_SEPARATOR = "\n".freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      if headers['Set-Cookie'].present? && Rack::Request.new(env).ssl?
        cookies = headers['Set-Cookie'].split(COOKIE_SEPARATOR)

        cookies.each do |cookie|
          next if cookie.blank?
          next if cookie =~ /;\s*secure/i

          cookie << '; Secure'
        end

        headers['Set-Cookie'] = cookies.join(COOKIE_SEPARATOR)
      end

      [status, headers, body]
    end
  end
end
