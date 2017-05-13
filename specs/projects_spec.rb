require_relative 'spec_helper'

describe 'Testing Project resource routes' do
  before do
    Configuration.dataset.destroy
    Project.dataset.destroy
    Account.dataset.destroy
  end

  describe 'Creating new owned project for account owner' do
    before do
      @account = CreateAccount.call(
        username: 'soumya.ray',
        email: 'sray@nthu.edu.tw',
        password: 'mypassword')
    end

    it 'HAPPY: should create a new owned project for account' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { name: 'Demo Project' }.to_json
      post "/api/v1/accounts/#{@account.id}/owned_projects/",
           req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.location).must_match(%r{http://})
    end

    it 'SAD: should not create projects with duplicate names' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { name: 'Demo Project' }.to_json
      2.times do
        post "/api/v1/accounts/#{@account.id}/owned_projects/",
             req_body, req_header
      end
      _(last_response.status).must_equal 400
      _(last_response.location).must_be_nil
    end
  end

  describe 'Finding existing projects' do
    before do
      @my_account = CreateAccount.call(
        username: 'soumya.ray',
        email: 'sray@nthu.edu.tw',
        password: 'mypassword')

      @other_account = CreateAccount.call(
        username: 'lee123',
        email: 'lee@nthu.edu.tw',
        password: 'leepassword')

      @my_projs = []
      3.times do |i|
        @my_projs << @my_account.add_owned_project(
          name: "Project #{@my_account.id}-#{i}")
        @other_account.add_owned_project(
          name: "Project #{@other_account.id}-#{i}")
      end

      @other_account.owned_projects.each.with_index do |proj, i|
        @my_projs << @my_account.add_project(proj) if i < 2
      end
    end

    it 'HAPPY: should find an existing project' do
      new_project = @my_projs.first
      new_configs = (1..3).map do |i|
        new_project.add_configuration(filename: "config_file#{i}.rb")
      end

      auth = AuthenticateAccount.call(username: 'soumya.ray',
                                      password: 'mypassword')

      auth_headers = { 'HTTP_AUTHORIZATION' => "Bearer #{auth[:auth_token]}" }
      get "/api/v1/projects/#{new_project.id}", nil, auth_headers
      _(last_response.status).must_equal 200

      results = JSON.parse(last_response.body)
      _(results['id']).must_equal new_project.id
      3.times do |i|
        _(results['relationships']['configurations'][i]['id']).must_equal new_configs[i].id
      end
    end

    it 'SAD: should not find non-existent projects' do
      get "/api/v1/projects/#{invalid_id(Project)}"
      _(last_response.status).must_equal 401
    end
  end

  describe 'Get index of all projects for an account' do
    before do
      @my_account = CreateAccount.call(
        username: 'soumya.ray',
        email: 'sray@nthu.edu.tw',
        password: 'mypassword')

      @other_account = CreateAccount.call(
        username: 'lee123',
        email: 'lee@nthu.edu.tw',
        password: 'leepassword')

      @my_projs = []
      3.times do |i|
        @my_projs << @my_account.add_owned_project(
          name: "Project #{@my_account.id}-#{i}")
        @other_account.add_owned_project(
          name: "Project #{@other_account.id}-#{i}")
      end

      @other_account.owned_projects.each.with_index do |proj, i|
        @my_projs << @my_account.add_project(proj) if i < 2
      end
    end

    it 'HAPPY: should find all projects for an account' do
      auth = AuthenticateAccount.call(username: 'soumya.ray',
                                      password: 'mypassword')

      auth_headers = { 'HTTP_AUTHORIZATION' => "Bearer #{auth[:auth_token]}" }
      result = get "/api/v1/accounts/#{@my_account.id}/projects", nil, auth_headers
      _(result.status).must_equal 200
      projs = JSON.parse(result.body)

      valid_ids = @my_projs.map(&:id)
      _(projs['data'].count).must_equal 5
      projs['data'].each do |proj|
        _(valid_ids).must_include proj['id']
      end
    end
  end
end
