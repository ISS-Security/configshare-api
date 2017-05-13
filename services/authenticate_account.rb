# Find account and check password
class AuthenticateAccount
  def self.call(credentials)
    account = Account.first(username: credentials[:username])
    return nil unless account&.password?(credentials[:password])
    { account: account, auth_token: AuthToken.create(account) }
  end
end
