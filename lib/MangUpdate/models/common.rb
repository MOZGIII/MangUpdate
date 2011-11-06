module MangUpdate
  module Model

    class Common < Base
      
      def self.build(filename, options = {})
        data = File.basename(filename, '.sql').split('_')
        self.new filename, data[1], data[0].gsub(/[^0-9]/, '').to_i
      end
      
    end

  end
end