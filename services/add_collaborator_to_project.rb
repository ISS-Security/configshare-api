# frozen_string_literal: true

# Add a collaborator to another owner's existing project
class AddCollaboratorToProject
  def self.call(collaborator:, project:)
    return false if project.owner.id == collaborator.id
    collaborator.add_project(project)
    collaborator
  end
end
