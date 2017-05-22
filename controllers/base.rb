# frozen_string_literal: true
require 'econfig'
require 'sinatra'

# Configuration Sharing API Web Service
class ShareConfigurationsAPI < Sinatra::Base
  extend Econfig::Shortcut

  configure do
    Econfig.env = settings.environment.to_s
    Econfig.root = File.expand_path('..', settings.root)

    SecureDB.setup(settings.config.DB_KEY)
    AuthToken.setup(settings.config.DB_KEY)
  end

  def secure_request?
    request.scheme.casecmp(settings.config.SECURE_SCHEME).zero?
  end

  def authenticated_account(env)
    scheme, auth_token = env['HTTP_AUTHORIZATION'].split(' ')
    return nil unless scheme.match?(/^Bearer$/i)

    account_payload = AuthToken.payload(auth_token)
    Account[account_payload['id']]
  end

  def authorized_account?(env, id)
    account = authenticated_account(env)
    account.id.to_s == id.to_s
  rescue
    false
  end

  before do
    halt(403, 'Use HTTPS only') unless secure_request?

    host_url = "#{settings.config.SECURE_SCHEME}://#{request.env['HTTP_HOST']}"
    @request_url = URI.join(host_url, request.path.to_s)
  end

  get '/?' do
    'ConfigShare web API up at /api/v1'
  end
end
