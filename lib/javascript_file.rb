module CssBrowserSelector
  module Javascript
    FILENAME = File.join(File.dirname(__FILE__), 'javascripts', 'css_browser_selector.js')
    
    def self.version
      @@version ||= raw_file.match(/CSS Browser Selector v(\d\.\d\.\d)/)[1]
    end
  
    def self.contents(show_comments = true)
      contents = raw_file.dup
      contents.gsub!(/\/\*.*\*\/\n/m, '') unless show_comments
      contents
    end
    
    private
    def self.raw_file
      @@raw_file ||= File.new(FILENAME).read
    end     
  end
end