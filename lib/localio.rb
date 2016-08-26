require 'localio/version'
require 'localio/locfile'
require 'localio/processor'
require 'localio/localizable_writer'
require 'localio/filter'
require 'active_support/inflector'
require 'localio/processors/csv_processor'
Dir["localio/processors/*"].each {|file| require file }

module Localio

  def self.from_cmdline(args)
    if ARGV.empty?
      if File.exist? 'Locfile'
        process_locfile('Locfile')
      else
        raise ArgumentError, 'Locfile not found in current directory, and no compatible file supplied in arguments.'
      end
    else
      process_locfile(ARGV.shift)
    end
  end

  def self.from_configuration(configuration)
    @configuration = configuration
    generate_localizables
  end

  private

  def self.process_locfile(path)
    @configuration = Locfile.load(path)
    generate_localizables
  end

  def self.generate_localizables
    process_to_memory
    apply_filters
    build_localizables
  end

  def self.process_to_memory
    @localizables = processor.load_localizables(
                                                @configuration.platform_options,
                                                @configuration.source_options,
                                                @configuration.languages
                                               )
  end

  def self.processor
    if [:xlsx, :xls, :google_drive, :csv].include? @configuration.source_service
      "#{@configuration.source_service.to_s.classify}Processor".constantize
    else
      raise ArgumentError, 'Unsupported service! Try with :google_drive, :csv, :xlsx or :xls in the source argument'
    end
  end

  def self.apply_filters
    @localizables[:segments] = Filter.apply_filter @localizables[:segments],
                                                   @configuration.only,
                                                   @configuration.except
  end

  def self.build_localizables
    @configuration.platform_options[:default_language] = @localizables[:default_language]
    LocalizableWriter.write @configuration.platform_name,
                            @localizables[:languages],
                            @localizables[:segments],
                            @configuration.output_path,
                            @configuration.output_name,
                            @configuration.formatting,
                            @configuration.platform_options
    puts 'Done!'.green
  end

end
