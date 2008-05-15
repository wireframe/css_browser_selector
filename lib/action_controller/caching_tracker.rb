module ActionController #:nodoc:
  module CachingTracker
    # Tracks what is being cached. There are three types of Caching in Rails: Page, Action, Fragment.
    # Currently, only Page Caching is tracked but this could be extended to track Action and Fragment caching.
    def self.included(base) #:nodoc:
      base.class_eval { include TrackPages }
    end

    # Methods to track pages that are cached.  Adds the class variable +page_cached_actions+ to each 
    # controller that includes +CachingTracker+.  Inserts the tracking mechanism on the caches_page
    # method.    
    module TrackPages
      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
        base.class_eval do
          include InstanceMethods
          
          @@page_cached_actions = []
          cattr_accessor :page_cached_actions
          class << self
            alias_method_chain :caches_page, :tracking
          end
        end
      end
      
      module ClassMethods
        # Saves the collection of actions that are passed to +caches_page+ if +perform_caching+ is true.
        def caches_page_with_tracking(*actions)
          self.page_cached_actions = actions.map(&:to_s) if perform_caching
          caches_page_without_tracking(*actions)
        end
      end

      module InstanceMethods
        # Helper to determine if the controller action is currently being page cached (ie. passed to 
        # the +caches_page+ method).  This is based on the controller instance's +action_name+ but
        # you can optionally pass the string name of the action:
        #   controller.page_cached?("new")
        def page_cached?(action = action_name)
          page_cached_actions.include?(action)
        end
      end
    end
  end
end
