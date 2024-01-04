**NOTE FOR ACCLAIM:** This is only meant to get us past the Psych 5 update on our way to Rails 7.1. 
The old settings.yml way of config should be going away before the end of Q1 2024 and at that point 
this can be removed from the acclaim-server gemfile and this repo should be removed.


Choices for Rails
=================

Easy-peasy external settings for your Rails app.

~~~ rb
# Gemfile
gem 'choices'
~~~

In your app initializer block:

~~~ rb
config.from_file 'settings.yml'
~~~

This will read configuration from "config/settings.yml" and, additionally,
"settings.local.yml" if it exists. You should check the main file into version
control, but not the ".local" file which is to be used for per-machine
configuration: tweaks in development or private keys in production, for example.

~~~
# .gitignore
config/settings.local.yml
~~~

Configuration files can contain ERB; this is useful for reading in dynamic
config such as from environment variables:

~~~ yaml
# settings.yml
defaults: &defaults
  secret_token: <%= ENV['COOKIE_SECRET'] %>
  heroku: <%= !!ENV['HEROKU_TYPE'] %>
  mongodb:
    uri: <%= ENV['MONGOHQ_URL'] %>

development:
  <<: *defaults

test: &testing
  <<: *defaults
  secret_token: <%= "banana" * 5 %>
  mongodb:
    database: myapp_test

cucumber:
  <<: *testing
~~~

The ".local" file can contain overrides for your development environment:

~~~ yaml
# settings.local.yml
development:
  mongodb:
    database: myapp_dev
~~~

Finally, the config keys can be read in your app as such:

~~~ rb
Rails.configuration.heroku              #=> false
Rails.configuration.mongodb.database    #=> "myapp_dev"
~~~
