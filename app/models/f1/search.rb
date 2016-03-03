module F1
  class Search < Authenticate
    attr_accessor :attr

    def search_by_name(name = nil)
      get!("https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/People/Search.json?searchFor=#{name}")
    end

    def search_by_email(email = nil)
      get!("https://#{ENV["F1_CODE"]}.fellowshiponeapi.com/v1/People/Search.json?communication=#{email}&include=communications")
    end

  end
end
