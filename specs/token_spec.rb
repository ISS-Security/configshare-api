# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Unit test AuthToken class' do
  before do
    AuthToken.setup(app.settings.config.DB_KEY)
    @contents = { 'id' => 12 }.freeze
    @invalid_token = 'nonsense'
  end

  it 'HAPPY: should create tokens' do
    token = AuthToken.create(@contents)
    _(token).must_be_kind_of String
  end

  it 'HAPPY: be able to round-trip valid tokens' do
    token = AuthToken.create(@contents)
    returned = AuthToken.payload(token)
    _(returned).must_equal @contents
  end

  it 'SAD: tokenizing nil returns nil' do
    token = AuthToken.create(nil)
    returned = AuthToken.payload(token)
    _(returned).must_be_nil
  end

  it 'SAD: should raise error if expired token provided' do
    expired_token = AuthToken.create(@contents, 0)
    expired_token_parsing = proc { AuthToken.payload(expired_token) }
    _(expired_token_parsing).must_raise AuthToken::ExpiredTokenError
  end

  it 'BAD: should raise error if invalid token provided' do
    bad_token_parsing = proc { AuthToken.payload(@invalid_token) }
    _(bad_token_parsing).must_raise AuthToken::InvalidTokenError
  end

  it 'BAD: should raise error if nil token provided' do
    bad_token_parsing = proc { AuthToken.payload(nil) }
    _(bad_token_parsing).must_raise AuthToken::InvalidTokenError
  end
end
