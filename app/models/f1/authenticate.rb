module F1
  class Authenticate
    attr_accessor :oauth_token_secret, :oauth_token, :user_link, :errors

    def initialize(username = nil, password = nil, church_code = "chbhmal", env = "staging")
      url = "https://#{church_code}.#{env}.fellowshiponeapi.com/v1/PortalUser/AccessToken"
      church_code = church_code
      env = env
      key = ENV["F1_KEY"]
      signature = URI.encode(Base64.encode64("#{username} #{password}"))
      data = "ec=" + signature
      f1_secret = ENV["F1_SECRET"] + "%2526"
      authorization_header = "OAuth oauth_version='1.0',oauth_nonce='#{SecureRandom.uuid}',oauth_timestamp='#{Time.now.to_i}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{f1_secret}'"
      string = "curl -i --data '#{data}' #{url} -H 'Authorization: #{authorization_header}'"
      resp = IO.popen(string).readlines
      if resp.last.match(/oauth/).present?
        tokens = resp.last.split("&").map{|s| { s.split("=").first => s.split("=").last } }
        @oauth_token = tokens.first.merge(tokens.last)["oauth_token"]
        @oauth_token_secret = tokens.first.merge(tokens.last)["oauth_token_secret"]
        @user_link = resp.select{|s| s.match(/Content-Location:/) }.first.split(": ").last.gsub(/\r\n/, "")
        @errors = nil
      else
        @errors = resp.last
      end
    rescue
      @errors = "Connection Failed"
    end

    def get_person
      url = "#{user_link}.json"
      key = ENV["F1_KEY"]
      f1_secret = ENV["F1_SECRET"] + "%2526"
      oauth_signature = f1_secret + oauth_token_secret
      authorization_header = "OAuth oauth_version='1.0',oauth_token='#{oauth_token}',oauth_nonce='#{SecureRandom.uuid}',oauth_timestamp='#{Time.now.to_i}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{oauth_signature}'"
      curl_string = "curl --header 'Authorization: #{authorization_header}' #{url}"
      JSON.parse(IO.popen(curl_string).readlines.first)
    end

    def self.get_details(user_id)
      user = F1::User.find(user_id)
      key = ENV["F1_KEY"]
      f1_secret = ENV["F1_SECRET"] + "%2526"
      url = user.url.match(/json/) ? user.url : user.url + ".json"
      oauth_signature = f1_secret + user.secret
      authorization_header = "OAuth oauth_version='1.0',oauth_token='#{user.token}',oauth_nonce='#{SecureRandom.uuid}',oauth_timestamp='#{Time.now.to_i}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{oauth_signature}'"
      curl_string = "curl --header 'Authorization: #{authorization_header}' #{url}"
      JSON.parse(IO.popen(curl_string).readlines.first)
    end

    def self.get_new_user
      token = "09082d93-3ad1-4d7c-a9a1-78ac9e3c8ea9"
      secret = "a2d18e89-de81-4974-8515-3e3913140dc4"
      url = "https://chbhmal.staging.fellowshiponeapi.com/v1/accounts/new.json"
      key = ENV["F1_KEY"]
      f1_secret = ENV["F1_SECRET"] + "%2526"
      oauth_signature = f1_secret + secret
      authorization_header = "OAuth oauth_version='1.0',oauth_token='#{token}',oauth_nonce='#{SecureRandom.uuid}',oauth_timestamp='#{Time.now.to_i}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{oauth_signature}'"
      curl_string = "curl --header 'Authorization: #{authorization_header}' #{url}"
      response = JSON.parse(IO.popen(curl_string).readlines.first)
    end

    def self.create_user(options = {})
      token = "09082d93-3ad1-4d7c-a9a1-78ac9e3c8ea9"
      secret = "a2d18e89-de81-4974-8515-3e3913140dc4"
      url = "https://chbhmal.staging.fellowshiponeapi.com/v1/Accounts.json"
      key = ENV["F1_KEY"]
      f1_secret = ENV["F1_SECRET"] + "%2526"
      oauth_signature = f1_secret + secret
      url_redirect = "http://google.com"
      post_data = '{"firstName": "#{options[:first_name]}", "lastName": "#{options[:last_name]}", "email": "#{options[:email]}", "url-redirect": "#{url_redirect}"}'
      authorization_header = "OAuth oauth_version='1.0',oauth_token='#{token}',oauth_nonce='#{SecureRandom.uuid}',oauth_timestamp='#{Time.now.to_i}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{oauth_signature}'"
      curl_string = "curl --header 'Authorization: #{authorization_header}' -d '#{post_data}' #{url}"
      response = JSON.parse(IO.popen(curl_string).readlines.first)
    rescue
      binding.pry
    end

  end
end
