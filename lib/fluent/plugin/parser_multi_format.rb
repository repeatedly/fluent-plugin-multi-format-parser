require 'fluent/plugin/parser'

module Fluent
  module Plugin
    class MultiFormatParser < Parser
      Plugin.register_parser('multi_format', self)
      config_param :format_key, :string, default: nil

      def initialize
        super

        @parsers = []
        @parser_format_names = []
      end

      def configure(conf)
        super

        conf.elements.each_with_index { |e, i|
          next unless ['pattern', 'format'].include?(e.name)
          next if e['format'].nil? && (e['@type'] == 'multi_format')
          @parser_format_names << e.delete('format_name') || ""+e['format']+"#"+i.to_s
          parser = Plugin.new_parser(e['format'])
          parser.configure(e)
          @parsers << parser
        }
      end

      def parse(text)
        @parsers.each_with_index { |parser, i|
          begin
            parser.parse(text) { |time, record|
              if time && record
                if @format_key
                  record[@format_key] = @parser_format_names[i]
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
