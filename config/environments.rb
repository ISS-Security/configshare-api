require 'sinatra'

configure :development do
  ENV['DATABASE_URL'] = 'sqlite://db/dev.db'

  def reload!
    # Tux reloading tip: https://github.com/cldwalker/tux/issues/3
    exec $PROGRAM_NAME, *ARGV
  end
end

configure :test do
  ENV['DATABASE_URL'] = 'sqlite://db/test.db'
end

configure :production do
  # Let Heroku set DATABASE_URL environment variable
end

configure do
  enable :logging

  require 'sequel'
  DB = Sequel.connect(ENV['DATABASE_URL'])

  require 'hirb'
  Hirb.enable
end
