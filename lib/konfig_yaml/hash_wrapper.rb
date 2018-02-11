class KonfigYaml
  module HashWrapper
    def activate
      replace_hash_and_expand_env
      define_attr_readers
    end

    def define_attr_readers
      self.instance_eval do |obj|
        s = class << self; self end
        @h.each_key do |name|
          s.send :define_method , name, lambda { @h[name] }
        end
      end
    end

    def replace_hash_and_expand_env
      new_h = {}
      @h.each do |name, val|
        key = name.to_sym
        if val.is_a?(Hash)
          new_h[key] = InnerHash.new(val)
        elsif val.is_a?(String)
          new_h[key] = val.gsub(/\$\{(.+?)\}/) do |m|
            env_key, default = $1.split(/:\-?/)
            default = '' if default.nil?
            ENV[env_key] || default
          end
        else
          new_h[key] = val
        end
      end
      @h = new_h
    end

    def [](key)
      @h[key.to_sym]
    end

    def []=(key, value)
      if value.is_a?(Hash)
        @h[key.to_sym] = InnerHash.new(value)
      else
        @h[key.to_sym] = value
      end
    end

    def each
      @h.each
    end

    def each_key
      @h.each_key
    end

    def each_value
      @h.each_value
    end

    def include?(key)
      @h.include?(key)
    end

    def to_h(opts = {})
      symbolize = opts.fetch(:symbolize_names, true)

      t = {}
      @h.each do |name, val|
        key = symbolize ? name : name.to_s
        if val.is_a?(InnerHash)
          t[key] = val.to_h(opts)
        else
          t[key] = val
        end
      end
      t
    end

    alias_method :each_pair, :each
    alias_method :has_key?, :include?
    alias_method :key?, :include?
    alias_method :member?, :include?
  end
end
