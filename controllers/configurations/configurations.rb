require 'sinatra'

# /api/v1/projects/:project_id/configurations routes
class ShareConfigurationsAPI < Sinatra::Base
  get '/api/v1/configurations/:config_id/?' do
    content_type 'application/json'

    begin
      account = authenticated_account(env)
      configuration = Configuration.find(id: params[:config_id])
      raise unless configuration
      config_policy = ConfigurationPolicy.new(account, configuration)
      raise unless config_policy.can_view?
      configuration.to_full_json
    rescue => e
      status 401
      logger.error "FAILED to process GET configuration request: #{e.inspect}"
    end
  end
end
