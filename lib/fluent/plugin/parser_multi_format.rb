require 'fluent/plugin/parser'

SubParser = Struct.new(:parser, :index, :name)
FORMAT_NAME = "format_name"

module Fluent
  module Plugin
    class MultiFormatParser < Parser
      Plugin.register_parser('multi_format', self)
      config_param :format_key, :string, default: ''
      config_param :index_key, :string, default: ''

      def initialize
        super

        @parsers = []
        @format_key = ''
        @index_key = ''
      end

      def configure(conf)
        super

        conf.elements.each_with_index { |e, i|
          next unless ['pattern', 'format'].include?(e.name)
          next if e['format'].nil? && (e['@type'] == 'multi_format')
          parser = SubParser.new
          format_name = e.delete(FORMAT_NAME) || ""+e['format']+"#"+i.to_s
          parser.parser = Plugin.new_parser(e['format'])
          parser.index = i
          parser.name = format_name
          parser.parser.configure(e)
          @parsers << parser
        }
      end

      def parse(text)
        @parsers.each { |subparser|
          begin
            subparser.parser.parse(text) { |time, record|
              if time && record
                if ! (@format_key.nil? || @format_key.empty?)
                  record[@format_key] = subparser.name
                end
                if ! (@index_key.nil? || @index_key.empty?)
                  record[@index_key] = subparser.index
                end
                yield time, record
                return
              end
            }
          rescue # ignore parser error
          end
        }

        yield nil, nil
      end
    end
  end
end
