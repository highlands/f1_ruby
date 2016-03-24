module F1
  class Authenticate
    attr_accessor :oauth_token_secret, :oauth_token, :user_link, :errors, :test, :has_account

    def initialize(username = nil, password = nil, test = !Rails.env.production?)
      @test = test
      user_type = username.match(/@/) && username.match(/\./) ? "WeblinkUser" : "PortalUser"
      url = base_url + "#{user_type}/AccessToken"
      data = "ec=" + signature(username, password)
      post_auth!(url, data)
    rescue
      @errors = "Connection Failed"
    end

    #########################################################
    # Methods to create a user through fellowship one's api #
    #########################################################

    def create_user(params = nil, redirect = nil)
      url = base_url + "accounts.json"
      params["account"]["urlRedirect"] = redirect
      data = params.to_json
      resp = Excon.post(url, :body => data, :headers => { "Content-Type" => "application/json", "Authorization" => request_header })
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
    rescue
      @errors = "Failed to create your account"
    end

    def mock_user
      get!(base_url + "accounts/new.json")
    end

    #################################################
    # Methods to interact with fellowship one's api #
    #################################################

    def get_person_by_id(id)
      get!(base_url + "People/#{id}.json")
    end

    def get_person
      get!("#{user_link}.json")
    end

    def get_attributes
      get!("#{user_link}/Attributes.json")
    end

    def get_requirements
      get!("#{user_link}/requirements.json")
    end

    def get_communications
      get!("#{user_link}/communications.json")
    end

    def get_addresses
      get!("#{user_link}/addresses.json")
    end

    def search_by_name(name = nil)
      get!(base_url + "People/Search.json?searchFor=#{name}")
    end

    def search_by_email(email = nil)
      get!(base_url + "People/Search.json?communication=#{email}&include=communications")
    end

    def associated_accounts(email = nil)
      results = search_by_email(email)
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

    private

    def base_url
      if test
        Excon.defaults[:ssl_verify_peer] = false
        "https://#{ENV["F1_CODE"]}.staging.fellowshiponeapi.com/v1/"
      else
        "https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/"
      end
    end

    def get!(url)
      resp = Excon.get(url, :headers => { "Content-Type" => "application/json", "Authorization" => request_header })
      if resp.status == 200
        @errors = nil
        JSON.parse(resp.body)
      elsif resp.reason_phrase.present?
        @errors = resp.reason_phrase
      else
        @errors = "Connection Failed"
      end
    end

    def post!(url, data = nil)
      resp = Excon.post(url, :body => data, :headers => { "Content-Type" => "application/json", "Authorization" => request_header })
      if resp.status == 201
        @errors = nil
        @reason = resp.reason_phrase
      elsif resp.reason_phrase.present?
        @errors = resp.reason_phrase
        return false
      else
        @errors = "Connection Failed"
        return false
      end
    end

    # experimental for updating
    def put!(url, data = nil)
      resp = Excon.put(url, :body => data, :headers => { "Content-Type" => "application/json", "Authorization" => request_header })
      if resp.status == 201
        @errors = nil
        @reason = resp.reason_phrase
      elsif resp.reason_phrase.present?
        @errors = resp.reason_phrase
        return false
      else
        @errors = "Connection Failed"
        return false
      end
    end

    def post_auth!(url, data = nil)
      resp = Excon.post(url, :body => data, :headers => { "Content-Type" => "application/x-www-form-urlencoded", "Authorization" => authorization_header })
      handle_auth_response(resp)
    end

    def authorization_header
      "OAuth oauth_version=\"1.0\",oauth_nonce=\"#{uid}\",oauth_timestamp=\"#{timestamp}\",oauth_consumer_key=\"#{get_key}\",oauth_signature_method=\"PLAINTEXT\",oauth_signature=\"#{get_secret}\""
    end

    def request_header
      oauth_signature = get_secret + oauth_token_secret
      "OAuth oauth_version=\"1.0\",oauth_token=\"#{oauth_token}\",oauth_nonce=\"#{uid}\",oauth_timestamp=\"#{timestamp}\",oauth_consumer_key=\"#{get_key}\",oauth_signature_method=\"PLAINTEXT\",oauth_signature=\"#{oauth_signature}\""
    end

    def handle_auth_response(resp)
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


