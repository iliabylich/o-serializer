require 'spec_helper'

RSpec.describe O::Serializer do
  let(:tag1) { Tag.new(name: 'tag1') }
  let(:tag2) { Tag.new(name: 'tag2') }
  let(:tag3) { Tag.new(name: 'tag3') }

  let(:profile1) { Profile.new(first_name: 'fname1', last_name: 'lname1') }
  let(:profile2) { Profile.new(first_name: 'fname2') }

  let(:user1) { User.new(email: 'email1', profile: profile1, tags: [tag1, tag2]) }
  let(:user2) { User.new(email: 'email2', profile: profile2, tags: [tag2, tag3]) }
  let(:user3) { User.new(email: 'email3', profile: nil, tags: [], id: 'ID') }

  let(:tag_serializer) do
    O::Serializer[
      name: O::Field[:name]
    ]
  end

  let(:profile_serializer) do
    O::Serializer[
      **O::PlainFields[
        :first_name,
        :last_name,
        :avatar
      ]
    ]
  end

  let(:user_serializer) do
    O::Serializer[
      id: ->(user) { user.id },
      is_active: O::Field[:active?],
      email: O::Field[:email],
      profile: O::From[:profile, profile_serializer],
      tags: O::From[:tags, O::Many[tag_serializer]]
    ]
  end

  context 'tags' do
    context 'one' do
      it 'converts tag to hash' do
        expect(
          tag_serializer.call(tag1)
        ).to eq(
          tag1.to_hash
        )
      end
    end

    context 'many' do
      it 'converts tags to array of hash' do
        expect(
          O::Many[tag_serializer].call([tag1, tag2])
        ).to eq(
          [tag1.to_hash, tag2.to_hash]
        )
      end
    end
  end

  context 'profile' do
    context 'one' do
      it 'converts profile to hash' do
        expect(
          profile_serializer.call(profile1)
        ).to eq(
          profile1.to_hash
        )
      end
    end

    context 'many' do
      it 'converts profiles to array of hash' do
        expect(
          O::Many[profile_serializer].call([profile1, profile2])
        ).to eq(
          [profile1.to_hash, profile2.to_hash]
        )
      end
    end
  end

  context 'user' do
    context 'one' do
      it 'converts user to hash' do
        expect(
          user_serializer.call(user1)
        ).to eq(
          user1.to_hash
        )
      end
    end

    context 'many' do
      it 'converts profiles to array of hash' do
        expect(
          O::Many[user_serializer].call([user1, user2])
        ).to eq(
          [user1.to_hash, user2.to_hash]
        )
      end
    end
  end
end
