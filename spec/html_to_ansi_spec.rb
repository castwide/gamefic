require 'gamefic/html_to_ansi'

describe HtmlToAnsi do
  before :all do
    @obj = Object.new
    @obj.extend HtmlToAnsi
  end

  it "trims extra whitespace" do
    text = %(
      plain text
    )
    ansi = @obj.html_to_ansi(text)
    expect(ansi.gsub(/\e\[([;\d]+)?m/, '')).to eq("plain text\n\n")
  end

  it "adds line breaks for paragraphs" do
    html = %(
      <p>paragraph one</p>
      <p>paragraph two</p>
    )
    ansi = @obj.html_to_ansi(html)
    expect(ansi.gsub(/\e\[([;\d]+)?m/, '')).to eq("paragraph one\n\nparagraph two\n\n")
  end

  it "collapses html whitespace" do
    html = %(
      <p>1234    6789</p>
    )
    ansi = @obj.html_to_ansi(html)
    expect(ansi.gsub(/\e\[([;\d]+)?m/, '')).to eq("1234 6789\n\n")
  end

  it "wraps text" do
    html = %(
      <p><b>123456789</b> 123456789</p>
    )
    ansi = @obj.html_to_ansi(html, width: 10)
    expect(ansi.gsub(/\e\[([;\d]+)?m/, '')).to eq("123456789\n123456789\n\n")
  end
end
