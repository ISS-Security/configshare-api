require 'sinatra'

# /api/v1/projects routes only
class ShareConfigurationsAPI < Sinatra::Base
  def authorized_affiliated_project(env, project_id)
    account = authenticated_account(env)
    all_projects = FindAllAccountProjects.call(id: account['id'])
    all_projects.select { |proj| proj.id == project_id.to_i }.first
  rescue => e
    logger.error "ERROR finding project: #{e.inspect}"
    nil
  end

  # Get particular project for an account
  get '/api/v1/projects/:id' do
    content_type 'application/json'

    project_id = params[:id]
    project = authorized_affiliated_project(env, project_id)

    if project
      project.to_full_json
    else
      error_msg = "PROJECT NOT FOUND: \"#{project_id}\""
      logger.info error_msg
      halt 401, error_msg
    end
  end
end
