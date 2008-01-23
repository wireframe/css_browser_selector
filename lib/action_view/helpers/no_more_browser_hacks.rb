require 'action_view/helpers/tag_helper'
require 'action_view/helpers/text_helper'
require 'action_view/helpers/capture_helper'

module ActionView
  module Helpers
    module NoMoreBrowserHacks
      include TagHelper
      include TextHelper
      include CaptureHelper

      # Javascript version of the CSS Browser Selector, can be put inline into the page / layout
      # by <%= javascript_tag css_browser_selector %>
      def css_browser_selector
        # CSS Browser Selector   v0.2.5
        # Documentation:         http://rafael.adm.br/css_browser_selector
        # License:               http://creativecommons.org/licenses/by/2.5/
        # Author:                Rafael Lima (http://rafael.adm.br)
        # Contributors:          http://rafael.adm.br/css_browser_selector#contributors
        %(var css_browser_selector = function() {
          	var 
          		ua=navigator.userAgent.toLowerCase(),
          		is=function(t){ return ua.indexOf(t) != -1; },
          		h=document.getElementsByTagName('html')[0],
          		b=(!(/opera|webtv/i.test(ua))&&/msie (\d)/.test(ua))?('ie ie'+RegExp.$1):is('gecko/')? 'gecko':is('opera/9')?'opera opera9':/opera (\d)/.test(ua)?'opera opera'+RegExp.$1:is('konqueror')?'konqueror':is('applewebkit/')?'webkit safari':is('mozilla/')?'gecko':'',
          		os=(is('x11')||is('linux'))?' linux':is('mac')?' mac':is('win')?' win':'';
          	var c=b+os+' js';
          	h.className += h.className?' '+c:c;
          }();)
      end
      
      # Inline javascript to creates an addLoadEvent method on Window to allow onload functions to 
      # be chained together without clobbering any prior onloads that may have been attached. This
      # can be added inline, standalone like so:
      #   <%= javascript_tag window_add_load_event %>
      def window_add_load_event
        %(Window.addLoadEvent = function(f){var oldf=window.onload; window.onload=(typeof window.onload!='function')?f:function(){oldf();f();}})
      end

      # Combines the window_add_load_event and window_add_js_to_tag methods to be run within one
      # script element:
      #   <%= javascript_tag window_on_load_add_js_to_tag(:body) %>
      def window_on_load_add_js_to_tag(tagname)
        "#{window_add_load_event}\n#{window_add_js_to_tag(tagname)}"
      end
      
      # Creates the html content element with css_browser_selectors added to its class attribute.
      # Includes by default the following attributes (which can be overridden):
      #   <html xmlns="http://www.w3.org/1999/xhtml" xml:lang=>"en" lang=>"en">
      def html(html_options = {}, &block)
        html_options.reverse_merge!(:xmlns=>"http://www.w3.org/1999/xhtml", :"xml:lang"=>"en", :lang=>"en")
        add_css_browser_selectors_to_tag(:html, html_options, &block)
      end

      # Creates the body content element with css_browser_selectors added to its class attribute.
      def body(html_options = {}, &block)
        add_css_browser_selectors_to_tag(:body, html_options, &block)
      end

      # # arguments: name, content options, escape = true
      # # will dry up once I get working
      # def content_tag_string_with_css_browser_selector(*args)
      #   if args[0] == :html or args[0] == :body
      #     html_options = args[2]||{}
      #     exclude_browser_and_os = html_options.delete(:exclude_browser_and_os)
      #     unless exclude_browser_and_os or (bros = determine_browser_and_os).empty?
      #       html_options[:class] = html_options[:class] ? "#{html_options[:class]} #{bros}" : bros 
      #     end
      #     args[2] = html_options if html_options
      #   end
      #   content_tag_string_without_css_browser_selector(*args)        
      # end
      # alias_method_chain :content_tag_string, :css_browser_selector
      
      private
      # Inline javascript to add the 'js' class to the supplied tag.  Adds the 'js' css_browser_selector
      # class, which must rely on javascript to be enabled to run.  Relies on
      # +Window.addLoadEvent+ method to be added (with the window_add_load_event method)
      #   <%= javascript_tag window_add_js_to_tag(:body)
      def window_add_js_to_tag(tagname)
        %(Window.addLoadEvent(function(){e=document.getElementsByTagName('#{tagname}')[0];e.className+=e.className?' js':'js'}))
      end

      # Underlying content builder for both the +html+ and +body+ functions
      def add_css_browser_selectors_to_tag(tag, html_options = {}, &block)
        html_options ||= {}
        exclude_browser_and_os = html_options.delete(:exclude_browser_and_os)
        unless exclude_browser_and_os or (bros = determine_browser_and_os).empty?
          html_options[:class] = html_options[:class] ? "#{html_options[:class]} #{bros}" : bros 
        end
        content = content_tag tag, (capture(&block) if block_given?), html_options
        concat(content, block.binding)
      end
      
      # The ruby version of the CSS Browser Selector with some additions
      def determine_browser_and_os(ua = request.env["HTTP_USER_AGENT"])
        ua = (ua||"").downcase
        br = (!(/opera|webtv/i=~ua)&&/msie (\d)/=~ua) ?      
             "ie ie"+Regexp.last_match(1) :                  # ie
             ua.include?("gecko/") ? "gecko" :               # ns
             ua.include?("opera/9") ? "opera opera9" :       # opera 9 only
             /opera (\d)/=~ua || /opera\/(\d)/=~ua ? 
             "opera opera"+Regexp.last_match(1) :            # opera 
             ua.include?("konqueror") ? "konqueror" :        # konqueror
             /applewebkit\/(\d+)/=~ua ?           
             (build = Regexp.last_match(1).to_i) &&
             "webkit safari safari" +                        # safari
                (/version\/(\d+)/=~ua ? 
                Regexp.last_match(1) : 
                (build >= 400) ? "2" : "1") :                 # safari version
             ua.include?("mozilla/") ? "gecko" : nil         # ff
        os = ua.include?("mac") || ua.include?("darwin") ? ua.include?("iphone") ? "iphone mac" : ua.include?("ipod") ? "ipod mac" : "mac" :
             ua.include?("x11") || ua.include?("linux") ? "linux" : 
             ua.include?("win") ? "win" : nil
        "#{br}#{" " unless br.nil? or os.nil?}#{os}"
      end
      
    end
  end
end
