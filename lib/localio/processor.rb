class Processor
  attr_accessor :options, :platform_options, :allowed_languages, :path, :languages, :sheet_index

  def initialize(platform_options, options, allowed_languages)
    @platform_options = platform_options || {}
    @options = options
    @allowed_languages = allowed_languages
    @languages = Hash.new("languages")
    @path = options[:path]
    @sheet_index = options[:sheet_index] || 0
  end

end
