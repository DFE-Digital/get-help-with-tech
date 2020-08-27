require 'net/http'

module RemoteFile
  def self.download(file_url, destination_file, redirect_limit = 10)
    raise StandardError, 'Too many redirects for download' if redirect_limit <= 0

    url = URI.parse(file_url)
    Net::HTTP.start(url.host, url.port,
                    use_ssl: url.scheme == 'https') do |http|
      http.request_get(url.request_uri) do |resp|
        case resp
        when Net::HTTPRedirection
          download(resp['location'], destination_file, redirect_limit - 1)
        when Net::HTTPSuccess
          resp.read_body do |chunk|
            destination_file.write(chunk.force_encoding(Encoding::ISO8859_1))
          end
        else
          resp.error!
        end
      end
    end
    destination_file.rewind
  end
end
