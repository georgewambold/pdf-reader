# coding: utf-8

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')

require 'pdf/reader'

context "The PDF::Reader::Encoding class" do

  specify "should return a new encoding object on request, or raise an error if unrecognised" do
    PDF::Reader::Encoding.factory("Identity-H").should be_a_kind_of(PDF::Reader::Encoding::IdentityH)
    PDF::Reader::Encoding.factory("MacRomanEncoding").should be_a_kind_of(PDF::Reader::Encoding::MacRomanEncoding)
    PDF::Reader::Encoding.factory("MacExpertEncoding").should be_a_kind_of(PDF::Reader::Encoding::MacExpertEncoding)
    PDF::Reader::Encoding.factory("StandardEncoding").should be_a_kind_of(PDF::Reader::Encoding::StandardEncoding)
    PDF::Reader::Encoding.factory("SymbolEncoding").should be_a_kind_of(PDF::Reader::Encoding::SymbolEncoding)
    PDF::Reader::Encoding.factory("WinAnsiEncoding").should be_a_kind_of(PDF::Reader::Encoding::WinAnsiEncoding)
    PDF::Reader::Encoding.factory("ZapfDingbatsEncoding").should be_a_kind_of(PDF::Reader::Encoding::ZapfDingbatsEncoding)
    lambda { PDF::Reader::Encoding.factory("FakeEncoding")}.should raise_error(PDF::Reader::UnsupportedFeatureError)
    PDF::Reader::Encoding.factory(nil).should be_nil
  end

  specify "should raise an exception if to_utf8 is called" do
    e = PDF::Reader::Encoding.new
    lambda { e.to_utf8("test")}.should raise_error(RuntimeError)
  end
end

context "The PDF::Reader::Encoding::IdentityH class" do

  specify "should raise an exception if to_utf8 is called without a cmap" do
    e = PDF::Reader::Encoding::IdentityH.new
    lambda { e.to_utf8("test")}.should raise_error(ArgumentError)
  end

  specify "should convert an IdentityH encoded string into UTF-8" do
    e = PDF::Reader::Encoding::IdentityH.new
    cmap = PDF::Reader::CMap.new("")
    cmap.instance_variable_set("@map",{1 => 0x20AC, 2 => 0x0031})
    result = e.to_utf8("\x00\x01\x00\x02", cmap)
    
    result.should eql("€1")

    if RUBY_VERSION >= "1.9"
      result.encoding.to_s.should eql("UTF-8")
    end
  end

end

context "The PDF::Reader::Encoding::MacExpertEncoding class" do

  specify "should correctly convert various expert strings to utf-8" do
    e = PDF::Reader::Encoding::MacExpertEncoding.new
    [
      {:expert => "\x22", :utf8 => [0xF6F8].pack("U*")},
      {:expert => "\x62", :utf8 => [0xF762].pack("U*")},
      {:expert => "\xBE", :utf8 => [0xF7E6].pack("U*")},
      {:expert => "\xF7", :utf8 => [0xF6EF].pack("U*")}
    ].each do |vals| 
      result = e.to_utf8(vals[:expert])

      if RUBY_VERSION >= "1.9"
        result.encoding.to_s.should eql("UTF-8")
        vals[:utf8].force_encoding("UTF-8")
      end

      result.should eql(vals[:utf8]) 
    end
  end
end

context "The PDF::Reader::Encoding::MacRomanEncoding class" do

  specify "should correctly convert various mac roman strings to utf-8" do
    e = PDF::Reader::Encoding::MacRomanEncoding.new
    [
      {:mac => "abc", :utf8 => "abc"},
      {:mac => "ABC", :utf8 => "ABC"},
      {:mac => "123", :utf8 => "123"},
      {:mac => "\x24", :utf8 => "\x24"},         # dollar sign
      {:mac => "\xDB", :utf8 => "\xE2\x82\xAC"}, # € sign
      {:mac => "\xD8", :utf8 => "\xC3\xBF"},     # ÿ sign
      {:mac => "\xE4", :utf8 => "\xE2\x80\xB0"}, # ‰  sign
      {:mac => "\xFD", :utf8 => "\xCB\x9D"}      # ˝ sign
    ].each do |vals| 
      result = e.to_utf8(vals[:mac])
      result.should eql(vals[:utf8]) 
      
      if RUBY_VERSION >= "1.9"
        result.encoding.to_s.should eql("UTF-8")
      end
    end
  end
end

context "The PDF::Reader::Encoding::StandardEncoding class" do

  specify "should correctly convert various standard strings to utf-8" do
    e = PDF::Reader::Encoding::StandardEncoding.new
    [
      {:standard => "abc",  :utf8 => "abc"},
      {:standard => "ABC",  :utf8 => "ABC"},
      {:standard => "123",  :utf8 => "123"},
      {:standard => "\x60", :utf8 => [0x2018].pack("U*")}, # "
      {:standard => "\xA4", :utf8 => [0x2044].pack("U*")}, # fraction sign
      {:standard => "\xBD", :utf8 => [0x2030].pack("U*")}, # per mile sign
      {:standard => "\xFA", :utf8 => [0x0153].pack("U*")}
    ].each do |vals| 
      result = e.to_utf8(vals[:standard])

      if RUBY_VERSION >= "1.9"
        result.encoding.to_s.should eql("UTF-8")
        vals[:utf8].force_encoding("UTF-8")
      end

      result.should eql(vals[:utf8]) 
      
    end
  end
end

context "The PDF::Reader::Encoding::SymbolEncoding class" do

  specify "should correctly convert various symbol strings to utf-8" do
    e = PDF::Reader::Encoding::SymbolEncoding.new
    [
      {:symbol => "\x41", :utf8 => [0x0391].pack("U*")}, # alpha
      {:symbol => "\x42", :utf8 => [0x0392].pack("U*")}, # beta
      {:symbol => "\x47", :utf8 => [0x0393].pack("U*")}, # gamma
      {:symbol => "123",  :utf8 => "123"},
      {:symbol => "\xA0", :utf8 => [0x20AC].pack("U*")}, # € sign
    ].each do |vals| 
      result = e.to_utf8(vals[:symbol])

      if RUBY_VERSION >= "1.9"
        result.encoding.to_s.should eql("UTF-8")
        vals[:utf8].force_encoding("UTF-8")
      end

      result.should eql(vals[:utf8]) 
      
    end
  end
end

context "The PDF::Reader::Encoding::WinAnsiEncoding class" do

  specify "should correctly convert various win-1252 strings to utf-8" do
    e = PDF::Reader::Encoding::WinAnsiEncoding.new
    [
      {:win => "abc", :utf8 => "abc"},
      {:win => "ABC", :utf8 => "ABC"},
      {:win => "123", :utf8 => "123"},
      {:win => "\x24", :utf8 => "\x24"},         # dollar sign
      {:win => "\x80", :utf8 => "\xE2\x82\xAC"}, # € sign
      {:win => "\x82", :utf8 => "\xE2\x80\x9A"}, # ‚ sign
      {:win => "\x83", :utf8 => "\xC6\x92"},     # ƒ sign
      {:win => "\x9F", :utf8 => "\xC5\xB8"}      # Ÿ sign
    ].each do |vals| 
      result = e.to_utf8(vals[:win])
      result.should eql(vals[:utf8]) 
      
      if RUBY_VERSION >= "1.9"
        result.encoding.to_s.should eql("UTF-8")
      end
    end
  end
end

context "The PDF::Reader::Encoding::ZapfDingbatsEncoding class" do

  specify "should correctly convert various dingbats strings to utf-8" do
    e = PDF::Reader::Encoding::ZapfDingbatsEncoding.new
    [
      {:dingbats => "\x22", :utf8 => [0x2702].pack("U*")}, # scissors
      {:dingbats => "\x25", :utf8 => [0x260E].pack("U*")}, # telephone
      {:dingbats => "\xAB", :utf8 => [0x2660].pack("U*")}, # spades
      {:dingbats => "\xDE", :utf8 => [0x279E].pack("U*")}, # ->
    ].each do |vals| 
      result = e.to_utf8(vals[:dingbats])

      if RUBY_VERSION >= "1.9"
        result.encoding.to_s.should eql("UTF-8")
        vals[:utf8].force_encoding("UTF-8")
      end

      result.should eql(vals[:utf8]) 
      
    end
  end
end
