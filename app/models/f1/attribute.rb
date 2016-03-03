module F1
  class Attribute < Authenticate

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

    def get_attributes_for(user_id)
      get!(base_url + "People/#{user_id}/Attributes.json")
    end

    # TODO the person_id and attribute_id should default to nil when live
    def create_attribute(person_id = "54076399", attribute_id = "532789", start_date = nil, end_date = nil)
      url = base_url + "People/#{person_id}/Attributes.json"
      attrs = {
        "attribute" => {
          "person"=>{
            "@id"=>"#{person_id}",
            "@uri"=>"#{base_url}People/#{person_id}"
          },
          "attributeGroup"=>{
            "@id"=>"",
            "@uri"=>"",
            "name"=>"",
            "attribute"=>{
              "@id"=>"#{attribute_id}",
              "@uri"=>"",
              "name"=>""
            }
          },
          "startDate"=>"#{start_date}",
          "endDate"=>"#{end_date}",
          "comment"=>nil,
          "createdDate"=>nil,
          "lastUpdatedDate"=>nil
        }
      }
      data = attrs.to_json
      post!(url, data)
    rescue
      @errors = "Your junk is broke"
    end

  end
end
