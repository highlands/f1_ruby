module F1
  class Authenticate
    attr_accessor :oauth_token_secret, :oauth_token, :user_link, :errors, :test, :has_account

    def initialize(username = nil, password = nil, test = !Rails.env.production?)
      @test = test
      user_type = username.match(/@/) && username.match(/\./) ? "WeblinkUser" : "PortalUser"
      if test
        Excon.defaults[:ssl_verify_peer] = false
        url = "https://#{ENV["F1_CODE"]}.staging.fellowshiponeapi.com/v1/#{user_type}/AccessToken"
      else
        url = "https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/#{user_type}/AccessToken"
      end
      data = "ec=" + signature(username, password)
      authorization_header = "OAuth oauth_version=\"1.0\",oauth_nonce=\"#{uid}\",oauth_timestamp=\"#{timestamp}\",oauth_consumer_key=\"#{get_key}\",oauth_signature_method=\"PLAINTEXT\",oauth_signature=\"#{get_secret}\""
      authenticate!(url, authorization_header, data)
    rescue
      @errors = "Connection Failed"
    end

    #################################################
    # Methods to interact with fellowship one's api #
    #################################################

    def get_person_by_id(id)
      create_header("https://chbhmal.fellowshiponeapi.com/v1/People/#{id}.json")
    end

    def get_person
      create_header("#{user_link}.json")
    end

    def get_attributes
      create_header("#{user_link}/Attributes.json")
    end

    def get_requirements
      create_header("#{user_link}/requirements.json")
    end

    def get_communications
      create_header("#{user_link}/communications.json")
    end

    def get_addresses
      create_header("#{user_link}/addresses.json")
    end

    def search_by_name(name = nil)
      if @test
        create_header("https://#{ENV["F1_CODE"]}.staging.fellowshiponeapi.com/v1/People/Search.json?searchFor=#{name}")
      else
        create_header("https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/People/Search.json?searchFor=#{name}")
      end
    end

    def search_by_email(email = nil)
      if @test
        create_header("https://#{ENV["F1_CODE"]}.staging.fellowshiponeapi.com/v1/People/Search.json?communication=#{email}&include=communications")
      else
        create_header("https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/People/Search.json?communication=#{email}&include=communications")
      end
    end

    def associated_accounts(email = nil)
      results = create_header("https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/People/Search.json?communication=#{email}&include=communications")
      if results && results["results"].present? && results["results"]["person"].present?
        people_with_emails = results["results"]["person"].select{|s| s["communications"]["communication"].select{|t| t["communicationType"]["@id"] == "6" || t["communicationType"]["@id"] == "4" }.present? }
        people_with_emails.map{|s| {id: s["@id"], first_name: s["firstName"], last_name: s["lastName"], emails: get_emails(s["communications"]["communication"]), communications: s["communications"]["communication"].select{|s| s["communicationType"]["@id"] == "6" || s["communicationType"]["@id"] == "4" } } }
      else
        @errors = {errors: "No results found"}
      end
    end

    def get_emails(communications)
      communications.select{|s| s["communicationType"]["@id"] == "6" || s["communicationType"]["@id"] == "4" }.map{|s| s["communicationValue"] }
    end

    ####################################################

    def create_header(url)
      oauth_signature = get_secret + oauth_token_secret
      authorization_header = "OAuth oauth_version=\"1.0\",oauth_token=\"#{oauth_token}\",oauth_nonce=\"#{uid}\",oauth_timestamp=\"#{timestamp}\",oauth_consumer_key=\"#{get_key}\",oauth_signature_method=\"PLAINTEXT\",oauth_signature=\"#{oauth_signature}\""
      request!(url, authorization_header)
    rescue
      @errors = "Connection Failed"
    end

    def create_user(params = nil, redirect = nil)
      if @test
        Excon.defaults[:ssl_verify_peer] = false
        url = "https://#{ENV["F1_CODE"]}.staging.fellowshiponeapi.com/v1/accounts.json"
      else
        url = "https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/accounts.json"
      end
      oauth_signature = get_secret + oauth_token_secret
      authorization_header = "OAuth oauth_version=\"1.0\",oauth_token=\"#{oauth_token}\",oauth_nonce=\"#{uid}\",oauth_timestamp=\"#{timestamp}\",oauth_consumer_key=\"#{get_key}\",oauth_signature_method=\"PLAINTEXT\",oauth_signature=\"#{oauth_signature}\""
      params["account"]["urlRedirect"] = redirect
      data = params.to_json
      create_user!(url, authorization_header, data)
    rescue
      @errors = "Failed to create your account"
    end

    def mock_user
      if @test
        create_header("https://#{ENV["F1_CODE"]}.staging.fellowshiponeapi.com/v1/accounts/new.json")
      else
        create_header("https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/accounts/new.json")
      end
    end

    private

    def authenticate!(url, authorization_header, data = nil)
      resp = Excon.post(url, :body => data, :headers => { "Content-Type" => "application/x-www-form-urlencoded", "Authorization" => authorization_header })
      if resp.status == 200
        if resp.headers["oauth_token"].present? && resp.headers["oauth_token_secret"].present?
          @oauth_token = resp.headers["oauth_token"]
          @oauth_token_secret = resp.headers["oauth_token_secret"]
        elsif resp.headers["Oauth-Token"].present? && resp.headers["Oauth-Token-Secret"].present?
          @oauth_token = resp.headers["Oauth-Token"]
          @oauth_token_secret = resp.headers["Oauth-Token-Secret"]
        end
        @user_link = resp.headers["Content-Location"]
        @errors = nil
      elsif resp.reason_phrase.present?
        @errors = resp.reason_phrase
      else
        @errors = "Connection Failed"
      end

    end

    def request!(url, authorization_header)
      resp = Excon.get(url, :headers => { "Content-Type" => "application/json", "Authorization" => authorization_header })
      if resp.status == 200
        @errors = nil
        JSON.parse(resp.body)
      elsif resp.reason_phrase.present?
        @errors = resp.reason_phrase
      else
        @errors = "Connection Failed"
      end
    end

    def create_user!(url, authorization_header, data = nil)
      resp = Excon.post(url, :body => data, :headers => { "Content-Type" => "application/json", "Authorization" => authorization_header })
      if resp.status == 204
        @errors = nil
        @reason = resp.reason_phrase
      elsif resp.status == 409
        @errors = "An account already exists for the email address you provided."
        @has_account = true
        return false
      elsif resp.reason_phrase.present?
        @errors = resp.reason_phrase
        return false
      else
        @errors = "Connection Failed"
        return false
      end
    end

    def signature(username, password)
      URI.encode(Base64.encode64("#{username} #{password}"))
    end

    def timestamp
      Time.now.to_i
    end

    def uid
      SecureRandom.uuid
    end

    def get_key
      @test.present? ? ENV["F1_KEY_STAGING"] : ENV["F1_KEY"]
    end

    def get_secret
      @test.present? ? ENV["F1_SECRET_STAGING"] + "%2526" : ENV["F1_SECRET"] + "%2526"
    end

  end
end


