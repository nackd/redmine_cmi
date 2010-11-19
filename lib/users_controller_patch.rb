require_dependency 'users_controller'
require 'dispatcher'

# Patches Redmine's ApplicationController dinamically. Redefines methods wich
# send error responses to clients
module UsersControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      alias_method_chain :edit, :history_profile
    end
  end

  module ClassMethods
  end

  module InstanceMethods

    def edit_with_history_profile
      @user = User.find(params[:id])
      if request.post?
        @user.admin = params[:user][:admin] if params[:user][:admin]
        @user.login = params[:user][:login] if params[:user][:login]
        @user.password, @user.password_confirmation = params[:password], params[:password_confirmation] unless params[:password].nil? or params[:password].empty? or @user.auth_source_id
        @user.group_ids = params[:user][:group_ids] if params[:user][:group_ids]
        change = (@user.role != (params[:user][:custom_field_values]).values[0])
        @user.attributes = params[:user]
        # Was the account actived ? (do it before User#save clears the change)
        was_activated = (@user.status_change == [User::STATUS_REGISTERED, User::STATUS_ACTIVE])
        if @user.save
          if change
            last_profile_status = HistoryUserProfile.find_last_by_user_id @user.id
            last_profile_status.update_attribute(:finished_on, Date.today)
            new_profile = HistoryUserProfile.new(:user_id => @user.id, :profile => (params[:user][:custom_field_values]).values[0])
            new_profile.save
          end
          if was_activated
            Mailer.deliver_account_activated(@user)
          elsif @user.active? && params[:send_information] && !params[:password].blank? && @user.auth_source_id.nil?
            Mailer.deliver_account_information(@user, params[:password])
          end
          flash[:notice] = l(:notice_successful_update)
          redirect_to :back
        end
      end
      @auth_sources = AuthSource.find(:all)
      @membership ||= Member.new
    rescue ::ActionController::RedirectBackError
      redirect_to :controller => 'users', :action => 'edit', :id => @user
    end
  end
end

Dispatcher.to_prepare do
  UsersController.send(:include, UsersControllerPatch)
end
