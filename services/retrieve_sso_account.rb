require 'http'

# Find or create an SsoAccount based on Github code
class AuthenticateSsoAccount
  def initialize(config)
    @config = config
  end

  def call(access_token)
    github_account = get_github_account(access_token)
    sso_account = find_or_create_sso_account(github_account)

    [sso_account, AuthToken.create(sso_account)]
  end

  private_class_method

  def get_github_account(access_token)
    gh_account = HTTP.headers(user_agent: 'Config Secure',
                              authorization: "token #{access_token}",
                              accept: 'application/json')
                     .get('https://api.github.com/user').parse
    { username: gh_account['login'], email: gh_account['email'] }
  end

  def find_or_create_sso_account(github_account)
    SsoAccount.first(github_account) || SsoAccount.create(github_account)
  end
end
