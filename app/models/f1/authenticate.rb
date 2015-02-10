module F1
  class Authenticate
    attr_accessor :oauth_token_secret, :oauth_token, :user_link, :errors, :test

    def initialize(username = nil, password = nil)
      host = "https://#{ENV["F1_CODE"]}.staging.fellowshiponeapi.com"
      endpoint = "/v1/PortalUser/AccessToken"
      url = host + endpoint

      key = ENV["F1_KEY_STAGING"]
      f1_secret = ENV["F1_SECRET_STAGING"] + "%2526"
      signature = URI.encode(Base64.encode64("#{username} #{password}"))
      data = "ec=" + signature
      authorization_header = "OAuth oauth_version='1.0',oauth_nonce='#{SecureRandom.uuid}',oauth_timestamp='#{Time.now.to_i}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{f1_secret}'"

      curl = Curl::Easy.http_post(url, {'ec' => signature}) do |curl|
        curl.headers["Content-Type"] = "application/json"
        curl.headers["Authorization"] = authorization_header
        curl.verbose = true
        curl.ssl_verify_peer = false
      end
      puts curl.head

    rescue
      binding.pry
    end

#    def initialize(username = nil, password = nil, test = nil)
#      # can use PortalUser or WeblinkUser
#      user_type = username.match(/@/) && username.match(/\./) ? "WeblinkUser" : "PortalUser"
#      @test = test
#      if test
#        url = "https://#{ENV["F1_CODE"]}.staging.fellowshiponeapi.com/v1/#{user_type}/AccessToken"
#        key = ENV["F1_KEY_STAGING"]
#        f1_secret = ENV["F1_SECRET_STAGING"] + "%2526"
#      else
#        url = "https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/#{user_type}/AccessToken"
#        key = ENV["F1_KEY"]
#        f1_secret = ENV["F1_SECRET"] + "%2526"
#      end
#      signature = URI.encode(Base64.encode64("#{username} #{password}"))
#      data = "ec=" + signature
#      authorization_header = "OAuth oauth_version='1.0',oauth_nonce='#{SecureRandom.uuid}',oauth_timestamp='#{Time.now.to_i}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{f1_secret}'"
#      string = "curl -i --data '#{data}' #{url} -H 'Authorization: #{authorization_header}'"
#      resp = IO.popen(string).readlines
#      if resp.last.match(/oauth/).present?
#        tokens = resp.last.split("&").map{|s| { s.split("=").first => s.split("=").last } }
#        @oauth_token = tokens.first.merge(tokens.last)["oauth_token"]
#        @oauth_token_secret = tokens.first.merge(tokens.last)["oauth_token_secret"]
#        @user_link = resp.select{|s| s.match(/Content-Location:/) }.first.split(": ").last.gsub(/\r\n/, "")
#        @errors = nil
#      else
#        @errors = resp.last
#      end
#    rescue
#      @errors = "Connection Failed"
#    end

    def get_person
      create_header("#{user_link}.json")
    end

    def create_header(url)
      if @test
        key = ENV["F1_KEY_STAGING"]
        f1_secret = ENV["F1_SECRET_STAGING"] + "%2526"
      else
        key = ENV["F1_KEY"]
        f1_secret = ENV["F1_SECRET"] + "%2526"
      end
      oauth_signature = f1_secret + oauth_token_secret
      authorization_header = "OAuth oauth_version='1.0',oauth_token='#{oauth_token}',oauth_nonce='#{SecureRandom.uuid}',oauth_timestamp='#{Time.now.to_i}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{oauth_signature}'"
      curl_string = "curl --header 'Authorization: #{authorization_header}' #{url}"
      JSON.parse(IO.popen(curl_string).readlines.first)
    end

    def self.get_details(user_id)
      user = F1::User.find(user_id)
      url = user.url.match(/json/) ? user.url : user.url + ".json"
      key = ENV["F1_KEY"]
      f1_secret = ENV["F1_SECRET"] + "%2526"
      oauth_signature = f1_secret + user.secret
      authorization_header = "OAuth oauth_version='1.0',oauth_token='#{user.token}',oauth_nonce='#{SecureRandom.uuid}',oauth_timestamp='#{Time.now.to_i}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{oauth_signature}'"
      curl_string = "curl --header 'Authorization: #{authorization_header}' #{url}"
      JSON.parse(IO.popen(curl_string).readlines.first)
    end


########################## Testing code below this line #################################

    def mock_user
      if @test
        create_header("https://chbhmal.staging.fellowshiponeapi.com/v1/accounts/new.json")
      else
        create_header("https://chbhmal.fellowshiponeapi.com/v1/accounts/new.json")
      end
    end

    def create_user(fname = nil, lname = nil, em = nil)
      url_redirect = "http://google.com"
      url = "https://chbhmal.staging.fellowshiponeapi.com/v1/accounts.json"
      key = ENV["F1_KEY_STAGING"]
      f1_secret = ENV["F1_SECRET_STAGING"] + "%2526"
      oauth_signature = f1_secret + oauth_token_secret
      authorization_header = "OAuth oauth_version='1.0',oauth_token='#{oauth_token}',oauth_nonce='#{SecureRandom.uuid}',oauth_timestamp='#{Time.now.to_i}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{oauth_signature}'"
      data = "{'firstName': '#{fname}', 'lastName': '#{lname}', 'email': '#{em}', 'urlRedirect': '#{url_redirect}'}"
      curl_string = "curl -X POST #{url} -d '#{data}' --header 'Authorization: #{authorization_header}'"

      binding.pry

      JSON.parse(IO.popen(curl_string).readlines.first)
    end

  end


end

