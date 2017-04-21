# Service object to create new accounts using all columns
class CreateAccount
  def self.call(registration)
    account = Account.new(
      username: registration[:username], email: registration[:email]
    )
    account.password = registration[:password]
    account.save
  end
end
