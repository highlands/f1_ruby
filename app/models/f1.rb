class F1
  attr_accessor :url, :signature, :data, :key, :secret, :time, :uid, :authorization_header, :string, :oauth_token_secret, :oauth_token, :church_code, :env

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
    authenticate
  end

  def get_person(id = "54076399")
    @url = "https://#{@church_code}.#{@env}.fellowshiponeapi.com/v1/People/#{id}.json"
    get_time_and_uid
    @oauth_signature = secret + @oauth_token_secret
    @authorization_header = "OAuth oauth_version='1.0',oauth_token='#{oauth_token}',oauth_nonce='#{@uid}',oauth_timestamp='#{@time}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{@oauth_signature}'"
    JSON.parse(popen_get)
  end

  def search(str = "jwarren")
    str = URI.encode(str)
    @url = "https://#{@church_code}.#{@env}.fellowshiponeapi.com/v1/People/Search?searchFor=#{str}"
    get_time_and_uid
    @oauth_signature = secret + @oauth_token_secret
    @authorization_header = "OAuth oauth_version='1.0',oauth_token='#{oauth_token}',oauth_nonce='#{@uid}',oauth_timestamp='#{@time}',oauth_consumer_key='#{key}',oauth_signature_method='PLAINTEXT',oauth_signature='#{@oauth_signature}'"
    popen_get
    # returns an xml string, but no results
  end

  private

  def get_time_and_uid
    @time = Time.now.to_i
    @uid = SecureRandom.uuid
  end

  def authenticate
    @string = "curl --data '#{@data}' #{@url} -H 'Authorization: #{@authorization_header}'"
    resp = IO.popen(@string).readlines.first
    tokens = resp.split("&").map{|s| { s.split("=").first => s.split("=").last } }
    @oauth_token = tokens.first.merge(tokens.last)["oauth_token"]
    @oauth_token_secret = tokens.first.merge(tokens.last)["oauth_token_secret"]
  end

  def popen_get
    @string = "curl --header 'Authorization: #{@authorization_header}' #{@url}"
    IO.popen(@string).readlines.first
  end

  def excon_get
    resp = Excon.get(@url, :headers => {'Authorization' => @authorization_header })
  end

end

