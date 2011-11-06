module MangUpdate
  
  autoload :Dsl,        'MangUpdate/dsl'
  autoload :UI,         'MangUpdate/ui'
  autoload :Templating, 'MangUpdate/templating'
  autoload :List,       'MangUpdate/list'
  autoload :Path,       'MangUpdate/path'
  autoload :Model,      'MangUpdate/model'
  autoload :Job,        'MangUpdate/job'
  autoload :Dumpfile,   'MangUpdate/dumpfile'
  
  class << self
    attr_accessor :options
    
    def run(options = {})
      @lists           = []
      @jobs            = []
      @loaded_dumpfile = nil
      @options         = Dsl.evaluate_mupfile(options)
      
      build_lists
      
      load_dumpfile
      
      unless check_database_auth_info
        UI.error "Database user and password must be supplied"
        exit 1
      end
      
      new_dumpfile = Dumpfile.new
      execute_jobs(new_dumpfile)
      
      dump_write(new_dumpfile) unless @options[:nodump]
    end
    
    def initialize_template(options = {})
      options = { :mupfile => "Mupfile" }.merge(options)
      if File.exist?(options[:mupfile])
        UI.error "Mupfile already exists at #{ File.expand_path(options[:mupfile]) }"
        exit 1
      end
      
      Templating.init_template({ :mupfile => "Mupfile" }.merge(options))
      UI.info "Mupfile generated, feel free to edit it"
    end
    
    def lists(filter = nil)
      case filter
      when Hash
        if filter[:except]
          array = filter[:except].kind_of?(Array) ? filter[:except] : [ filter[:except] ]
          @lists.find_all { |list| !array.member?(list.name) }
          
        elsif filter[:only]
          array = filter[:only].kind_of?(Array) ? filter[:only] : [ filter[:only] ]
          @lists.find_all { |list| array.member?(list.name) }
          
        else
          @lists
          
        end
      when String, Symbol
        @lists.find { |list| list.name == filter }
      when Regexp
        @lists.find_all { |list| list.name.to_s =~ filter }
      when Proc
        @lists.find_all { |list| filter.call(list) }
      else
        @lists
      end
    end
    
    def add_list(name, paths)
      list = lists(name)
      if list.nil?
        list = List.new(name, paths)
        @lists << list
      else
        unless list.built?
          list.add_paths(paths)
        else
          raise "List #{name} was already built, you can't add more paths to it!"
        end
      end
      list
    end
    
    def add_job(name, uploads)
      job = Job.new(name, uploads)
      @jobs << job
    end
    
    def build_lists
      fully_built = lists.inject(true) do |valid, list|
        list.build!
        valid &&= list.built?
      end
      
      raise "Some lists are not fully built!" unless fully_built
    end
    
    def execute_jobs(dumpfile)
      lists.each do |list|
        dumpfile.update_revs({ list.name => list.current_rev })
      end
      
      @jobs.each do |job|
        UI.info "Running job: #{job.name}"
        
        job.collect_updates
        
        dumpfile.update_revs(job.latest_revs)
        
        job.updates.flatten.each do |update|
          UI.info update.filename if @options[:list]
          update.upload unless @options[:dry_run]
        end
        
      end
    end
    
    def check_database_auth_info
      [ :mysql_user, :mysql_pass ].all? do |param|
        @options[param] && !@options[param].empty?
      end
    end
    
    def upload_file_to_db(path, database)
      user = @options[:mysql_user]
      pass = @options[:mysql_pass]
      command = %Q[mysql -u"#{user}" -p"#{pass}" -D"#{database}" < "#{path}"]
      UI.debug "SYSTEM: #{command}"
      system command
    end
    
    def upload_inline_sql(sql, database = nil)
      user = @options[:mysql_user]
      pass = @options[:mysql_pass]
      
      command = %Q[mysql -u"#{user}" -p"#{pass}" -D"#{database}" -B -s -e "#{sql.gsub('"', '\"')}"]
      UI.debug "SYSTEM: #{command}"
      system command
    end
    
    def load_dumpfile
      @loaded_dumpfile = Dumpfile.load
      
      @loaded_dumpfile.revs.each do |key, value|
        list = lists(key)
        list.current_rev = value if list
      end
    end
    
    def dump_write(dump)
      Dumpfile.write(dump)
    end
    
  end
end
