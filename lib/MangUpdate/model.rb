module MangUpdate
  module Model
    
    autoload :Common,     'MangUpdate/models/common'
    autoload :InlineSql,  'MangUpdate/models/inline_sql'
  
    class Base
      
      attr_reader :filename, :database, :rev, :info
      attr_accessor :applied
      
      def self.build(filename, options = {})
        raise "Do not know how to build #{name}"
        
        # Should be overwritten by subclasses with something like self.new ...
      end
      
      def initialize(filename, database, rev, info = {})
        @filename = filename
        @database = database
        @rev = rev
        @info = info
      end     
      
      def sort_data
        [rev]
      end
      
      def to_s
        "Rev#{rev} [#{self.class.name}:#{filename}]"
      end
      
      def upload
        MangUpdate.upload_file_to_db(filename, database)
      end
    end
  end
end