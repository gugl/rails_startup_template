# Rails Startup template

This is a template I use for my new Ruby on Rails 4 applications. **Pull requests are welcome.**

Also check out [Startup Readings](https://github.com/dennybritz/startupreadings).

## How to Use

```bash
rails new [app_name] -m https://raw.github.com/dennybritz/rails_startup_template/master/template.rb
```

## What it does

1. Adds the following gems:
  - [analytics-ruby](https://github.com/segmentio/analytics-ruby): I use [segment.io](https://segment.io/) as an anaytics provider. Segment.io is easy to integrate, asynchronous, and forwards data to other providers like Mixpanel and Kissmetrics.
  - bcrypt-ruby: I usually implement authentication myself instead of using gems like Devise. This is needed for the `has_secure_password` functionality. [See API Doc](http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html).
  - [bourbon](http://bourbon.io/): Bourbon provides useful SASS mixins for cross-browser compatibility.
  - (default)[Pundit](https://github.com/elabs/pundit): Simple, robust and scaleable authorization system.
  - (optional)[CanCan](https://github.com/ryanb/cancan): CanCan is an authorization library for Ruby on Rails which restricts what resources a given user is allowed to access.
  - [haml-rails](http://haml.info): HAML is a beautiful templating language. I prefer it over ERB.
  - [simple_form](https://github.com/plataformatec/simple_form): SimpleForm makes it easy to build complex form using simple markup.
  - uuidtools: To generate UUIDs, which is useful for various things.
  - [rspec-rails](https://github.com/rspec/rspec-rails): Rspec is a testing tool for test-driven and behavior-driven development. It makes writing specs more enjoyable.
  - [guard-rspec](https://github.com/guard/guard-rspec): Guard for automatically launching your specs when files are modified.
  - (test environment) [capybara](https://github.com/jnicklas/capybara): I use Capybara to write integration tests and simulate user behavior.
  - (test environment) [factory_girl_rails](https://github.com/thoughtbot/factory_girl): FactoryGirl provdes a flexible alternative to Rails fixtures.
  - (production environment) [rails_12factor](https://devcenter.heroku.com/articles/rails-integration-gems): This is needed for deploying Rails 4 applications on [Heroku](http://heroku.com).

2. Sets up [foreman](https://github.com/ddollar/foreman) to deal with environment variables and background services. Instead of using `rails s` you should use `foreman s`. Add your own environment variables in the `.env` file.

3. Cleans up assets by renaming `application.css` to `application.css.scss` and removing the `include_tree` directives. It's better design to import and require things manually. For example, `@import 'bourbon';`

4. Initializes a new git repository with an initial commit.

## TODO

Here are some things I'd like to add:

- Add Heroku-specific gems inside a question group, "Are you using Heroku?"

## Credits

- Although I changed a lot in my fork, thanks to [Denny Britz](https://github.com/dennybritz) for giving me a good starting point and inspiration.
- Some code for using multiple choice questions and improved questions is taken from the [Rails Composer](https://github.com/RailsApps/rails_apps_composer).
