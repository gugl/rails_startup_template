# Helper methods
# ==================================================

def say_custom(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end

def ask_wizard(question)
  ask "\033[1m\033[36m" + (@current_recipe || "prompt").rjust(10) + "\033[1m\033[36m" + "  #{question}\033[0m"
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def multiple_choice(question, choices)
  say_custom('question', question)
  values = {}
  choices.each_with_index do |choice,i|
    values[(i + 1).to_s] = choice[1]
    say_custom( (i + 1).to_s + ')', choice[0] )
  end
  answer = ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end


# Questions
# ==================================================

@use_devise           = yes_wizard?('Devise?')
@authorization_system = multiple_choice 'Authorization System?', [['Pundit (default)', :pundit], ['Cancan', :cancan]]

# Gems
# ==================================================

# Segment.io as an analytics solution (https://github.com/segmentio/analytics-ruby)
gem "analytics-ruby"

if @use_devise
  gem 'devise'
else
  # For encrypted password
  gem "bcrypt-ruby"
end

# Useful SASS mixins (http://bourbon.io/)
gem "bourbon"

gem 'figaro'
gem 'foundation-rails'
gem 'rails-i18n', '~> 4.0.0'
gem 'puma'

# Add gem for Authorization System
case @authorization_system
  when :cancan then gem 'cancan'
  when :pundit then gem 'pundit' # Simple, robust and scaleable authorization system (https://github.com/elabs/pundit)
end

# HAML templating language (http://haml.info)
gem "haml-rails"

# Foundation
gem 'foundation'

# Simple form builder (https://github.com/plataformatec/simple_form)
gem "simple_form", git: "https://github.com/plataformatec/simple_form"
# To generate UUIDs, useful for various things
gem "uuidtools"

gem_group :development do
  # Rspec for tests (https://github.com/rspec/rspec-rails)
  gem "rspec-rails"
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :mri_21, :rbx]

  # Guard for automatically launching your specs when files are modified. (https://github.com/guard/guard-rspec)
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-cucumber'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'html2haml'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
  gem 'simplecov'
  gem "erb2haml"
end

gem_group :test do
  gem "rspec-rails"
  # Capybara for integration testing (https://github.com/jnicklas/capybara)
  gem "capybara"
  gem "capybara-webkit"
  gem "launchy"
  # FactoryGirl instead of Rails fixtures (https://github.com/thoughtbot/factory_girl)
  gem "factory_girl_rails"

  gem 'cucumber-rails', :require=>false
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
end

gem_group :production do
  # For Rails 4 deployment on Heroku
  gem "rails_12factor"
end

# Environments
# ==================================================
environment 'config.action_mailer.default_url_options = { host: "localhost:3000" }', env: 'development'

# Setting up foreman to deal with environment variables and services
# https://github.com/ddollar/foreman
# ==================================================
# Use Procfile for foreman
run "echo 'web: bundle exec rails server -p $PORT' >> Procfile"
run "echo PORT=3000 >> .env"
run "echo '.env' >> .gitignore"
# We need this with foreman to see log output immediately
run "echo 'STDOUT.sync = true' >> config/environments/development.rb"

# Install gems
# ==================================================
run 'bundle install'

generate :controller, 'home index'
route "root 'home#index'"

# Initialize guard
# ==================================================
run "bundle exec guard init rspec"

# Initialize Authorization System
# ==================================================
case @authorization_system
  when :cancan
    run 'rails g cancan:ability'
  when :pundit
    run 'rails g pundit:install'
    inject_into_class 'app/controllers/application_controller.rb', 'ApplicationController', "  include Pundit\n"
end



# Figaro
# ==================================================
run 'rails g figaro:install'

# Testing
# ==================================================
run 'rails g rspec:install'
run 'rails g cucumber:install'
run 'rails g email_spec:steps'

# Database
# ==================================================
run 'rake db:create'
run 'rake db:migrate'

# Devise
# ==================================================

if @use_devise
  run 'rails generate devise:install'
  run 'rails generate devise User'
  run 'rake db:migrate'

  # run "echo 'before_action :authenticate_user!' >> app/controllers/application_controller.rb"

  file 'spec/support/devise.rb', <<-CODE
    RSpec.configure do |config|
      config.include Devise::TestHelpers, type: :controller
    end
  CODE
end

# Foundation
# ==================================================
# run 'rails g foundation:install --haml --force'
run "rails g simple_form:install --foundation"
run 'rails g layout:install foundation5 --force'
# run "echo '@import \"foundation_and_overrides\";' >>  app/assets/stylesheets/application.css.scss"
run "echo '@import \"framework_and_overrides\";' >>  app/assets/stylesheets/application.css.scss"
run "rails g layout:navigation"

if @use_devise
  # uncomment_lines 'config/initializers/devise.rb', 'config.scoped_views = false'

  # https://github.com/plataformatec/markerb
  # run 'rails generate devise:views users --markerb'
  # run 'rails generate devise:views --markerb'
  run 'rails generate layout:devise foundation5'
end

# Clean up Assets
# ==================================================
# Remove the require_tree directives from the SASS and JavaScript files.
# It's better design to import or require things manually.
run "sed -i '' /require_tree/d app/assets/javascripts/application.js"
run "sed -i '' /require_tree/d app/assets/stylesheets/application.css.scss"
# Add bourbon to stylesheet file
run "echo >> app/assets/stylesheets/application.css.scss"
run "echo '@import \"bourbon\";' >>  app/assets/stylesheets/application.css.scss"

# Replace ERB files with HAML
# ==================================================
rake 'haml:replace_erbs'

# Remove the --warning option from .rspec
gsub_file '.rspec', /--warnings\n/, ''

# Ignore rails doc files, Vim/Emacs swap files, .DS_Store, and more
# ===================================================
run "cat << EOF >> .gitignore
/.bundle
/db/*.sqlite3
/db/*.sqlite3-journal
/log/*.log
/tmp
database.yml
doc/
*.swp
*~
.project
.idea
.secret
.DS_Store
EOF"

# Git: Initialize
# ==================================================
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

# if yes?("Initialize GitHub repository?")
#   git_uri = `git config remote.origin.url`.strip
#   unless git_uri.size == 0
#     say "Repository already exists:"
#     say "#{git_uri}"
#   else
#     username = ask "What is your GitHub username?"
#     run "curl -u #{username} -d '{\"name\":\"#{app_name}\"}' https://api.github.com/user/repos"
#     git remote: %Q{ add origin git@github.com:#{username}/#{app_name}.git }
#     git push: %Q{ origin master }
#   end
# end
