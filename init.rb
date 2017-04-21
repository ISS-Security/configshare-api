folders = 'config,lib,models,services,controllers'
Dir.glob("./{#{folders}}/init.rb").each do |file|
  require file
end
