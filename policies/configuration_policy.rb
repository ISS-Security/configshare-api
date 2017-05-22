# frozen_string_literal: true

# Policy to determine if account can view a project
class ConfigurationPolicy
  def initialize(account, configuration)
    @account = account
    @configuration = configuration
  end

  def can_view?
    account_owns_project? || account_contributes_project?
  end

  def can_edit?
    account_owns_project? || account_contributes_project?
  end

  def can_delete?
    account_owns_project? || account_contributes_project?
  end

  def summary
    {
      view: can_view?,
      edit: can_edit?,
      delete: can_delete?
    }
  end

  private

  def account_owns_project?
    @configuration.project.owner == @account
  end

  def account_contributes_project?
    @configuration.project.contributors.include?(@account)
  end
end
