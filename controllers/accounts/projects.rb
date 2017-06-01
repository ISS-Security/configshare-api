require 'sinatra'

# /api/v1/projects routes only
class ShareConfigurationsAPI < Sinatra::Base
  # Get all projects for an account
  get '/api/v1/accounts/:account_id/projects/?' do
    content_type 'application/json'

    begin
      requesting_account = authenticated_account(env)
      target_account = BaseAccount[params[:account_id]]

      viewable_projects =
        ProjectPolicy::Scope.new(requesting_account, target_account).viewable
      JSON.pretty_generate(data: viewable_projects)
    rescue
      error_msg = "FAILED to find projects for user: #{params[:account_id]}"
      logger.info error_msg
      halt 404, error_msg
    end
  end
end
