require 'pathname'

# KonfigYaml main class
# @attr [String] name Use this if log message is not specified (by default this is 'No message').
# @attr [String] opts The field name of Exception (by default this is :err).
# @attr [Hash] with_fields The fields appending to all logs.
# @attr [Proc] before_log Hook before logging.
class KonfigYaml
  include HashWrapper

  def initialize(name = 'app', opts = {})
    env = ENV['RUBY_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    dir_path = Pathname(Dir.pwd).join(opts[:path] || 'config')
    use_cache = opts[:use_cache]
    use_cache = true if use_cache.nil?

    cfg_key = "#{name}/#{env}"
    if use_cache && cfg_cache.key?(cfg_key)
      @h = cfg_cache[cfg_key];
      activate
      return
    end

    cfg = load_file(name, dir_path);
    if cfg.include?(env)
      @h = deep_merge(cfg[env], cfg['default']);
    else
      @h = cfg['default']
    end

    if !@h
      throw new Error("The configuration for #{env} is not defined in #{name}");
    end
    cfg_cache[cfg_key] = @h

    activate
  end

  def cfg_cache
    @@cfg_cache ||= {}
  end

  def self.clear
    @@cfg_cache = {};
  end

  private

  def load_file(name, dir)
    cfg_path = Dir.glob("#{dir}/#{name}.{yml,yaml}").first
    raise 'Not found configuration yaml file' unless cfg_path
    YAML.load(File.read(cfg_path))
  end

  def deep_merge(target, default)
    target = {} unless target
    default = {} unless default
    target.merge!(default) do |key, target_val, default_val|
      if target_val.is_a?(Hash) && default_val.is_a?(Hash)
        deep_merge(target_val, default_val)
      else
        target_val
      end
    end
  end
end
