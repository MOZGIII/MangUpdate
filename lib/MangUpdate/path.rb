require 'active_support/inflector'
module MangUpdate
  class Path
    
    def initialize(path, options = {})
      @path = path
      @options = options
      
      @model_class = get_model_class(options[:model] || :common)
      raise "Unable to load model!" unless @model_class
    end
    
    def scan
      Dir.glob(@path).each do |file|
        model = @model_class.build(file, @options)
        yield(model) if model
      end
    end
    
    private
    
    def get_model_class(name)
      name = name.to_s
      file_name   = name.underscore
      const_name  = name.camelize
      try_require = false
      begin
        require "MangUpdate/models/#{ file_name }" if try_require
        ::MangUpdate::Model.const_get(::MangUpdate::Model.constants.find { |c| c.to_s.downcase == const_name.downcase })
      rescue TypeError
        unless try_require
          try_require = true
          retry
        else
          UI.error "Could not find class MangUpdate::Model::#{ const_name }"
        end
      rescue LoadError => loadError
        UI.error "Could not load 'MangUpdate/models/#{ file_name }' or find class MangUpdate::Model::#{ const_name }"
        UI.error loadError.to_s
      end      
    end
    
  end
end