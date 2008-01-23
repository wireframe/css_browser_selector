$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'action_view/helpers/no_more_browser_hacks'
ActionView::Base.send(:include, ActionView::Helpers::NoMoreBrowserHacks)
