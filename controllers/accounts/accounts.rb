require 'sinatra'

# /api/v1/projects routes only
class ShareConfigurationsAPI < Sinatra::Base
  get '/api/v1/accounts/:id' do
    content_type 'application/json'

    id = params[:id]
    account = BaseAccount.first(id: id)

    if account
      projects = account.owned_projects
      JSON.pretty_generate(data: account, relationships: projects)
    else
      halt 401, "ACCOUNT NOT VALID: #{id}"
    end
  end

  post '/api/v1/accounts/?' do
    begin
      registration_info = JsonRequestBody.parse_symbolize(request.body.read)
      new_account = CreateAccount.call(registration_info)
    rescue => e
      logger.info "FAILED to create new account: #{e.inspect}"
      halt 400
    end

    new_location = URI.join(@request_url.to_s + '/', new_account.username).to_s

    status 201
    headers('Location' => new_location)
  end
end
