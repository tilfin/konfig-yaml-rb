require 'pathname'

# KonfigYaml main class
# @attr [String] name Use this if log message is not specified (by default this is 'No message').
# @attr [String] opts The field name of Exception (by default this is :err).
# @attr [Hash] with_fields The fields appending to all logs.
# @attr [Proc] before_log Hook before logging.
class KonfigYaml
  include HashWrapper

  # @param [String] name ('app') the basename of yaml file
  # @param [Hash] opts the options to intialize
  # @option opts [String] :env (ENV['RUBY_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development') run environment
  # @option opts [String] :path ('config') directory path that contains the yaml file
  # @option opts [Boolean] :use_cache (true) whether cache settings or not
  def initialize(name = 'app', opts = nil)
    if name.is_a?(Hash) && opts.nil?
      opts = name
      name = 'app'
    elsif opts.nil?
      opts = {}
    end

    env = opts[:env] || ENV['RUBY_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    env = env.to_s
    use_cache = opts.fetch(:use_cache, true)

    cfg_key = "#{name}/#{env}"
    if use_cache && cfg_cache.key?(cfg_key)
      @h = cfg_cache[cfg_key];
      activate
      return
    end

    dir_path = File.expand_path(opts[:path] || 'config', Dir.pwd)
    cfg = load_file(name, dir_path);
    if cfg.include?(env)
      @h = deep_merge(cfg[env], cfg['default']);
    else
      @h = cfg['default']
    end

    raise ArgumentError.new("The configuration for #{env} is not defined in #{name}") unless @h

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
    raise ArgumentError.new("Not found configuration yaml file") unless cfg_path
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
