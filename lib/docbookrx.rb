require 'nokogiri'
require_relative 'docbookrx/docbook_visitor'

module Docbookrx
  def self.root
    nil
  end
  def self.read_xml(str, opts = {})
    begin
      ::Nokogiri::XML(str) do |config|
        if opts[:strict]
          config.strict.dtdload
        else
          config.default_xml.dtdload
        end
      end
    rescue Nokogiri::XML::SyntaxError => e
      filename = opts[:infile]
      if filename
        STDERR.puts "Failed to parse #{filename}: #{e}"
      else
        STDERR.puts e
      end
      self
    end
  end
  def self.convert(str, opts = {})
    xmldoc = nil
    Dir.chdir(opts[:cwd] || File.dirname(opts[:infile]||".")) do |path|
      xmldoc = self.read_xml(str, opts)
    end
    raise 'Not a parseable document' unless (root = xmldoc.root)
    visitor = DocbookVisitor.new opts
    xmldoc.accept visitor
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
    output = convert str, opts.merge({:infile => infile})
    ::IO.write outfile, output
    nil
  end
end
