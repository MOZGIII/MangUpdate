module MangUpdate
  module Model

    class InlineSql < Base
      attr_reader :sql
    
      def self.build(filename, options = {})
        raise "#{name} can not be used as a model"
      end
      
      def initialize(filename, database, rev, info = {})
        super("<Inline SQL>", database, rev, info)
        @sql = @info[:sql]
      end
      
      def upload
        MangUpdate.upload_inline_sql(sql, database)
      end
      
    end

  end
end