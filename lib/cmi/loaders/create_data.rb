module CMI
  module Loaders
    module CreateData
      # Create needed custom fields
      def self.load
        ProjectCustomField.create(:type => "ProjectCustomField", :name => DEFAULT_VALUES['project_group_field'],
                                  :field_format => "list", :possible_values => ['Aplicaciones','Distribuciones','Migraciones','GPI','GIS','Otros'],
                                  :regexp => "", :is_required => true, :is_for_all => false, :is_filter => false, :searchable => false, :editable => false)

        UserCustomField.create(:type => "UserCustomField", :name => DEFAULT_VALUES['user_role_field'],
                               :field_format => "list", :possible_values => ['JP', 'AF', 'AP', 'PS', 'PJ', 'B'],
                               :regexp => "", :is_required => true, :is_for_all => false, :is_filter => false, :searchable => false, :editable => false, :default_value => nil)
      end
    end
  end
end
