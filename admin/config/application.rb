require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Admin
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # Allow requests from local, docker container, and domain hosts
    config.hosts << "app"
    config.hosts << "app:3000"
    config.hosts << "localhost"
    config.hosts << "127.0.0.1"
    config.hosts << "www.example.com"
    config.hosts << "example.com"
    config.hosts << /.*\.localhost/
    config.hosts << /.*\.trandat\.icu/
    config.hosts << /admin-web-.*/

    # Skip HostAuthorization for internal endpoints (health check and MediaMTX WebRTC auth webhook)
    config.host_authorization = {
      exclude: ->(request) { request.path.start_with?("/up", "/rooms/auth") }
    }

    config.i18n.available_locales = [ :vi, :en ]
    config.i18n.default_locale = "vi"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
