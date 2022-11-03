require 'fluent/config'
require 'fluent/test'
require 'fluent/test/driver/parser'
require 'fluent/plugin/parser'
require 'fluent/plugin/parser_multi_format'
require 'test/unit'

class MultiFormatParserTest < ::Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf)
    conf = Fluent::Config.parse(conf, "(test)", "(test_dir)", true)
    Fluent::Test::Driver::Parser.new(Fluent::Plugin::MultiFormatParser.new).configure(conf)
  end

  def test_configure
    conf = %[
      @type multi_format
      <pattern>
        format apache
      </pattern>
      <pattern>
        format json
        time_key timestamp
      </pattern>
      <pattern>
        format none
      </pattern>
    ]
    d = create_driver(conf)
    parsers = d.instance.instance_variable_get(:@parsers)
    assert_instance_of(Fluent::Plugin::ApacheParser, parsers[0])
    assert_instance_of(Fluent::Plugin::JSONParser, parsers[1])
    assert_instance_of(Fluent::Plugin::NoneParser, parsers[2])
  end

  def test_parse
    conf = %[
      @type multi_format
      <pattern>
        format apache
      </pattern>
      <pattern>
        format json
        time_key timestamp
      </pattern>
      <pattern>
        format none
      </pattern>
    ]
    d = create_driver(conf)
    d.instance.parse('{"k":"v"}') { |t, r|
      assert_equal({"k" => "v"}, r)
    }
    d.instance.parse('hello') { |t, r|
      assert_equal({"message" => "hello"}, r)
    }
  end
end
