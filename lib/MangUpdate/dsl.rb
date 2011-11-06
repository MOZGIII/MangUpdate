module MangUpdate
  class Dsl
    
    class << self

      @@options = nil
      @@configs = nil

      # Evaluate the DSL methods in the `Mupfile`.
      #
      def evaluate_mupfile(options = {})
        raise ArgumentError.new('No option hash passed to evaluate_mupfile!') unless options.is_a?(Hash)

        @@options = options.dup
        @@configs = {}

        fetch_mupfile_contents
        instance_eval_mupfile(mupfile_contents)
        
        @@configs.each do |key, value|
          @@options[key] = value unless @@options.key?(key)
        end
        @@options
      end

      def instance_eval_mupfile(contents)
        new.instance_eval(contents, @@options[:mupfile_path], 1)
      rescue
        UI.error "Invalid Mupfile, original error is:\n#{ $! }"
        raise if @@options[:debug]
        exit 1
      end
      
      def read_mupfile(mupfile_path)
        @@options[:mupfile_path]     = mupfile_path
        @@options[:mupfile_contents] = File.read(mupfile_path)
      rescue
        UI.error("Error reading file #{ mupfile_path }")
        exit 1
      end

      # Get the content to evaluate and stores it into
      # the options as `:mupfile_contents`.
      #
      def fetch_mupfile_contents
        if @@options[:mupfile_contents]
          UI.info 'Using inline Mupfile.'
          @@options[:mupfile_path] = 'Inline Mupfile'

        elsif @@options[:mupfile]
          if File.exist?(@@options[:mupfile])
            read_mupfile(@@options[:mupfile])
            UI.info "Using Mupfile at #{ @@options[:mupfile] }."
          else
            UI.error "No Mupfile exists at #{ @@options[:mupfile] }."
            exit 1
          end

        else
          if File.exist?(mupfile_default_path)
            read_mupfile(mupfile_default_path)
          else
            UI.error 'No Mupfile found, please create one with `mangupdate init`.'
            exit 1
          end
        end

        if mupfile_contents.empty?
          UI.error "The command file(#{ @@options[:mupfile] }) seems to be empty."
          exit 1
        end
      end

      def mupfile_contents
        @@options ? @@options[:mupfile_contents] : ''
      end

      def mupfile_path
        @@options ? @@options[:mupfile_path] : ''
      end

      def mupfile_default_path
        File.join(Dir.pwd, 'Mupfile')
      end

    end
    
    def initialize
      @tmp = {}
    end
    
    def tmp_block(merge_options = {})
      return unless block_given?
      preserve_tmp = @tmp
      @tmp = {} if @tmp.nil? && merge_options
      @tmp = @tmp.merge(merge_options) if @tmp.respond_to?(:merge)
      val = yield
      @tmp = preserve_tmp
      val
    end
      
    def list(name)
      tmp_block({ :type => :list, :paths => [] }) do
        yield if block_given?
        MangUpdate.add_list(name, @tmp[:paths])
      end
    end
    
    def path(path, options = {})
      raise "path must be called inside of a list block" unless @tmp[:type] == :list
      @tmp[:paths] << [path, options]
    end
    
    def job(name)
      # jobs are just for some extra groupping
      tmp_block({ :type => :job, :applies => [] }) do
        yield if block_given?
        MangUpdate.add_job(name, @tmp[:applies])
      end
    end
    
    def filtered(options = { :clear => false })
      raise "filtered must be called inside of a job block" unless [:job, :filtered].member?(@tmp[:type])
      filters_new = []
      filters_new = @tmp[:filters] if @tmp[:filters] && !options[:clear]      
      tmp_block({ :type => :filtered, :filters => filters_new, :jobname => @tmp[:jobname] }) do
        yield if block_given?
      end
    end
    
    def filter(&block)
      raise "filter must be called inside of a filtered block" unless @tmp[:type] == :filtered
      @tmp[:filters] << block
    end
    
    def apply(options = {})
      raise "apply must be called inside of a job block" unless [:job, :filtered].member?(@tmp[:type])  
      @tmp[:applies] << [:list, options, @tmp[:filters] || []]
    end
    
    def config(*args)
      name = args.shift
      case args.size
      when 0
        @@configs[name.downcase.to_sym]
      when 1
        @@configs[name.downcase.to_sym] = args[0]
      else
        raise ArgumentError, "Wrong number of arguments!"
      end
    end
    
    def build_lists
      MangUpdate.build_lists
    end
    
    def upload_file(filename, database, rev = nil)
      raise "upload_file must be called inside of a job block" unless @tmp[:type] == :job
      @tmp[:applies] << [:file, filename, database, rev]
    end
    
    def upload_sql_string(sql, database, rev = nil)
      raise "upload_sql_string must be called inside of a job block" unless @tmp[:type] == :job
      @tmp[:applies] << [:inline, sql, database, rev]
    end
    
  end
end