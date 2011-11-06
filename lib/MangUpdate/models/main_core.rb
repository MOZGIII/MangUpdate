module MangUpdate
  module Model

    class MainCore < Base
      APPLY_PRIORITY = 1
      
      def self.build(filename, options = {})
        data = File.basename(filename, '.sql').split('_')
        self.new filename, data[2], data[0].to_i, :num => data[1].to_i
      end
      
      def sort_data
        [rev, APPLY_PRIORITY, info[:num]]
      end
      
    end

  end
end