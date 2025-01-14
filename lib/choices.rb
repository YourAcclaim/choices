require 'hashie/mash'
require 'erb'
require 'yaml'

module Choices
  extend self
  
  def load_settings(filename, env)
    mash = Hashie::Mash.new(load_settings_hash(filename))
    
    with_local_settings(filename, '.local') do |local|
      mash.update local
    end

    mash.fetch(env) do
      raise IndexError, %{Missing key for "#{env}" in `#{filename}'}
    end
  end

  def load_settings_hash(filename)
    yaml_content = ERB.new(IO.read(filename)).result
    yaml_load(yaml_content)
  end
  
  def with_local_settings(filename, suffix)
    local_filename = filename.sub(/(\.\w+)?$/, "#{suffix}\\1")
    if File.exist? local_filename
      Logger.new(STDOUT).warn("Using settings.local.yml is deprecated and will be removed. Please migrate to .env.")
      hash = load_settings_hash(local_filename)
      yield hash if hash
    end
  end
  
  def yaml_load(content)
    if defined?(YAML::ENGINE) && defined?(Syck)
      # avoid using broken Psych in 1.9.2
      old_yamler = YAML::ENGINE.yamler
      YAML::ENGINE.yamler = 'syck'
    end
    begin
      YAML.safe_load(content, aliases: true, permitted_classes: [Symbol])
    ensure
      YAML::ENGINE.yamler = old_yamler if defined?(YAML::ENGINE) && defined?(Syck)
    end
  end
end

if defined? Rails
  require 'choices/rails'
end
