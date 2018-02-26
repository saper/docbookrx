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

  xml = @@xml # syntactic sugar
  xml.remove_namespaces! # xpath would be /xmlns:book/xmlns:... otherwise
  root = xml.root

  describe "SUSE XML tags" do
    #
    # overall format
    #
    describe "docbook xml" do
      it "is readable" do
        assert File.readable? @@asciidoctor_xml
      end
      it "is XML" do
        assert_equal ::Nokogiri::XML::Document, xml.class 
      end
      it "is a <book>" do
        root.name.must_equal "book"
      end
    end

    #
    # internal structure
    #
    describe "internal structure" do
      it "has a <info> section" do
        assert xml.at_xpath('/book/info')
      end
      it "has a <preface> section" do
        assert xml.at_xpath('/book/preface')
      end
      it "has a <part> section" do
        assert xml.at_xpath('/book/part')
      end
    end

    #
    # info section
    #
    describe "info section" do
      info = xml.at_xpath("/book/info")
      title = info.at_xpath("title")
      it "has a title" do
        assert title
      end
      it "has a title 'A Set of Books'" do
        assert_equal 'A Set of Books', title.text
      end
      it "has a date" do
        assert info.at_xpath("date")
      end
      it "has 3 authors" do
        authorgroup = info.at_xpath("authorgroup")
        assert_equal 3, authorgroup.elements.size
#        assert_equal "Sally Penguin; Tux Penguin; Wilber Penguin", simpara.text
      end
    end
    #
    # preface section
    # asciidoctor converts info > abstract into preface > abstract
    #
    describe "preface section" do
      it "has an abstract" do
        assert xml.at_xpath("/book/preface/abstract")
      end
      it "has simpara in abstract" do
        simpara = xml.at_xpath("/book/preface/abstract/simpara")
        assert simpara
        assert_equal "This is a test document for DocbookRX/SUSErx it contains all tags used by SUSE for checking output.", simpara.text
      end
    end
    #
    # part section
    #
    describe "part section" do
      part = xml.at_xpath("/book/part")
      title = part.at_xpath("title")
      chapter = part.at_xpath("chapter")
      it "has a title" do
        assert title
      end
      it "has a title 'Book One'" do
        assert_equal 'Book One', title.text
      end
      it "has a chapter" do
        assert chapter
      end
    end
    #
    # chapter one
    #
    describe "chapter one" do
      chapter = xml.at_xpath("/book/part/chapter")
      title = chapter.at_xpath("title")
      abstract = chapter.at_xpath("abstract/simpara")
      section = chapter.at_xpath("section")
      it "has a title" do
        assert title
      end
      it "has a non-empty title" do
        refute_empty title.text
      end
      it "has an abstract" do
        assert abstract
      end
      it "s title abstract reads" do
        assert_equal 'Test abstract', abstract.text
      end
      it "has a simpara" do
        simpara = chapter.at_xpath("simpara")
        assert simpara
        assert_match /^Standing atop NASA/, simpara.text
      end
      it "simpara has an embedded link" do
        link = chapter.at_xpath("simpara/link")
        assert link
        assert_equal "Launch Pad 39A", link.text
        href = link.attribute("href")
        assert href
        assert_equal 'https://www.space.com/25509-spacex-historic-nasa-apollo-launch-pad.html', href.text
      end
      it "has a section" do
        assert section
      end
    end
    describe "chapter one sections" do
      section1 = xml.at_xpath("/book/part/chapter/section")
      simpara = section1.at_xpath("simpara")
      it "has a section with a proper id" do
        assert section1
        id = section1.attribute('id')
        assert id
        assert_equal '_chapt.one.b1.sect1', id.text
      end
      it "has a title" do
        title = section1.at_xpath("title")
        assert title
        assert_equal 'Section One', title.text
      end
      it "has a paragraph" do
        assert simpara
        assert_match /^Standing atop NASA/, simpara.text
      end
      it "simpara has an embedded link" do
        link = simpara.at_xpath("link")
        assert link
        assert_equal "Launch Pad 39A", link.text
        href = link.attribute("href")
        assert href
        assert_equal 'https://www.space.com/25509-spacex-historic-nasa-apollo-launch-pad.html', href.text
      end
      it "is has an odered list" do
        assert section1.at_xpath("orderedlist")
      end
    end
    describe "chapter one section ordered list" do
      ol = xml.at_xpath("/book/part/chapter/section/orderedlist")
    end
  end
end
