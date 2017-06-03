# frozen_string_literal: true
require 'sinatra'

# /api/v1/projects/:project_id/configurations routes
class ShareConfigurationsAPI < Sinatra::Base
  post '/api/v1/projects/:project_id/configurations/?' do
    content_type 'application/json'

    begin
      account = authenticated_account(env)
      project = Project[params[:project_id]]

      raise unless ProjectPolicy.new(account, project).can_add_configuration?

      config_data = JSON.parse(request.body.read)
      saved_config = CreateConfigurationForProject.call(
        project: project,
        filename: config_data['filename'],
        description: config_data['description'],
        document: config_data['document']
      )
    rescue => e
      logger.error "FAILED to create new config: #{e.inspect}"
      halt(401, 'Not authorized, or problem with configuration')
    end

    status 201
    saved_config.to_json
  end
end
