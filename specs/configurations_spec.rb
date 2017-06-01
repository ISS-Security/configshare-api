# frozen_string_literal: true

require_relative './spec_helper'

describe 'Testing Configuration resource routes' do
  before do
    Configuration.dataset.destroy
    Project.dataset.destroy
    BaseAccount.dataset.destroy
  end

  describe 'Creating new configurations for projects' do
    it 'HAPPY: should add a new configuration for an existing project' do
      existing_project = Project.create(name: 'Demo Project')

      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { filename: 'Demo Configuration' }.to_json
      post "/api/v1/projects/#{existing_project.id}/configurations",
           req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.location).must_match(%r{http://})
    end

    it 'SAD: should not add a configuration for non-existant project' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { filename: 'Demo Configuration' }.to_json
      post "/api/v1/projects/#{invalid_id(Project)}/configurations",
           req_body, req_header
      _(last_response.status).must_equal 400
      _(last_response.location).must_be_nil
    end

    it 'SAD: should catch duplicate config files within a project' do
      existing_project = Project.create(name: 'Demo Project')
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { filename: 'conflict.yml' }.to_json
      url = "/api/v1/projects/#{existing_project.id}/configurations"

      2.times { post url, req_body, req_header }
      _(last_response.status).must_equal 400
      _(last_response.location).must_be_nil
    end
  end

  describe 'Getting configurations' do
    it 'HAPPY: should find existing configuration' do
      config = Project.create(name: 'Demo Project')
                      .add_configuration(filename: 'demo_config.rb')
      get "/api/v1/projects/#{config.project_id}/configurations/#{config.id}"
      _(last_response.status).must_equal 200
      parsed_config = JSON.parse(last_response.body)['data']['configuration']
      _(parsed_config['type']).must_equal 'configuration'
    end

    it 'SAD: should not find non-existant project and configuration' do
      proj_id = invalid_id(Project)
      config_id = invalid_id(Configuration)
      get "/api/v1/projects/#{proj_id}/configurations/#{config_id}"
      _(last_response.status).must_equal 404
    end

    it 'SAD: should not find non-existant configuration for existing project' do
      proj_id = Project.create(name: 'Demo Project').id
      config_id = invalid_id(Configuration)
      get "/api/v1/projects/#{proj_id}/configurations/#{config_id}"
      _(last_response.status).must_equal 404
    end
  end
end

describe 'Creating Secure Content on Configurations' do
  before do
    Configuration.dataset.destroy
    Project.dataset.destroy
    BaseAccount.dataset.destroy
  end

  it 'HAPPY: should find existing configuration' do
    plaindesc = 'config file'
    plaindoc = "---\nSECRET: secrets here"
    project = Project.create(name: 'Demo Project')
    config = CreateConfigurationForProject.call(
      project: project, filename: 'config.yml',
      description: plaindesc, document: plaindoc
    )

    _(config.document).must_equal plaindoc
    _(config.document_secure).wont_equal plaindoc
    _(config.document_secure).wont_be_nil

    _(config.description).must_equal plaindesc
    _(config.description_secure).wont_equal plaindesc
    _(config.description_secure).wont_be_nil
  end
end
