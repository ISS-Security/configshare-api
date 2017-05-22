# frozen_string_literal: true

# Policy to determine if an account can view a particular project
class ProjectPolicy
  def initialize(account, project)
    @account = account
    @project = project
  end

  def can_view_project?
    account_is_owner? || account_is_contributor?
  end

  # duplication is ok!
  def can_edit_project?
    account_is_owner? || account_is_contributor?
  end

  def can_delete_project?
    account_is_owner?
  end

  def can_leave_project?
    account_is_contributor?
  end

  def can_add_configuration?
    account_is_owner? || account_is_contributor?
  end

  def can_remove_configuration?
    account_is_owner? || account_is_contributor?
  end

  def can_add_contributor?
    account_is_owner?
  end

  def can_remove_contributor?
    account_is_owner?
  end

  def summary
    {
      view_project: can_view_project?,
      edit_project: can_edit_project?,
      delete_project: can_delete_project?,
      leave_project: can_leave_project?,
      add_configuration: can_add_configuration?,
      delete_configuration: can_remove_configuration?,
      add_contributor: can_add_contributor?,
      remove_contributor: can_remove_contributor?
    }
  end

  private

  def account_is_owner?
    @project.owner == @account
  end

  def account_is_contributor?
    @project.contributors.include?(@account)
  end
end
