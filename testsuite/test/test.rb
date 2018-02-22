require 'nokogiri'
require 'minitest/autorun'

class SuseXmlTest < MiniTest::Spec
  def self.prepare 
    toplevel = File.dirname File.dirname __FILE__
    @@asciidoctor_xml = File.expand_path(File.join(toplevel,"asciidoctor", "xml", "MAIN-set.xml"))

    puts "Read #{@@asciidoctor_xml.inspect}"
    @@xml = ::Nokogiri::XML.parse(File.read(@@asciidoctor_xml))
  end
  prepare

  describe "SUSE XML tags" do
    describe "docbook xml" do
      it "is readable" do
        assert File.readable? @@asciidoctor_xml
      end
      it "is XML" do
        assert_equal ::Nokogiri::XML::Document, @@xml.class 
      end
      it "is a <book>" do
        @@xml.root.name.must_equal "book"
      end
    end
  end
end
