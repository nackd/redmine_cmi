module CMI
  module Loaders
    module CustomFields
      include Redmine::I18n

      class << self
        # Loads the cmi needed custom fields
        # Raises a RecordNotSaved exception if something goes wrong
        def load
            # IssueCustomField
            tracker = Tracker.find_by_name(DEFAULT_VALUES['tracker']['inform'])
            list = []
            list << IssueCustomField.create!(:type => "IssueCustomField",
                    :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', l(:label_JP)),
                    :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => true,
                    :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            list << IssueCustomField.create!(:type => "IssueCustomField",
                    :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', l(:label_AF)),
                    :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => true,
                    :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            list << IssueCustomField.create!(:type => "IssueCustomField",
                    :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', l(:label_AP)),
                    :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => true,
                    :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            list << IssueCustomField.create!(:type => "IssueCustomField",
                    :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', l(:label_PS)),
                    :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => true,
                    :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            list << IssueCustomField.create!(:type => "IssueCustomField",
                    :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', l(:label_PJ)),
                    :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => true,
                    :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            list << IssueCustomField.create!(:type => "IssueCustomField",
                    :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', l(:label_B)),
                    :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => true,
                    :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            list << IssueCustomField.create!(:type => "IssueCustomField",
                    :name => DEFAULT_VALUES['report_material_original_budget_field'], :field_format => "float",
                    :possible_values => [], :regexp => "", :is_required => true, :is_for_all => true, :is_filter => false,
                    :searchable => false, :editable => true, :default_value => 0)

            list << IssueCustomField.create!(:type => "IssueCustomField",
                    :name => DEFAULT_VALUES['report_material_current_budget_field'], :field_format => "float",
                    :possible_values => [], :regexp => "", :is_required => false, :is_for_all => true, :is_filter => false,
                    :searchable => false, :editable => true, :default_value => 0)
            list << IssueCustomField.create!(:type => "IssueCustomField", :name => DEFAULT_VALUES['expense_value_field'],
                    :field_format => "float", :possible_values => [], :regexp => "", :is_required => false, :is_for_all => true,
                    :is_filter => false, :searchable => false, :editable => true, :default_value => 0)

            list << IssueCustomField.create!(:type => "IssueCustomField", :name => DEFAULT_VALUES['spected_date_end'],
                    :field_format => "date", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => true,
                    :is_filter => false, :searchable => false, :editable => true, :default_value => nil)

            list << IssueCustomField.create!(:type => "IssueCustomField", :name => DEFAULT_VALUES['quality_meets_done'],
                    :field_format => "int", :possible_values => [], :regexp => "", :is_required => false, :is_for_all => true,
                    :is_filter => false, :searchable => false, :editable => true, :default_value => "")

            list.each do |icf|
              icf.trackers[0] = tracker
              tracker.custom_fields << icf
              tracker.save
              icf.save
            end

            ProjectCustomField.create!(:type => "ProjectCustomField", :name => DEFAULT_VALUES['budget_spected_rrmm'],
              :field_format => "float", :possible_values => [], :regexp => "", :is_required => true,
              :is_for_all => false, :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            ProjectCustomField.create!(:type => "ProjectCustomField", :name => DEFAULT_VALUES['budget_accepted'],
              :field_format => "float", :possible_values => [], :regexp => "", :is_required => true,
              :is_for_all => false, :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            ProjectCustomField.create!(:type => "ProjectCustomField",
              :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', l(:label_JP)),
              :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => false,
              :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            ProjectCustomField.create!(:type => "ProjectCustomField",
              :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', l(:label_AF)),
              :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => false,
              :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            ProjectCustomField.create!(:type => "ProjectCustomField",
              :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', l(:label_AP)),
              :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => false,
              :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            ProjectCustomField.create!(:type => "ProjectCustomField",
              :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', l(:label_PS)),
              :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => false,
              :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            ProjectCustomField.create!(:type => "ProjectCustomField",
              :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', l(:label_PJ)),
              :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => false,
              :is_filter => false, :searchable => false, :editable => true, :default_value => 0)
            ProjectCustomField.create!(:type => "ProjectCustomField",
              :name => DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', l(:label_B)),
              :field_format => "float", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => false,
              :is_filter => false, :searchable => false, :editable => true, :default_value => 0)

            ProjectCustomField.create!(:type => "ProjectCustomField", :name => DEFAULT_VALUES['date_start_real'],
              :field_format => "date", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => false,
              :is_filter => false, :searchable => false, :editable => true)
            ProjectCustomField.create!(:type => "ProjectCustomField", :name => DEFAULT_VALUES['date_start_planned'],
              :field_format => "date", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => false,
              :is_filter => false, :searchable => false, :editable => true)
            ProjectCustomField.create!(:type => "ProjectCustomField", :name => DEFAULT_VALUES['date_end_planned'],
              :field_format => "date", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => false,
              :is_filter => false, :searchable => false, :editable => true)

            ProjectCustomField.create!(:type => "ProjectCustomField", :name => DEFAULT_VALUES['quality_meets_planned'],
              :field_format => "int", :possible_values => [], :regexp => "", :is_required => true, :is_for_all => false,
              :is_filter => false, :searchable => false, :editable => true)
            ProjectCustomField.create!(:type => "ProjectCustomField", :name => DEFAULT_VALUES['project_group_field'],
              :field_format => "list", :possible_values => ['Aplicaciones','Distribuciones','Migraciones','GPI','GIS','Otros'],
              :regexp => "", :is_required => true, :is_for_all => false, :is_filter => false, :searchable => false, :editable => false)

            UserCustomField.create!(:type => "UserCustomField", :name => DEFAULT_VALUES['user_role_field'],
              :field_format => "list", :possible_values => [l(:label_JP), l(:label_AF), l(:label_AP), l(:label_PS), l(:label_PJ), l(:label_B)],
              :regexp => "", :is_required => false, :is_for_all => false, :is_filter => false, :searchable => false, :editable => false, :default_value => nil)
        end
      end
    end
  end
end
