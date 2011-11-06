require 'erb'

module MangUpdate
  module Templating
    class << self
    
      def init_template(options = {})
        b = binding
        template_filename = File.join(File.dirname(__FILE__), "templates", "Mupfile.erb")
        
        template = ERB.new(File.read(template_filename))
        template.filename = template_filename
        
        result = template.result(b)
        
        File.open(options[:mupfile], 'wb') do |f|
          f.puts(result)
        end
      end
      
    end
  end
end
