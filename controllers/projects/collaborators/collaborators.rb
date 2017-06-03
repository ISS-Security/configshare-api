# frozen_string_literal: true
require 'sinatra'

# /api/v1/projects/:project_id/configurations routes
class ShareConfigurationsAPI < Sinatra::Base
  post '/api/v1/projects/:project_id/collaborators/?' do
    content_type 'application/json'
    begin
      collab_criteria = JSON.parse request.body.read
      account = authenticated_account(env)
      collaborator = FindAccountByEmail.call(collab_criteria['email'])
      project = Project[params[:project_id]]
      raise('Unauthorized or not found') unless project && collaborator

      raise unless ProjectPolicy.new(account, project).can_add_contributor?

      collaborator = AddCollaboratorToProject.call(
        collaborator: collaborator,
        project: project
      )
      collaborator ? status(201) : raise('Could not add collaborator')
    rescue => e
      logger.info "FAILED to add collaborator to project: #{e.inspect}"
      halt 401
    end

    collaborator.to_json
  end
end
