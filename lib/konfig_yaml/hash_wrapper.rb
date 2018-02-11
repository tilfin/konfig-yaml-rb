class KonfigYaml
  module HashWrapper
    def activate
      replace_hash_and_expand_env
      define_attr_readers
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

    # Convert to original Hash
    #
    # @return [Hash] hash
    # @param [Hash] opts the options to intialize
    # @option opts [String] :symbolize_names (true) whether symbolize names or not
    def to_h(opts = {})
      symbolize = opts.fetch(:symbolize_names, true)

      @h.map {|name, val|
        [symbolize ? name : name.to_s,
         val.is_a?(InnerHash) ? val.to_h(opts) : val]
      }.to_h
    end

    alias_method :each_pair, :each
    alias_method :has_key?, :include?
    alias_method :key?, :include?
    alias_method :member?, :include?

    private

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
        new_h[name.to_sym] = convert_value(val)
      end
      @h = new_h
    end

    def convert_value(val)
      if val.is_a?(Hash)
        InnerHash.new(val)
      elsif val.is_a?(String)
        val.gsub(/\$\{(.+?)\}/) {|m|
          env_key, default = $1.split(/:\-?/)
          ENV[env_key] || default || ''
        }
      else
        val
      end
    end
  end
end
