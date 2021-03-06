require 'localio/template_handler'
require 'localio/segments_list_holder'
require 'localio/segment'
require 'localio/formatter'

class RailsWriter
  def self.write(languages, terms, path, formatter, options)
    puts 'Writing Rails YAML translations...'

    languages.keys.each do |lang|
      output_path = path

      # We have now to iterate all the terms for the current language, extract them, and store them into a new array

      segments = SegmentsListHolder.new lang
      terms.each do |term|
        next if term.values[lang].nil?
        key = Formatter.format(term.keyword, formatter, method(:rails_key_formatter))
        translation = term.values[lang]
        segment = Segment.new(key, translation, lang)
        segment.key = nil if term.is_comment?
        segments.segments << segment
      end

      segments.create_nested_hash

      TemplateHandler.process_template 'rails_localizable.erb', output_path, "#{lang}.yml", segments
      puts " > #{lang.yellow}"
    end
  end

  private

  def self.rails_key_formatter(key)
    key.space_to_underscore.strip_tag.downcase
  end
end