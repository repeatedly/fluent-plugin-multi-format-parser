require 'fluent/parser'

module Fluent
  class TextParser
    if defined?(::Fluent::Parser)
      class MultiFormatParser < Parser
        Plugin.register_parser('multi_format', self)

        def initialize
          super

          @parsers = []
        end

        def configure(conf)
          super

          conf.elements.each { |e|
            next unless ['pattern', 'format'].include?(e.name)
            next if e['format'].nil? && (e['@type'] == 'multi_format')

            parser = Plugin.new_parser(e['format'])
            parser.configure(e)
            @parsers << parser
          }
        end

        def parse(text)
          @parsers.each { |parser|
            begin
              parser.parse(text) { |time, record|
                if time && record
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
    else # support old API. Will be removed.
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

        def parse(text)
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

        def call(*a, &b)
          parse(*a, &b)
        end
      end

      register_template('multi_format', Proc.new { MultiFormatParser.new })
    end
  end
end
