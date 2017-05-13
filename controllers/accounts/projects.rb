require 'sinatra'

# /api/v1/projects routes only
class ShareConfigurationsAPI < Sinatra::Base
  # Get all projects for an account
  get '/api/v1/accounts/:id/projects/?' do
    content_type 'application/json'

    begin
      id = params[:id]
      halt 401 unless authorized_account?(env, id)
      all_projects = FindAllAccountProjects.call(id: id)
      JSON.pretty_generate(data: all_projects)
    rescue => e
      logger.info "FAILED to find projects for user: #{e}"
      halt 404
    end
  end

  # Make a new project
  post '/api/v1/accounts/:id/owned_projects/?' do
    begin
      new_project_data = JSON.parse(request.body.read)
      saved_project = CreateProjectForOwner.call(
        owner_id: params[:id],
        name: new_project_data['name'],
        repo_url: new_project_data['repo_url']
      )
      new_location = URI.join(@request_url.to_s + '/',
                              saved_project.id.to_s).to_s
    rescue => e
      logger.info "FAILED to create new project: #{e.inspect}"
      halt 400
    end

    status 201
    headers('Location' => new_location)
  end
end
