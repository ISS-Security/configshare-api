# frozen_string_literal: true

# Find all projects (owned and contributed to) by an account
class FindAllAccountProjects
  def self.call(id:)
    account = BaseAccount.first(id: id)
    account.projects + account.owned_projects
  end
end
