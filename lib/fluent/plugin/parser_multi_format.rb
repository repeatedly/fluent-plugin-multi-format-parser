require 'fluent/parser'

module Fluent
  class TextParser
    class MultiFormatParser
      include Configurable

      def initialize
        super

        @parsers = []
      end

      def configure(conf)
        super

        conf.elements.each { |e|
          next unless ['pattern', 'format'].include?(e.name)

          parser = TextParser.new
          parser.configure(e)
          @parsers << parser.parser
        }
      end

      def call(text)
        @parsers.each { |parser|
          begin
            parser.call(text) { |time, record|
              if time && record
                if block_given?
                  yield time, record
                  return
                else
                  return time, record
                end
              end
            }
          rescue # ignore parser error
          end
        }

        if block_given?
          yield nil, nil
        else
          return nil, nil
        end
      end
    end

    register_template('multi_format', Proc.new { MultiFormatParser.new })
  end
end
