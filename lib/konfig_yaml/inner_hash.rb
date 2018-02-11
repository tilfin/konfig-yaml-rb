class KonfigYaml
  class InnerHash
    include HashWrapper

    def initialize(h)
      @h = h
      activate
    end
  end
end
