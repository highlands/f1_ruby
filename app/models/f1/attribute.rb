module F1
  class Attribute < Authenticate
    attr_accessor :attr

    def get_attributes
      create_header("#{user_link}/Attributes.json")
    end

    def set_attr
      @attr = {
        "attribute" => {
          "person"=>{
            "@id"=>"54076399",
            "@uri"=>"https://chbhmal.fellowshiponeapi.com/v1/People/54076399"
          },
          "attributeGroup"=>{
            "@id"=>"",
            "@uri"=>"",
            "name"=>"",
            "attribute"=>{
              "@id"=>"532789",
              "@uri"=>"",
              "name"=>""
            }
          },
          "startDate"=>nil,
          "endDate"=>nil,
          "comment"=>nil,
          "createdDate"=>nil,
          "lastUpdatedDate"=>nil
        }
      }
    end

    def create_attribute(person_id = "54076399", params = set_attr)
      if @test
        Excon.defaults[:ssl_verify_peer] = false
        url = "https://#{ENV["F1_CODE"]}.staging.fellowshiponeapi.com/v1/People/#{person_id}/Attributes.json"
      else
        url = "https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/People/#{person_id}/Attributes.json"
      end
      data = params.to_json
      create_header(url, data)
    rescue
      @errors = "Your junk is broke"
      binding.pry
    end

    def create_header(url, data)
      oauth_signature = get_secret + oauth_token_secret
      authorization_header = "OAuth oauth_version=\"1.0\",oauth_token=\"#{oauth_token}\",oauth_nonce=\"#{uid}\",oauth_timestamp=\"#{timestamp}\",oauth_consumer_key=\"#{get_key}\",oauth_signature_method=\"PLAINTEXT\",oauth_signature=\"#{oauth_signature}\""
      post!(url, authorization_header, data)
    rescue
      @errors = "Connection Failed"
      binding.pry
    end

    def post!(url, authorization_header, data = nil)
      resp = Excon.post(url, :body => data, :headers => { "Content-Type" => "application/json", "Authorization" => authorization_header })
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
    rescue
      binding.pry
    end

    # Request
    #
    # Given: [POST] https://demo.fellowshiponeapi.com/v1/People/1636208/Attributes.json
    #
    #{
    #    "attribute": {
    #        "@id": "",
    #        "@uri": "",
    #        "person": {
    #            "@id": "1636208",
    #            "@uri": "https://demo.fellowshiponeapi.com/v1/People/1636208"
    #        },
    #        "attributeGroup": {
    #            "@id": "",
    #            "@uri": "",
    #            "name": null,
    #            "attribute": {
    #                "@id": "958",
    #                "@uri": "",
    #                "name": null
    #            }
    #        },
    #        "startDate": null,
    #        "endDate": null,
    #        "comment": null,
    #        "createdDate": null,
    #        "lastUpdatedDate": null
    #    }
    #}

    # Response
    #
    #HTTP/1.1 201 Created
    #Cache-Control: private
    #Content-Type: application/json; charset=utf-8
    #Location: https://demo.fellowshiponeapi.com/v1/People/1636208/Attributes.json/29717646
    #Server: Microsoft-IIS/7.0
    #X-AspNetMvc-Version: 1.0
    #X-AspNet-Version: 2.0.50727
    #X-Powered-By: ASP.NET
    #Date: Fri, 01 May 2009 19:13:31 GMT
    #Content-Length: 551
    #
    #{
    #    "attribute": {
    #        "@id": "29717646",
    #        "@uri": "https://demo.fellowshiponeapi.com/v1/People/1636208/Attributes/29717646",
    #        "person": {
    #            "@id": "1636208",
    #            "@uri": "https://demo.fellowshiponeapi.com/v1/People/1636208"
    #        },
    #        "attributeGroup": {
    #            "@id": "145",
    #            "@uri": "https://demo.fellowshiponeapi.com/v1/People/AttributeGroups/145",
    #            "name": "Experiences",
    #            "attribute": {
    #                "@id": "958",
    #                "@uri": "https://demo.fellowshiponeapi.com/v1/People/AttributeGroups/145/Attributes/958",
    #                "name": "Baptism"
    #            }
    #        },
    #        "startDate": null,
    #        "endDate": null,
    #        "comment": null,
    #        "createdDate": "2009-05-01T14:13:29",
    #        "lastUpdatedDate": null
    #    }
    #}
    #{
    #  "attribute": {
    #    "@id": "",
    #    "@uri": "",
    #    "person": {
    #      "@id": "1636208",
    #      "@uri": "https://demo.fellowshiponeapi.com/v1/People/1636208"
    #    },
    #    "attributeGroup": {
    #      "@id": "",
    #      "@uri": "",
    #      "name": null,
    #      "attribute": {
    #        "@id": "958",
    #        "@uri": "",
    #        "name": null
    #      }
    #    },
    #    "startDate": null,
    #    "endDate": null,
    #    "comment": null,
    #    "createdDate": null,
    #    "lastUpdatedDate": null
    #  }
    #}
    #
    #{
    #  "@id"=>"104107976",
    #  "@uri"=>"https://chbhmal.fellowshiponeapi.com/v1/People/49474127/Attributes/104107976",
    #  "person"=>{
    #    "@id"=>"49474127",
    #    "@uri"=>"https://chbhmal.fellowshiponeapi.com/v1/People/49474127"
    #  },
    #  "attributeGroup"=>{
    #    "@id"=>"14313",
    #    "@uri"=>"https://chbhmal.fellowshiponeapi.com/v1/People/AttributeGroups/14313",
    #    "name"=>"Grants Mill Small Group Leadership",
    #    "attribute"=>{"@id"=>"729698",
    #      "@uri"=>"https://chbhmal.fellowshiponeapi.com/v1/People/AttributeGroups/14313/Attributes/729698",
    #      "name"=>"*Sm Grp Leader - Marriage"
    #    }
    #  },
    #  "startDate"=>"2015-09-06T00:00:00",
    #  "endDate"=>"2015-12-05T00:00:00",
    #  "comment"=>nil,
    #  "createdDate"=>"",
    #  "lastUpdatedDate"=>nil
    #}

    #{
    #  "@id"=>"104107976",
    #  "@uri"=>"https://chbhmal.fellowshiponeapi.com/v1/People/49474127/Attributes/104107976",
    #  "person"=>{
    #    "@id"=>"49474127",
    #    "@uri"=>"https://chbhmal.fellowshiponeapi.com/v1/People/49474127"
    #  },
    #  "attributeGroup"=>{
    #    "@id"=>"14313",
    #    "@uri"=>"https://chbhmal.fellowshiponeapi.com/v1/People/AttributeGroups/14313",
    #    "name"=>"Grants Mill Small Group Leadership",
    #    "attribute"=>{"@id"=>"729698",
    #      "@uri"=>"https://chbhmal.fellowshiponeapi.com/v1/People/AttributeGroups/14313/Attributes/729698",
    #      "name"=>"*Sm Grp Leader - Marriage"
    #    }
    #  },
    #  "startDate"=>"2015-09-06T00:00:00",
    #  "endDate"=>"2015-12-05T00:00:00",
    #  "comment"=>nil,
    #  "createdDate"=>"",
    #  "lastUpdatedDate"=>nil
    #}

  end
end
