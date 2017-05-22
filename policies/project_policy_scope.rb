# frozen_string_literal: true

# Policy to determine if account can view a project
class ProjectPolicy
  # Scope of project policies
  class Scope
    def initialize(current_account, target_account)
      @scope = all_projects(target_account)
      @current_account = current_account
      @target_account = target_account
    end

    def viewable
      if @current_account == @target_account
        @scope
      else
        @scope.select { |proj| includes_contributor?(proj, @current_account) }
      end
    end

    private

    def all_projects(account)
      account.owned_projects + account.projects
    end

    def includes_contributor?(project, account)
      project.contributors.include? account
    end
  end
end
