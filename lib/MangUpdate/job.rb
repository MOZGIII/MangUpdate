module MangUpdate
  class Job
    attr_reader :name, :updates, :latest_revs
    
    def initialize(name, applies)
      @name = name
      @applies = applies      
      @updates = nil
      @latest_revs = {}
    end
    
    def collect_updates
      @updates = []
      @applies.each do |apply|
        type = apply.shift
        case type
        when :list
          options, filters = apply
          
          updates = []
          MangUpdate.lists(options).each do |list|
            next unless list.built?
            
            list.updates.each do |update|
              selected = filters.all? do |filter|
                filter.call(update, list)
              end
              
              if selected
                @latest_revs[list.name] = update.rev  
                updates << update
              end
            end
            
          end
          
          @updates << updates
        when :file
          filename, database, rev = apply
          model = Model::Common.new(filename, database, rev || 0)
          @updates << [ model ]
          
        when :inline
          sql, database, rev = apply
          model = Model::InlineSql.new(nil, database, rev || 0, { :sql => sql })
          @updates << [ model ]
          
        end
        
      end
    end
    
  end
end