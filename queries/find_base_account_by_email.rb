# frozen_string_literal: true

# Query all accounts and return first email match
class FindAccountByEmail
  def self.call(search_email)
    BaseAccount.first(email: search_email)
  end
end
