module CMI
  class ProfileException < ::CMI::Exception
    attr_reader :users

    def initialize(users=[], project='""')
      @users = users
      @project = project
    end

    def to_s
      I18n.t :'cmi.error_profile', :users => @users.join(', '), :project => @project
    end
  end
end
