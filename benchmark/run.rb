require 'bundler/setup'

require 'o/serializer'
require 'active_model_serializers'
require 'fast_jsonapi'
require 'benchmark/ips'

class User
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :id, :email, :password, :profile, :tags

  def active?
    true
  end

  def to_hash
    {
      id: id,
      is_active: active?,
      email: email,
      profile: profile ? profile.to_hash : nil,
      tags: tags.map(&:to_hash)
    }
  end

  # FastJsonapi doesn't support custom methods
  def is_active
    active?
  end

  # FastJsonapi uses FKs for optimizations
  def profile_id
    profile.id if profile
  end

  def tag_ids
    tags.map(&:id)
  end
end

class Profile
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :id, :first_name, :last_name

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

class Tag
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :id, :name

  def to_hash
    {
      name: name
    }
  end
end

tag1 = Tag.new(id: 1, name: 'tag1')
tag2 = Tag.new(id: 2, name: 'tag2')
tag3 = Tag.new(id: 3, name: 'tag3')

profile1 = Profile.new(id: 1, first_name: 'fname1', last_name: 'lname1')
profile2 = Profile.new(id: 2, first_name: 'fname2')

user1 = User.new(email: 'email1', profile: profile1, tags: [tag1, tag2])
user2 = User.new(email: 'email2', profile: profile2, tags: [tag2, tag3])
user3 = User.new(email: 'email3', profile: nil, tags: [], id: 'ID')

users = [user1, user2, user3]

module O
  TagSerializer = O::Serializer.new(
    name: O::Field[:name]
  )

  ProfileSerializer = O::Serializer.new(
    **O::PlainFields[
      :first_name,
      :last_name,
      :avatar
    ]
  )

  UserSerializer = O::Serializer.new(
    id: ->(user) { user.id },
    is_active: O::Field[:active?],
    email: O::Field[:email],
    profile: O::From[:profile, ProfileSerializer],
    tags: O::From[:tags, O::Many[TagSerializer]]
  )
end

module AMS
  class TagSerializer < ActiveModel::Serializer
    attributes :name
  end

  class ProfileSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name, :avatar
  end

  class UserSerializer < ActiveModel::Serializer
    attributes :id, :is_active, :email

    has_one :profile, serializer: ProfileSerializer
    has_many :tags, serializer: TagSerializer

    def is_active
      object.active?
    end
  end
end

module FastJsonApi
  class TagSerializer
    include FastJsonapi::ObjectSerializer
    attributes :name
  end

  class ProfileSerializer
    include FastJsonapi::ObjectSerializer
    attributes :first_name, :last_name, :avatar
  end

  class UserSerializer
    include FastJsonapi::ObjectSerializer

    attributes :id, :is_active, :email

    has_one :profile, serializer: ProfileSerializer
    has_many :tags, serializer: TagSerializer
  end
end

Benchmark.ips do |x|
  x.config time: 5, warmup: 2

  x.report '#to_hash' do
    users.map(&:to_hash)
  end

  x.report 'O::Serializer' do
    O::Many[O::UserSerializer].call(users)
  end

  x.report 'AMS' do
    ActiveModel::Serializer::CollectionSerializer.new(users, serializer: AMS::UserSerializer).as_json
  end

  x.report 'fast_jsonapi' do
    FastJsonApi::UserSerializer.new(users).serializable_hash
  end

  x.compare!
end

# p users.map(&:to_hash)
# p O::Many[O::UserSerializer].call(users)
# p ActiveModel::Serializer::CollectionSerializer.new(users, serializer: AMS::UserSerializer).as_json
# p FastJsonApi::UserSerializer.new(users).serializable_hash
