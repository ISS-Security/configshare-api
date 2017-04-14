folders = 'config,lib,models,controllers'
Dir.glob("./{#{folders}}/init.rb").each do |file|
  require file
end
