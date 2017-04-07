require 'sinatra'
require_relative 'config/environments'
require_relative 'models/init'

# Configuration Sharing API Web Service
class ShareConfigurationsAPI < Sinatra::Base
  before do
    host_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    @request_url = URI.join(host_url, request.path.to_s)
  end

  get '/?' do
    'ConfigShare web API up at /api/v1'
  end

  get '/api/v1/projects/?' do
    content_type 'application/json'

    JSON.pretty_generate(data: Project.all)
  end

  get '/api/v1/projects/:id' do
    content_type 'application/json'

    # TODO: Which way to retrieve a project: SQL style or pure ORM style?
    project = Project.where("id = #{params[:id]}").first
    # project = Project[id]

    configurations = project ? project.configurations : []

    if project
      JSON.pretty_generate(data: project, relationships: configurations)
    else
      error_msg = "PROJECT NOT FOUND: \"#{params[:id]}\""
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

  get '/api/v1/projects/:id/configurations/?' do
    content_type 'application/json'

    # TODO: Which way to retrieve a project: SQL style or pure ORM style?
    project = Project.where("id = #{params[:id]}").first
    # project = Project[id]

    configurations = project ? project.configurations : []

    JSON.pretty_generate(data: configurations)
  end

  get '/api/v1/projects/:project_id/configurations/:id/?' do
    content_type 'application/json'

    begin
      doc_url = URI.join(@request_url.to_s + '/', 'document')
      configuration = Configuration
                      .where(project_id: params[:project_id], id: params[:id])
                      .first
      halt(404, 'Configuration not found') unless configuration
      JSON.pretty_generate(data: {
                             configuration: configuration,
                             links: { document: doc_url }
                           })
    rescue => e
      error_msg = "FAILED to process GET configuration request: #{e.inspect}"
      logger.info error_msg
      halt 400, error_msg
    end
  end

  get '/api/v1/projects/:project_id/configurations/:id/document' do
    content_type 'text/plain'

    begin
      Configuration
        .where(project_id: params[:project_id], id: params[:id])
        .first
        .document
    rescue => e
      status 404
      e.inspect
    end
  end

  post '/api/v1/projects/:project_id/configurations/?' do
    begin
      new_data = JSON.parse(request.body.read)
      project = Project[params[:project_id]]
      saved_config = project.add_configuration(new_data)
    rescue => e
      error_msg = "FAILED to create new config: #{e.inspect}"
      logger.info error_msg
      halt 400, error_msg
    end

    status 201
    headers('Location' => [@request_url.to_s, saved_config.id].join('/'))
  end
end
