# frozen_string_literal: true

folders = 'config,lib,models,policies,queries,services,controllers'
Dir.glob("./{#{folders}}/init.rb").each do |file|
  require file
end
