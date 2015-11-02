module F1
  class User < ActiveRecord::Base
    serialize :data, ActiveRecord::Coders::NestedHstore

    def name
      "#{first_name} #{last_name}"
    end

    def reverse_name
      "#{last_name}, #{first_name}"
    end

    def is_valid?(cookie_token, cookie_secret)
      token == cookie_token && secret == cookie_secret
    end

  end
end
