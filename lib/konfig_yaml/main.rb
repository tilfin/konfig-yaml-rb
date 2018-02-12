require 'pathname'
require 'neohash'

# KonfigYaml main class
class KonfigYaml
  include NeoHash::Support

  # Create an configuration from yaml file
  #
  # @param [String] name ('app') the basename of yaml file
  # @param [Hash] opts the options to intialize
  # @option opts [String] :env (ENV['RUBY_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development') execution environment
  # @option opts [String] :path ('config') directory path that contains the yaml file
  # @option opts [Boolean] :use_cache (true) whether cache settings or not
  def initialize(name = 'app', opts = nil)
    if name.is_a?(Hash) && opts.nil?
      opts = name
      name = 'app'
    elsif opts.nil?
      opts = {}
    end

    path = File.expand_path(opts[:path] || 'config', Dir.pwd)
    env = environment(opts)
    use_cache = opts.fetch(:use_cache, true)

    h = load_config(name, env, path, use_cache)
    set_inner_hash(dup_hash_expand_envs(h))
  end

  # Clear caches
  def self.clear
    @@cfg_cache = {};
  end

  private

  def environment(opts)
    env = opts[:env]
    return env.to_s if env
    ENV['RUBY_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  end

  def cfg_cache
    @@cfg_cache ||= {}
  end

  def load_config(name, env, path, use_cache)
    cfg_key = "#{name}/#{env}"
    if use_cache && cfg_cache.key?(cfg_key)
      return cfg_cache[cfg_key]
    end

    data = load_yaml(name, path)
    cfg_cache[cfg_key] = convert_data_to_hash(data, env)
  end

  def load_yaml(name, dir)
    file_path = Dir.glob("#{dir}/#{name}.{yml,yaml}").first
    raise ArgumentError.new("Not found configuration yaml file") unless file_path
    YAML.load(File.read(file_path))
  end

  def convert_data_to_hash(data, env)
    if data.include?(env)
      deep_merge(data[env] || {}, data['default'] || {})
    elsif data.include?('default')
      data['default']
    else
      raise ArgumentError.new("The configuration for #{env} is not defined in #{name}")
    end
  end

  def deep_merge(target, default)
    target.merge(default) do |key, target_val, default_val|
      if target_val.is_a?(Hash) && default_val.is_a?(Hash)
        deep_merge(target_val, default_val)
      else
        target_val
      end
    end
  end

  def dup_hash_expand_envs(root)
    root.map do |name, val|
      if val.is_a?(Hash)
        [name, dup_hash_expand_envs(val)]
      elsif val.is_a?(Array)
        [name, dup_array_expand_envs(val)]
      elsif val.is_a?(String)
        [name, expand_envs(val)]
      else
        [name, val]
      end
    end.to_h
  end

  def dup_array_expand_envs(root)
    root.map do |val|
      if val.is_a?(Hash)
        dup_hash_expand_envs(val)
      elsif val.is_a?(Array)
        dup_array_expand_envs(val)
      elsif val.is_a?(String)
        expand_envs(val)
      else
        val
      end
    end
  end

  def expand_envs(str)
    str.gsub(/\$\{(.+?)\}/) do |m|
      env_key, default = $1.split(/:\-?/)
      ENV[env_key] || default || ''
    end
  end
end
