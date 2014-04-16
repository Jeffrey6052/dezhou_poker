
require 'settingslogic'

class Settings < Settingslogic
  
  if ENV['SINAREY_ENV'] == 'heroku'
    source "#{Sinarey.root}/heroku/settings.yml"
  else
    source "#{Sinarey.root}/settings.yml"
  end

  namespace Sinarey.env
  load!
end