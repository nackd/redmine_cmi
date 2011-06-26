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

INITIAL_METRICS = [ "#{DEFAULT_VALUES['date_start_planned']}", # TODO field_project_scheduled_start_date
                    "#{DEFAULT_VALUES['date_end_planned']}", # TODO field_project_scheduled_finish_date
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['expected']).gsub('{{profile}}', 'JP')}",
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['expected']).gsub('{{profile}}', 'AF')}",
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['expected']).gsub('{{profile}}', 'AP')}",
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['expected']).gsub('{{profile}}', 'PS')}",
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['expected']).gsub('{{profile}}', 'PJ')}",
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['expected']).gsub('{{profile}}', 'B')}",
                    "#{DEFAULT_VALUES['budget_spected_rrmm']}",
                    "#{DEFAULT_VALUES['budget_accepted']}", # TODO field_project_total_income
                    "#{DEFAULT_VALUES['quality_meets_planned']}",
                    "#{DEFAULT_VALUES['date_start_real']}" # TODO field_project_actual_start_date
                    ]

VARIANT_METRICS = ["#{DEFAULT_VALUES['expected_date_end']}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'JP')}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'AF')}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'AP')}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'PS')}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'PJ')}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'B')}",
                   "#{DEFAULT_VALUES['quality_meets_done']}"
                   ]
