require 'bundler/setup'

require 'o/serializer'
require 'active_model_serializers'
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

  attr_accessor :name

  def to_hash
    {
      name: name
    }
  end
end

tag1 = Tag.new(name: 'tag1')
tag2 = Tag.new(name: 'tag2')
tag3 = Tag.new(name: 'tag3')

profile1 = Profile.new(first_name: 'fname1', last_name: 'lname1')
profile2 = Profile.new(first_name: 'fname2')

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

    def id
      object.id
    end
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

  x.compare!
end
