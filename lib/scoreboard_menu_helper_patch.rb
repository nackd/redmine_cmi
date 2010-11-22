require 'redmine/menu_manager'

module MenuHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :render_main_menu, :score_menu
      alias_method_chain :display_main_menu?, :score_menu
    end
  end

  module InstanceMethods
    # Adds a rates tab to the user administration page
    def render_main_menu_with_score_menu(project)
      # Core defined data
      if params[:controller] == 'management'
        render_menu :scoreboard_menu
      else
        render_main_menu_without_score_menu project
      end
    end
    def display_main_menu_with_score_menu?(project)
      # Core defined data
      if params[:controller] == 'management'
        return true
      else
        display_main_menu_without_score_menu? project
      end
    end
  end
end

Redmine::MenuManager::MenuHelper.send :include, MenuHelperPatch
