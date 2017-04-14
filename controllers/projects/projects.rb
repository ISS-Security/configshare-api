require 'sinatra'

# /api/v1/projects routes only
class ShareConfigurationsAPI < Sinatra::Base
  get '/api/v1/projects/?' do
    content_type 'application/json'

    JSON.pretty_generate(data: Project.all)
  end

  get '/api/v1/projects/:id' do
    content_type 'application/json'

    proj_id = params[:id]
    project = Project[proj_id]

    if project
      configurations = project.configurations
      JSON.pretty_generate(data: project, relationships: configurations)
    else
      error_msg = "PROJECT NOT FOUND: \"#{proj_id}\""
      logger.info error_msg
      halt 404, error_msg
    end
  end

  post '/api/v1/projects/?' do
    begin
      new_data = JSON.parse(request.body.read)
      saved_project = Project.create(new_data)
    rescue => e
      error_msg = "FAILED to create new project: #{e.inspect}"
      logger.info error_msg
      halt 400, error_msg
    end

    status 201
    headers('Location' => [@request_url.to_s, saved_project.id].join('/'))
  end
end
