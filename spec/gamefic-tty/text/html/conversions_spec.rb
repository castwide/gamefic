require 'gamefic-tty/text'
# include Gamefic::Tty::Text

describe Gamefic::Tty::Text::Html::Conversions do
  it "trims extra whitespace" do
    text = %(
      plain           text
    )
    ansi = Gamefic::Tty::Text::Html::Conversions.html_to_ansi(text)
    expect(ansi.gsub(/\e\[([;\d]+)?m/, '')).to eq("plain text")
  end

  it "adds line breaks for paragraphs" do
    html = %(
      <p>paragraph one</p>

      <p>paragraph two</p>
    )
    text = Gamefic::Tty::Text::Html::Conversions.html_to_text(html)
    expect(text).to eq("\nparagraph one\n\nparagraph two\n\n")
  end

  it "collapses html whitespace" do
    html = %(
      <p>1234    6789</p>
    )
    text = Gamefic::Tty::Text::Html::Conversions.html_to_text(html)
    expect(text).to eq("\n1234 6789\n\n")
  end

  it "wraps text" do
    html = %(
      <p><b>123456789</b> 123456789</p>
    )
    ansi = Gamefic::Tty::Text::Html::Conversions.html_to_ansi(html, width: 10)
    expect(ansi.gsub(/\e\[([;\d]+)?m/, '')).to eq("\n123456789\n123456789\n\n")
  end

  # TODO: The ANSI tests are far from perfect. They check for the existence of
  # codes but do not validate the actual formatting, e.g., returning to normal
  # text after the end of a strong tag.

  it "adds bold formatting" do
    normal = Gamefic::Tty::Text::Ansi.graphics_mode Gamefic::Tty::Text::Ansi::Code::Attribute::NORMAL
    bold = Gamefic::Tty::Text::Ansi.graphics_mode Gamefic::Tty::Text::Ansi::Code::Attribute::NORMAL, Gamefic::Tty::Text::Ansi::Code::Attribute::BOLD
    %w(strong b em).each { |tag|
      html = "normal <#{tag}>bold</#{tag}>"
      ansi = Gamefic::Tty::Text::Html::Conversions.html_to_ansi html
      expect(ansi).to eq "#{normal}normal #{bold}bold#{normal}"
    }
  end

  it "underscores" do
    normal = Gamefic::Tty::Text::Ansi.graphics_mode Gamefic::Tty::Text::Ansi::Code::Attribute::NORMAL
    under = Gamefic::Tty::Text::Ansi.graphics_mode Gamefic::Tty::Text::Ansi::Code::Attribute::NORMAL, Gamefic::Tty::Text::Ansi::Code::Attribute::UNDERSCORE
    %w(u i).each { |tag|
      html = "normal <#{tag}>under</#{tag}>"
      ansi = Gamefic::Tty::Text::Html::Conversions.html_to_ansi html
      expect(ansi).to eq "#{normal}normal #{under}under#{normal}"
    }
  end

  it "formats ordered lists" do
    html = '<ol><li>Item</li></ol>'
    ansi = Gamefic::Tty::Text::Html::Conversions.html_to_ansi html
    expect(ansi).to include '1. Item'
  end

  it "formats unordered lists" do
    html = '<ul><li>Item</li></ul>'
    ansi = Gamefic::Tty::Text::Html::Conversions.html_to_ansi html
    expect(ansi).to include '* Item'
  end

  it "conserves whitespace in pre" do
    pre = "\n\n  nested\n\n    indenting"
    text = Gamefic::Tty::Text::Html::Conversions.html_to_text "<pre>#{pre}</pre>"
    expect(text).to eq pre
  end

  it "bolds and uppercases headers" do
    bold = Gamefic::Tty::Text::Ansi::Code::Attribute::BOLD.to_s
    %w(h1 h2 h3 h4 h5).each { |h|
      html = "<#{h}>header</#{h}>"
      ansi = Gamefic::Tty::Text::Html::Conversions.html_to_ansi html
      expect(ansi).to include bold
      expect(ansi).to include 'HEADER'
    }
  end

  it "includes hard line breaks" do
    html = "<p>line one<br/>line two</p>"
    text = Gamefic::Tty::Text::Html::Conversions.html_to_text html
    expect(text).to eq "\nline one\nline two\n\n"
  end

  it "conserves unescaped entities" do
    orig = "'one' & \"two\""
    text = Gamefic::Tty::Text::Html::Conversions.html_to_text "<p>#{orig}</p>"
    expect(text).to eq "\n#{orig}\n\n"
  end

  it "returns raw HTML for invalid markup" do
    html = "<p>one"
    text = Gamefic::Tty::Text::Html::Conversions.html_to_text html
    expect(text).to eq html
  end
end
