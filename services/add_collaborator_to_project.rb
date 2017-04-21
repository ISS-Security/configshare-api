# Add a collaborator to another owner's existing project
class AddCollaboratorToProject
  def self.call(collaborator_id:, project_id:)
    collaborator = Account.where(id: collaborator_id.to_i).first
    project = Project.first(id: project_id.to_i)
    return false if project.owner.id == collaborator.id
    collaborator.add_project(project)
    collaborator
  end
end
