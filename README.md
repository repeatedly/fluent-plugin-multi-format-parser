# Multi format parser plugin for Fluentd

Parse format mixed logs.

## Installation

Use RubyGems:

    fluent-gem install fluent-plugin-multi-format-parser

## Configuration

This plugin is a parser plugin. After installed, you can use `multi_format` in `format` supported plugins.
Use multiple `<pattern>` to specify multiple format.

    <source>
      type udp
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
See [in_tail format document](http://docs.fluentd.org/articles/in_tail) for more details.

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
