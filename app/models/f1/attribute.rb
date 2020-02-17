module F1
  class Attribute < Authenticate
    attr_accessor :attrs, :person_id, :attribute_id, :start_date, :end_date

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

    def delete_attribute_for(user_id, attribute_id)
      delete!(base_url + "People/#{user_id}/Attributes/#{attribute_id}")
    end

    def set_attrs
      @attrs = {
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
    end

    # TODO the person_id and attribute_id should default to nil when live
    def create_attribute(params = {})
      #person_id = 60109964, attribute_id = 532788, start_date = nil, end_date = nil
      url = base_url + "People/#{params["person_id"]}/Attributes.json"
      attrs = {
        "attribute" => {
          "person"=>{
            "@id"=>"#{params["person_id"]}",
            "@uri"=>"#{base_url}People/#{params["person_id"]}"
          },
          "attributeGroup"=>{
            "@id"=>"",
            "@uri"=>"",
            "name"=>"",
            "attribute"=>{
              "@id"=>"#{params["attribute_id"]}",
              "@uri"=>"",
              "name"=>""
            }
          },
          "startDate"=>"#{params["start_date"]}",
          "endDate"=>"#{params["end_date"]}",
          "comment"=>nil,
          "createdDate"=>nil,
          "lastUpdatedDate"=>nil
        }
      }
      data = attrs.to_json
      post!(url, data)
    rescue
      @errors = "Attribute error"
    end

    def update_attribute(person_id = "54076399", attribute_id = "532738", start_date = nil, end_date = nil)
      @person_id = person_id
      @attribute_id = attribute_id
      @start_date = start_date
      @end_date = end_date
      url = base_url + "People/#{person_id}/Attributes/#{attribute_id}.json"
      data = set_attrs.to_json
      put!(url, data)
    rescue
      @errors = "Attribute error"
    end

    def get_attribute_groups
      attrs = get!(base_url + "People/AttributeGroups.json")
      attrs["attributeGroups"]["attributeGroup"]
    end

    def get_attributes_list(attribute_group_id)
      get!(base_url + "People/AttributeGroups/#{attribute_group_id}/Attributes.json")
    end

    def parsed_attributes
      get_attribute_groups.select{|a| a["attribute"].present? }.map{|b| {"id" => b["@id"], "name" => b["name"], "attributes" => b["attribute"].map{|c| {"id" => c["@id"], "name" => c["name"] } } } }
    end

    def small_groups_attribute_groups
      parsed_attributes.select{|s| s["name"].match(/Small Group Leadership/) }
    end

  end
end
