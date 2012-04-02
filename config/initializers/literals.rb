# Literals from database values

PROJECT_GROUPS = ["Aplicaciones-GIS", "Distribuciones", "Migraciones", "GPI", "GIS", "Otros"]

METRICS = [ 'time_start_planned',
             'time_end_planned',
             'time_start_now',
             'time_end_now',
             'time_end_real',
             'effort_planned',
             'effort_now',
             'effort_real',
             'money_planned',
             'money_now',
             'money_real']

role_field = UserCustomField.find_by_name(DEFAULT_VALUES['user_role_field'])
roles = role_field ? role_field.possible_values : []

INITIAL_METRICS = [ DEFAULT_VALUES['date_start_planned'],
                    DEFAULT_VALUES['date_end_planned'],
                    roles.collect { |role| DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['expected']).gsub('{{profile}}', role) },
                    DEFAULT_VALUES['budget_spected_rrmm'],
                    DEFAULT_VALUES['budget_accepted'],
                    DEFAULT_VALUES['quality_meets_planned'],
                    DEFAULT_VALUES['date_start_real']
                    ].flatten

VARIANT_METRICS = [DEFAULT_VALUES['expected_date_end'],
                   roles.collect { |role| DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', role) },
                   DEFAULT_VALUES['quality_meets_done']
                   ].flatten
