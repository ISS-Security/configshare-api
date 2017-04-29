# Find account and check password
class AuthenticateAccount
  def self.call(credentials)
    account = Account.first(username: credentials['username'])
    account&.password?(credentials['password']) ? account : nil
  end
end
