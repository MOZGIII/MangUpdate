require 'thor'
require 'MangUpdate/version'

module MangUpdate

  class CLI < Thor

    default_task :update

    desc 'update', 'Runs the update'
    
    method_option :debug,
                  :type    => :boolean,
                  :default => false,
                  :aliases => '-d',
                  :banner  => 'Print debug messages'  
                  
    method_option :mupfile,
                  :type    => :string,
                  :aliases => '-M',
                  :banner  => 'Specify a Mupfile'
    
    method_option :dry_run,
                  :type    => :boolean,
                  :default => false,
                  :aliases => '-n',
                  :banner  => 'Do not upload SQL files'
                  
    method_option :list,
                  :type    => :boolean,
                  :default => false,
                  :aliases => '-l',
                  :banner  => 'Print SQL filenames'
                  
    method_option :nodump,
                  :type    => :boolean,
                  :default => false,
                  :banner  => 'Do not dump update info'
    
    def update
      ::MangUpdate.run(options)
    end


    desc 'version', 'Shows the MangUpdate version'
    
    map %w(-v --version) => :version
    
    def version
      ::MangUpdate::UI.info "MangUpdate version #{ MangUpdate::VERSION }"
    end

    
    desc 'init', 'Generates a Mupfile at the current working directory'
    
    method_option :mupfile,
              :type    => :string,
              :aliases => '-M',
              :banner  => 'Specify a Mupfile path'
    
    def init
      ::MangUpdate.initialize_template(options)
    end

  end
end