require 'nokogiri'
require_relative 'docbookrx/docbook_visitor'

module Docbookrx
  def self.convert(str, opts = {})
    xmldoc = ::Nokogiri::XML(str) do |config|
      config.default_xml.dtdload
    end
    raise 'Not a parseable document' unless (root = xmldoc.root)
    visitor = DocbookVisitor.new opts
    root.accept visitor
    visitor.after
    visitor.lines * "\n"
  end

  def self.convert_file infile, opts = {}
    outfile = if (ext = ::File.extname infile)
      %(#{infile[0...-ext.length]}.adoc)
    else
      %(#{infile}.adoc)
    end

    str = ::IO.read infile
    output = convert str, opts
    ::IO.write outfile, output
    nil
  end
end
