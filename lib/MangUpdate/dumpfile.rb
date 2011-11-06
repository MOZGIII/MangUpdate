require 'yaml'

module MangUpdate
  class Dumpfile
  
    class << self
      def load(path = "Mupfile.dump")
        from_hash(YAML.load(File.read(path)))
      rescue
        nil
      end
      
      def write(dump, path = "Mupfile.dump")
        File.open(path, "wb") do |f|
          f.write dump.to_hash.to_yaml
        end
      end
      
      def from_hash(hash)
        dumpfile = self.new
        dumpfile.revs = hash[:revs]
        dumpfile
      end
    end
    
    attr_accessor :revs
    def initialize(revs = {})
      @revs = revs
    end
    
    def update_revs(revs_new = {})
      revs_new.each do |key, value|
        @revs[key] = value if !@revs.key?(key) || @revs[key] < value
      end
    end
    
    def to_hash
      {
        :revs => revs
      }
    end
    
  end
end