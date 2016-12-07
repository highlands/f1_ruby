module F1
  class Registration < Authenticate
    attr_accessor :attr

    def create_user(params = nil, redirect = nil)
      if @test
        # Excon.defaults[:ssl_verify_peer] = false
        url = "https://#{ENV["F1_CODE"]}.staging.fellowshiponeapi.com/v1/accounts.json"
      else
        url = "https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/accounts.json"
      end
      params["account"]["urlRedirect"] = redirect
      data = params.to_json
      #  resp = Excon.post(url, :body => data, :headers => { "Content-Type" => "application/json", "Authorization" => request_header })
      resp = HTTParty.post(url, :body => data, :headers => { "Content-Type" => "application/json", "Authorization" => request_header })
      if resp.code == 204
        @errors = nil
        @reason = "Successfuly created your account. Please check your email to complete registration." # resp.reason_phrase
      elsif resp.code == 409
        @errors = "An account already exists for the email address you provided."
        @has_account = true
        return false
      else
        @errors = "Connection Failed"
        return false
      end
    rescue
      @errors = "Failed to create your account"
    end

    def mock_user
      if @test
        get!("https://#{ENV["F1_CODE"]}.staging.fellowshiponeapi.com/v1/accounts/new.json")
      else
        get!("https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/accounts/new.json")
      end
    end

  end
end
