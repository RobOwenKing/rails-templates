run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    # For user accounts and authentication (https://github.com/heartcombo/devise)
    gem "devise"
    # Automatically add vendor prefixes to CSS rules (https://github.com/ai/autoprefixer-rails)
    gem "autoprefixer-rails"
    # Make forms easier (https://github.com/heartcombo/simple_form)
    gem "simple_form", github: "heartcombo/simple_form"

    # Icons (https://github.com/FortAwesome/font-awesome-sass)
    # gem "font-awesome-sass", "~> 6.1"
  RUBY
end

inject_into_file "Gemfile", after: 'gem "debug", platforms: %i[ mri mingw x64_mingw ]' do
  <<-RUBY

  # Load environment variables from .env into ENV in development (https://github.com/bkeepers/dotenv)
  gem "dotenv-rails"
  RUBY
end

gsub_file("Gemfile", '# gem "sassc-rails"', 'gem "sassc-rails"')

# Assets
########################################
inject_into_file "config/initializers/assets.rb", before: "# Precompile additional assets." do
  <<~RUBY
    Rails.application.config.assets.paths << Rails.root.join("node_modules")
  RUBY
end

# Flashes
########################################
file "app/views/shared/_flashes.html.erb", <<~HTML
  <% if notice %>
    <div role="alert">
      <%= notice %>
      <button type="button" aria-label="Close">
      </button>
    </div>
  <% end %>
  <% if alert %>
    <div role="alert">
      <%= alert %>
      <button type="button" aria-label="Close">
      </button>
    </div>
  <% end %>
HTML

inject_into_file "app/views/layouts/application.html.erb", after: "<body>" do
  <<~HTML
    <%= render "shared/flashes" %>
  HTML
end

# README
########################################
markdown_file_content = <<~MARKDOWN
  Rails app generated with a [template](https://github.com/RobOwenKing/rails-templates) by [RobOwenKing](http://robowenking.com/) based on [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
MARKDOWN
file "README.md", markdown_file_content, force: true

# Generators
########################################
generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :test_unit, fixture: false
  end
RUBY

environment generators

########################################
# After bundle
########################################
after_bundle do
  # Generators: db + simple form + pages controller
  ########################################
  rails_command "db:drop db:create db:migrate"
  generate("simple_form:install")
  generate(:controller, "pages", "home", "--skip-routes", "--no-test-framework")

  # Routes
  ########################################
  route 'root to: "pages#home"'

  # Gitignore
  ########################################
  setup_gitignore

  # Devise install + user
  ########################################
  generate("devise:install")
  generate("devise", "User")

  # Application controller
  ########################################
  overwrite_application_controller

  # migrate + devise views
  ########################################
  rails_command "db:migrate"
  generate_devise_views

  # Pages Controller
  ########################################
  overwrite_pages_controller

  # Environments
  ########################################
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: "development"
  environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }',
              env: "production"

  # Heroku
  ########################################
  run "bundle lock --add-platform x86_64-linux"

  # Dotenv
  ########################################
  run "touch '.env'"

  # Rubocop
  ########################################
  run "curl -L https://raw.githubusercontent.com/RobOwenKing/rails-templates/master/.rubocop.yml > .rubocop.yml"

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'feat: Basic Rails app setup using template at https://github.com/RobOwenKing/rails-templates'"
end

def setup_gitignore
  append_file ".gitignore", <<~TXT
    # Ignore .env file containing credentials.
    .env*
    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT
end

def overwrite_application_controller
  run "rm app/controllers/application_controller.rb"
  file "app/controllers/application_controller.rb", <<~RUBY
    class ApplicationController < ActionController::Base
      before_action :authenticate_user!
    end
  RUBY
end

def generate_devise_views
  generate("devise:views")
  gsub_devise_new_registration
  gsub_devise_new_session
  gsub_devise_edit_registration
end

def gsub_devise_new_registration
  gsub_file(
    "app/views/devise/registrations/new.html.erb",
    "<%= simple_form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f| %>",
    "<%= simple_form_for(resource, as: resource_name, url: registration_path(resource_name), data: { turbo: :false }) do |f| %>"
  )
end

def gsub_devise_new_session
  gsub_file(
    "app/views/devise/sessions/new.html.erb",
    "<%= simple_form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>",
    "<%= simple_form_for(resource, as: resource_name, url: session_path(resource_name), data: { turbo: :false }) do |f| %>"
  )
end

def gsub_devise_edit_registration
  link_to = <<~HTML
    <p>Unhappy? <%= link_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete %></p>
  HTML
  button_to = <<~HTML
    <div>
      <div>Unhappy?</div>
      <%= button_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete, class: "btn btn-link" %>
    </div>
  HTML
  gsub_file("app/views/devise/registrations/edit.html.erb", link_to, button_to)
end

def overwrite_pages_controller
  run "rm app/controllers/pages_controller.rb"
  file "app/controllers/pages_controller.rb", <<~RUBY
    class PagesController < ApplicationController
      skip_before_action :authenticate_user!, only: [ :home ]

      def home
      end
    end
  RUBY
end
