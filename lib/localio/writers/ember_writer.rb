require 'localio/template_handler'
require 'localio/segments_list_holder'
require 'localio/segment'
require 'localio/formatter'

class EmberWriter
  TEMPLATE = 'ember_localizable.erb'

  def self.write(languages, terms, path, formatter, options)
    puts 'Writing ember translations...'

    languages.keys.each do |language|
      output_path = "#{path}/#{language}"
      output_name = "translations.js"

      segments = SegmentsListHolder.new(language)
      terms.each do |term|
        next if term.values[language].nil?
        key = Formatter.format(term.keyword, formatter, method(:javascript_key_formatter))
        translation = javascript_parsing(term.values[language])
        segment = Segment.new(key, translation, language)
        segment.key = nil if term.is_comment?
        segments.segments << segment
      end

      # Create a nested hash of the segments (key, translation pairs).
      segments.create_nested_hash

      TemplateHandler.process_template(TEMPLATE, output_path, output_name, segments)
      puts " > #{language.yellow}"
    end
  end

  def self.javascript_parsing(term)
    term.gsub(/<s\$(\d)>/, '{\1}').
         gsub(/<d\$(\d)>/, '{\1}').
         gsub('""', '\"')
  end

  private

  def self.javascript_key_formatter(key)
    key.space_to_underscore.strip_tag.downcase
  end


end
