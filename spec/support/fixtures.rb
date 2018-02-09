module Serialization
  def read_attribute_for_serialization(attribute_name)
    public_send(attribute_name)
  end
end

# Simulates
#   class User < ActiveRecord::Base
#     has_one :profile
#     has_many :tags
#
#     def active?
#       true
#     end
#   end
#
User = Struct.new(:id, :email, :password, :profile, :tags, keyword_init: true) do
  include Serialization

  def active?
    true
  end

  def to_hash
    {
      id: id,
      is_active: active?,
      email: email,
      profile: profile.to_hash,
      tags: tags.map(&:to_hash)
    }
  end
end

# Simulates
#   class Profile < ActiveRecord::Base
#     def avatar
#       "https://example.com/#{first_name}-#{last_name}.png"
#     end
#   end
#
Profile = Struct.new(:id, :first_name, :last_name, keyword_init: true) do
  include Serialization

  def avatar
    "https://example.com/#{first_name}-#{last_name}.png"
  end

  def to_hash
    {
      first_name: first_name,
      last_name: last_name,
      avatar: avatar
    }
  end
end

# Simulates
#   class Tag < ActiveRecord::Base
#   end
#
Tag = Struct.new(:name, keyword_init: true) do
  include Serialization

  def to_hash
    {
      name: name
    }
  end
end
