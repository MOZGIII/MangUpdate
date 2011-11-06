module MangUpdate
  module Model

    class YtdbCore < Base
      APPLY_PRIORITY = 2
      
      def self.build(filename, options = {})
        data = File.basename(filename, '.sql').split('_')
        return if data[1] == 'corepatch' # skip all corepatches...      
        self.new filename, data[1], data[3].gsub(/[^0-9]/, '').to_i
      end
      
      def sort_data
        [rev, APPLY_PRIORITY]
      end
      
    end

  end
end