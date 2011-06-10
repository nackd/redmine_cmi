module CMI
  class ProfileException < ::CMI::Exception
    attr_reader :users

    def initialize(users=[], project='""')
      @users = users
      @project = project
    end

    def to_s
      "Hay usuarios (#{@users.join(',')}) sin perfil asignado en el proyecto '#{@project}'. Es necesario para poder realizar los cálculos correctamente."
    end
  end
end
