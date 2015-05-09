{"changed":false,"filter":false,"title":"application.rb","tooltip":"/config/application.rb","value":"require File.expand_path('../boot', __FILE__)\n\nrequire 'rails/all'\n\n# Require the gems listed in Gemfile, including any gems\n# you've limited to :test, :development, or :production.\nBundler.require(*Rails.groups)\n\nmodule Workspace\n  class Application < Rails::Application\n    # Settings in config/environments/* take precedence over those specified here.\n    # Application configuration should go into files in config/initializers\n    # -- all .rb files in that directory are automatically loaded.\n\n    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.\n    # Run \"rake -D time\" for a list of tasks for finding time zone names. Default is UTC.\n    # config.time_zone = 'Central Time (US & Canada)'\n    config.assets.precompile << /\\.(?:svg|eot|woff|ttf)\\z/\n    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.\n    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]\n    # config.i18n.default_locale = :de\n  end\nend\n","undoManager":{"stack":[],"mark":-1,"position":-1},"ace":{"folds":[],"scrolltop":16,"scrollleft":0,"selection":{"start":{"row":23,"column":0},"end":{"row":23,"column":0},"isBackwards":false},"options":{"guessTabSize":true,"useWrapMode":false,"wrapToView":true},"firstLineState":{"row":0,"state":"start","mode":"ace/mode/ruby"}},"timestamp":1430685559551}