require 'sinatra'

# /api/v1/projects/:project_id/configurations routes
class ShareConfigurationsAPI < Sinatra::Base
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
