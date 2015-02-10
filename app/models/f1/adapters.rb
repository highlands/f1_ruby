module F1
  class Adapters
    # Working examples of how to post from different adapters:

    def excon
      a = Excon.post(url, :body => data, :headers => { "Content-Type" => "application/x-www-form-urlencoded", "Authorization" => authorization_header })
    end

    def curb
      curl = Curl::Easy.http_post(url, data) do |curl|
        curl.headers["Content-Type"] = "application/x-www-form-urlencoded"
        curl.headers["Authorization"] = authorization_header
        curl.verbose = true
      end
      if curl.response_code == 200
        http_headers = curl.header_str.split(/[\r\n]+/).map(&:strip)
        http_headers = Hash[http_headers.flat_map{ |s| s.scan(/^(\S+): (.+)/) }]
        @oauth_token = http_headers["oauth_token"]
        @oauth_token_secret = http_headers["oauth_token_secret"]
        @user_link = http_headers["Content-Location"]
        @errors = nil
      else
        binding.pry
        @errors = resp.last
      end
    end

  end
end
