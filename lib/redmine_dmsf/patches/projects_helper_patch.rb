# Redmine plugin for Document Management System "Features"
#
# Copyright © 2011    Vít Jonáš <vit.jonas@gmail.com>
# Copyright © 2012    Daniel Munn <dan.munn@munnster.co.uk>
# Copyright © 2011-18 Karel Pičman <karel.picman@kontron.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module RedmineDmsf
  module Patches
    module ProjectHelperPatch

      def project_settings_tabs_without_patch
        tabs = [{:name => 'info', :action => :edit_project, :partial => 'projects/edit', :label => :label_information_plural},
                {:name => 'modules', :action => :select_project_modules, :partial => 'projects/settings/modules', :label => :label_module_plural},
                {:name => 'members', :action => :manage_members, :partial => 'projects/settings/members', :label => :label_member_plural},
                {:name => 'versions', :action => :manage_versions, :partial => 'projects/settings/versions', :label => :label_version_plural,
                 :url => {:tab => 'versions', :version_status => params[:version_status], :version_name => params[:version_name]}},
                {:name => 'categories', :action => :manage_categories, :partial => 'projects/settings/issue_categories', :label => :label_issue_category_plural},
                {:name => 'wiki', :action => :manage_wiki, :partial => 'projects/settings/wiki', :label => :label_wiki},
                {:name => 'repositories', :action => :manage_repository, :partial => 'projects/settings/repositories', :label => :label_repository_plural},
                {:name => 'boards', :action => :manage_boards, :partial => 'projects/settings/boards', :label => :label_board_plural},
                {:name => 'activities', :action => :manage_project_activities, :partial => 'projects/settings/activities', :label => :enumeration_activities}
        ]
        tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
      end


      ##################################################################################################################
      # Overridden methods

      def project_settings_tabs
        tabs = project_settings_tabs_without_patch
        dmsf_tabs = [
            {:name => 'dmsf', :action => {:controller => 'dmsf_state', :action => 'user_pref_save'},
             :partial => 'dmsf_state/user_pref', :label => :menu_dmsf},
            {:name => 'dmsf_workflow', :action => {:controller => 'dmsf_workflows', :action => 'index'},
             :partial => 'dmsf_workflows/main', :label => :label_dmsf_workflow_plural}
        ]
        tabs.concat(dmsf_tabs.select {|dmsf_tab| User.current.allowed_to?(dmsf_tab[:action], @project)})
        tabs
      end

    end
  end
end

if Redmine::Plugin.installed?(:easy_extensions)
  RedmineExtensions::PatchManager.register_helper_patch 'ProjectsHelper',
                                                        'RedmineDmsf::Patches::ProjectHelperPatch', prepend: true
else
  RedmineExtensions::PatchManager.register_patch_to_be_first 'ProjectsHelper',
                                                             'RedmineDmsf::Patches::ProjectHelperPatch', prepend: true, first: true
end