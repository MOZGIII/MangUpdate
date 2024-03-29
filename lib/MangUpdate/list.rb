module MangUpdate
  class List
    
    attr_reader :name, :updates
    attr_accessor :current_rev
    
    def initialize(name, paths)
      @name = name
      @paths = []
      @updates = []
      @built = false
      @current_rev = 0
      add_paths(paths)
    end
    
    def add_paths(paths)
      paths.each do |path|
        _path, options = path
        @paths << Path.new(_path, options) 
      end
    end
    
    def build!
      @built = true
      @paths.each do |path|
        path.scan do |update|
          @updates << update
        end
      end
      sort_list!(@updates)
    rescue
      @built = false
      raise
    end
    
    def built?
      @built
    end    
    
    private
    
    # This sorts the array of updates by it's sort_data field
    def sort_list!(list)
      list.sort! do |a,b|
        a, b = a.sort_data, b.sort_data
        i = 0
        i += 1 while a[i] == b[i] && (a[i+1] || b[i+1])
        if a[i] && b[i]
          a[i] <=> b[i]
        else
          a[i] ? 1 : -1
        end
      end
      list
    end
  
  end
end