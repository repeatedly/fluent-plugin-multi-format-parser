# Multi format parser plugin for Fluentd

Parse format mixed logs.

## Installation

Use RubyGems:

    fluent-gem install fluent-plugin-multi-format-parser

## Configuration

This plugin is a parser plugin. After installed, you can use `multi_format` in `format` supported plugins.
Use multiple `<pattern>` to specify multiple format.

    <source>
      @type udp
      tag logs.multi

      format multi_format
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
    </match>

`multi_format` tries pattern matching from top to bottom and returns parsed result when matched.

Available format patterns and parameters are depends on Fluentd parsers.
See [parser plugin document](http://docs.fluentd.org/v0.12/articles/parser-plugin-overview) for more details.

### For v0.14

This plugin handles `pattern` section manually, so v0.14's automatic parameter conversion doesn't work well.
If you want to use this plugin with v0.14, you need to use v0.14 parser syntax like below

    <filter app.**>
      @type parser
      key_name message
      <parse> # Use <parse> section for parser parameters
        @type multi_format
        <pattern>
          format json
        </pattern>
        <pattern>
          # In v0.14, format regexp and expression parameters are used for v0.12's old "format //" syntax.
          format regexp
          expression /...your regexp pattern.../
        </pattern>
        <pattern>
          format none
        </pattern>
      </parse>
    </filter>

### NOTE

This plugin doesn't work with `multiline` parsers because parser itself doesn't store previous lines.

## Copyright

<table>
  <tr>
    <td>Author</td><td>Masahiro Nakagawa <repeatedly@gmail.com></td>
  </tr>
  <tr>
    <td>Copyright</td><td>Copyright (c) 2014- Masahiro Nakagawa</td>
  </tr>
  <tr>
    <td>License</td><td>MIT License</td>
  </tr>
</table>
