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
      it "has an id" do
        assert_equal "_book_one", part.attribute("id").text
      end
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
        assert title
        assert_equal 'Chapter One', title.text
      end
      it "has a subtitle" do
        subtitle = chapter.at_xpath("subtitle")
        assert subtitle
        assert_equal 'Chapter One Subtitle', subtitle.text
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
      section1 = xml.at_xpath("/book/part/chapter[1]/section")
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
      ol = xml.at_xpath("/book/part/chapter[1]/section/orderedlist")
      it "has a title" do
        title = ol.at_xpath("title")
        assert title
        assert_equal 'Procedure: Test Procedure', title.text
      end
      it "has three steps" do
        listitems = ol.xpath("listitem")
        assert listitems
        assert_equal 3, listitems.size
        assert_equal 'Do this first…​', listitems[0].at_xpath('simpara').text
        assert_equal 'Now do that…​', listitems[1].at_xpath('simpara').text
        assert_equal 'Then do this again…​', listitems[2].at_xpath('simpara').text
      end
    end
    describe "chapter one section informalfigure" do
      fig = xml.at_xpath("/book/part/chapter[1]/section/informalfigure")
      it "has a informalfigure" do
        assert fig
      end
      it "references airplainjokes.jpg" do
        id = fig.at_xpath("mediaobject/imageobject/imagedata")
        assert id
        fr = id.attribute("fileref")
        assert fr
        assert_equal 'airplanejokes.jpg', fr.text
      end
    end
    describe "chapter one section figure" do
      fig = xml.at_xpath("/book/part/chapter[1]/section/figure")
      it "has a figure" do
        assert fig
      end
      it "has an empty title" do
        title = fig.at_xpath("title")
        assert title
        assert title.text.empty?
      end
      it "references numbers.jpg" do
        id = fig.at_xpath("mediaobject/imageobject/imagedata")
        assert id
        fr = id.attribute("fileref")
        assert fr
        assert_equal 'numbers.jpg', fr.text
      end
    end
    describe "chapter one section simparas" do
      simparas = xml.xpath("/book/part/chapter[1]/section[1]/simpara")
      simpara1 = simparas[0]
      it "has many simparas" do
        assert simparas
        assert_equal 18, simparas.size
      end
      it "simpara1 has an embedded link" do
        link = simpara1.at_xpath("link")
        assert link
        assert_equal "Launch Pad 39A", link.text
        href = link.attribute("href")
        assert href
        assert_equal 'https://www.space.com/25509-spacex-historic-nasa-apollo-launch-pad.html', href.text
      end
    end
    describe "chapter one replaceables" do
      it "has two replacables" do
        replaceables = xml.xpath("/book/part/chapter/section/simpara[@id='replaceable']/replaceable")
        assert replaceables
        assert_equal 2, replaceables.size
      end
    end
    describe "chapter one tip" do
      tip = xml.at_xpath("/book/part/chapter/section/tip")
      it "exists" do
        assert tip
      end
      it "has a title" do
        title = tip.at_xpath("title")
        assert_equal "Tip", title.text
      end
      it "has content" do
        simpara = tip.at_xpath("simpara")
        assert simpara.text
        refute simpara.text.empty?
      end
    end
    describe "chapter one note" do
      note = xml.at_xpath("/book/part/chapter/section/note")
      it "exists" do
        assert note
      end
      it "has a title" do
        title = note.at_xpath("title")
        assert_equal "Note", title.text
      end
      it "has content" do
        simpara = note.at_xpath("simpara")
        assert simpara.text
        refute simpara.text.empty?
      end
    end
    describe "chapter one caution" do
      caution = xml.at_xpath("/book/part/chapter/section/caution")
      it "exists" do
        assert caution
      end
      it "has a title" do
        title = caution.at_xpath("title")
        assert_equal "Caution", title.text
      end
      it "has content" do
        simpara = caution.at_xpath("simpara")
        assert simpara.text
        refute simpara.text.empty?
      end
    end
    describe "chapter one important" do
      important = xml.at_xpath("/book/part/chapter/section/important")
      it "exists" do
        assert important
      end
      it "has a title" do
        title = important.at_xpath("title")
        assert_equal "Important", title.text
      end
      it "has content" do
        simpara = important.at_xpath("simpara")
        assert simpara.text
        refute simpara.text.empty?
      end
    end
    describe "chapter one warning" do
      warning = xml.at_xpath("/book/part/chapter/section/warning")
      it "exists" do
        assert warning
      end
      it "has a title" do
        title = warning.at_xpath("title")
        assert_equal "Warning", title.text
      end
      it "has content" do
        simpara = warning.at_xpath("simpara")
        assert simpara.text
        refute simpara.text.empty?
      end
    end
    describe "chapter one bridgehead" do
      bridgehead = xml.at_xpath("/book/part/chapter/section/bridgehead")
      it "exists" do
        assert bridgehead
      end
      it "renders as sect3" do
        assert_equal "sect3", bridgehead.attribute("renderas").text
      end
      it "starts with Bridgehead" do
        assert bridgehead.text.start_with? "Bridgehead"
      end
    end
    describe "chapter one variablelist" do
      vl = xml.at_xpath("/book/part/chapter/section/variablelist")
      entries = vl.xpath("varlistentry")
      it "exists" do
        assert vl
      end
      it "has two varlistentries" do
        assert_equal 2, entries.size
      end
      it "has a term and a listitem" do
        entries.each do |e|
          assert e.at_xpath("term")
          assert e.at_xpath("listitem")
        end
      end
    end
    describe "chapter one itemizedlist" do
      il = xml.at_xpath("/book/part/chapter/section/itemizedlist")
      entries = il.xpath("listitem")
      it "exists" do
        assert il
      end
      it "has two listitems" do
        assert_equal 2, entries.size
      end
    end
    describe "chapter one orderedlist" do
      # get the second one. The first is the <procedure>
      ol = xml.at_xpath("/book/part/chapter/section/orderedlist[2]")
      entries = ol.xpath("listitem")
      it "exists" do
        assert ol
      end
      it "has two listitems" do
        assert_equal 2, entries.size
      end
    end
    describe "chapter one keycap" do
      keycap = xml.at_xpath("/book/part/chapter/section/simpara/keycap")
      it "exists" do
        assert keycap
      end
      it "says F1" do
        assert_equal "F1", keycap.text
      end
    end
    describe "chapter one keycombos" do
      keycombos = xml.xpath("/book/part/chapter/section/simpara/keycombo")
      it "exists" do
        assert keycombos
        assert_equal 2, keycombos.size
        assert_equal 2, keycombos[0].elements.size
        assert_equal 3, keycombos[1].elements.size
      end
    end
    describe "chapter one keycode" do
      keycode = xml.at_xpath("/book/part/chapter/section/simpara/keycode")
      it "exists" do
        assert keycode
        assert_equal "0x3B", keycode.text
      end
    end
    describe "chapter one literal filename" do
      filename = xml.at_xpath("/book/part/chapter/section/simpara/literal[@role='path']")
      it "exists" do
        assert filename
      end
    end
    describe "chapter one literal" do
      literal = xml.at_xpath("/book/part/chapter/section/simpara[@id='literal']/literal")
      it "exists" do
        assert literal
      end
    end
    describe "chapter one link" do
      link = xml.at_xpath("/book/part/chapter/section/simpara[@id='link']/link")
      it "exists" do
        assert link
      end
      it "has a linkend attribute" do
        linkend = link.attribute('linkend')
        assert linkend
        assert_equal '_nextsect', linkend.text
      end
    end
    describe "chapter one xref" do
      xref = xml.at_xpath("/book/part/chapter/section/simpara[@id='xref']/xref")
      it "exists" do
        assert xref
      end
      it "has a linkend attribute" do
        linkend = xref.attribute('linkend')
        assert linkend
        assert_equal '_chapt.one.b1.sect2', linkend.text
      end
    end
    describe "chapter one qandaset" do
      qandaset = xml.at_xpath("/book/part/chapter/section/qandaset")
      entries = qandaset.xpath("qandaentry")
      it "exists" do
        assert qandaset
      end
      it "has two entries" do
        assert_equal 2, entries.size
      end
      it "has entries with question and answer" do
        entries.each do |entry|
          assert entry.at_xpath("question")
          assert entry.at_xpath("answer")
        end
      end
    end
    describe "chapter one calloutlist" do
      screen = xml.at_xpath("/book/part/chapter/section/screen")
      col = xml.at_xpath("/book/part/chapter/section/calloutlist")
      it "exists" do
        assert screen
        assert col
      end
      it "has two entries" do
        refs = screen.xpath("co")
        anchors = col.xpath("callout")
        assert_equal 2, refs.size
        assert_equal 2, anchors.size
        rvalues = []
        refs.each do |ref|
          attr = ref.attribute("id")
          assert attr
          rvalues << attr.value
        end
        anchors.each do |anchor|
          attr = anchor.attribute("arearefs")
          assert attr
          rvalues.delete attr.value
        end
        # cross-references are fine
        assert_empty rvalues
      end
    end
    describe "chapter one ref" do
      ref = xml.at_xpath("/book/part/chapter/section/simpara/emphasis/phrase[@role='ref']")
      it "exists" do
        assert ref
      end
    end
    describe "chapter one email" do
      email = xml.at_xpath("/book/part/chapter/section/simpara[@id='email']/email")
      it "exists" do
        assert email
      end
      it "refers to example@example.com" do
        assert_equal 'example@example.com', email.text
      end
    end
    describe "chapter one command" do
      command = xml.at_xpath("/book/part/chapter/section/simpara[@id='command']/command")
      it "exists" do
        assert command
      end
      it "refers to 'ls -a'" do
        assert_equal 'ls -a', command.text
      end
    end
    describe "chapter one date" do
      date = xml.at_xpath("/book/part/chapter/section/simpara[@id='date']/date")
      it "exists" do
        assert date
      end
      it "refers to '09/16/1978'" do
        assert_equal '09/16/1978', date.text
      end
    end
    #
    # chapter two
    #
    describe "chapter two" do
      chapters = xml.xpath("/book/part/chapter")
      chapter = chapters[1]
      it "has a second chapter with the correct id" do
        assert chapter
        id = chapter.attribute("id")
        assert_equal "_part.one.book.i", id.text
      end
      it "has a title of 'Part One'" do
        title = chapter.at_xpath("title")
        assert_equal 'Part One', title.text
      end
    end
  end
end
