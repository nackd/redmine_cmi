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

INITIAL_METRICS = [ "#{DEFAULT_VALUES['date_start_planned']}",
                    "#{DEFAULT_VALUES['date_end_planned']}",
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', 'JP')}",
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', 'AF')}",
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', 'AP')}",
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', 'PS')}",
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', 'PJ')}",
                    "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['spected']).gsub('{{profile}}', 'B')}",
                    "#{DEFAULT_VALUES['budget_spected_rrmm']}",
                    "#{DEFAULT_VALUES['budget_accepted']}",
                    "#{DEFAULT_VALUES['quality_meets_planned']}",
                    "#{DEFAULT_VALUES['date_start_real']}"
                    ]

VARIANT_METRICS = ["#{DEFAULT_VALUES['spected_date_end']}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'JP')}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'AF')}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'AP')}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'PS')}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'PJ')}",
                   "#{DEFAULT_VALUES['effort'].gsub('{{type}}', DEFAULT_VALUES['current']).gsub('{{profile}}', 'B')}",
                   "#{DEFAULT_VALUES['quality_meets_done']}"
                   ]

GLOBAL_METRICS = [0.0] * 50

