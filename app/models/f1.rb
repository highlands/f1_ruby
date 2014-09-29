class F1

  attr_accessor :url, :signature, :data, :key, :secret, :time, :uid, :authorization_header, :string, :oauth_token_secret, :oauth_token, :church_code, :env, :user_link, :errors

  def initialize(username = nil, password = nil, church_code = "chbhmal", env = "staging")
    @church_code = church_code
    @env = env
    @url = "https://#{@church_code}.#{@env}.fellowshiponeapi.com/v1/PortalUser/AccessToken"
    @signature = URI.encode(Base64.encode64("#{username} #{password}"))
    @data = "ec=" + @signature
    @key = ENV["F1_KEY"]
    @secret = ENV["F1_SECRET"] + "%2526"
    get_time_and_uid
    @authorization_header = "OAuth oauth_version='1.0',oauth_nonce='#{@uid}',oauth_timestamp='#{@time}',oauth_consumer_key='#{@key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{@secret}'"
    @string = "curl -i --data '#{@data}' #{@url} -H 'Authorization: #{@authorization_header}'"
    authenticate
  end

  def get_person(id = "54076399")
    @url = "#{user_link}.json"
    get_time_and_uid
    @oauth_signature = secret + @oauth_token_secret
    @authorization_header = "OAuth oauth_version='1.0',oauth_token='#{oauth_token}',oauth_nonce='#{@uid}',oauth_timestamp='#{@time}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{@oauth_signature}'"
    @string = "curl --header 'Authorization: #{@authorization_header}' #{@url}"
    JSON.parse(popen.first)
  end

  private

  def get_time_and_uid
    @time = Time.now.to_i
    @uid = SecureRandom.uuid
  end

  def authenticate
    resp = popen
    if resp.last.match(/oauth/).present?
      tokens = resp.last.split("&").map{|s| { s.split("=").first => s.split("=").last } }
      @oauth_token = tokens.first.merge(tokens.last)["oauth_token"]
      @oauth_token_secret = tokens.first.merge(tokens.last)["oauth_token_secret"]
      @user_link = resp.select{|s| s.match(/Content-Location:/) }.first.split(": ").last.gsub(/\r\n/, "")
      @errors = nil
    else
      @errors = resp.last
    end
  end

  def popen
    IO.popen(@string).readlines
  end

end
