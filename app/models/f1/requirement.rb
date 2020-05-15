module F1
  class Requirement < Authenticate
    attr_accessor :attrs, :person_id, :requirement_id

    def initialize(test = !Rails.env.production?)
      @test = test
      username = ENV["F1_API_USER_USERNAME"]
      password = ENV["F1_API_USER_PASSWORD"]
      url = base_url + "PortalUser/AccessToken"
      data = "ec=" + signature(username, password)
      post_auth!(url, data)
    rescue
      @errors = "Connection Failed"
    end

    def get_requirements_for(user_id)
      get!(base_url + "People/#{user_id}/Requirements.json?recordsperpage=300")
    end

  end
end
