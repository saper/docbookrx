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
      it "has an abstract" do
        assert info.at_xpath("abstract")
      end
      it "has para in abstract" do
        simpara = info.at_xpath("abstract/simpara")
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
      chapters = part.xpath("chapter")
      it "has a title" do
        assert title
      end
      it "has a title 'Book One'" do
        assert_equal 'Book One', title.text
      end
      it "has two chapters" do
        assert_equal 2, chapters.size
      end
    end
    #
    # chapter one
    #
    describe "chapter one" do
      chapters = xml.xpath("/book/part/chapter")
      chapter = chapters.first
      title = chapter.at_xpath("title")
      info = chapter.at_xpath("info")
      abstract = info.at_xpath("abstract")
      section = chapter.at_xpath("section")
      it "has a title" do
        assert title
      end
      it "has a non-empty title" do
        refute_empty title.text
      end
      it "has info" do
        assert info
      end
      it "info has an abstract" do
        assert abstract
      end
      it "s title abstract reads" do
        assert_equal 'Test abstract', abstract.text.strip
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
    #
    # chapter two
    #
    describe "chapter two" do
      chapters = xml.xpath("/book/part/chapter")
      chapter = chapters[1]
      it "has a second chapter" do
        assert chapter
      end
      it "has a title of 'Part One'" do
        title = chapter.at_xpath("title")
        assert_equal 'Part One', title.text
      end
    end
  end
end
