require File.dirname(__FILE__) + "/../test_helper"

class MetricsControllerTest < ActionController::TestCase
  # We are managing this ourselves
  self.use_transactional_fixtures = false

  def self.suite
    mysuite = super
    def mysuite.run(*args)
      ActiveRecord::Base.connection.transaction do
        create_test_data
        super
        raise ActiveRecord::Rollback
      end
    end
    mysuite
  end

  test "routing" do
    assert_routing({:method => :get, :path => "/projects/:project_id/metrics/show"},
                   :controller => "metrics", :project_id => ":project_id", :action => "show")
    assert_routing({:method => :get, :path => "/projects/:project_id/metrics/info"},
                   :controller => "metrics", :project_id => ":project_id", :action => "info")
    assert_routing({:method => :get, :path => "/projects/:project_id/metrics/checkpoints"},
                   :controller => "checkpoints", :project_id => ":project_id", :action => "index")
    assert_routing({:method => :get, :path => "/projects/:project_id/metrics/expenditures"},
                   :controller => "expenditures", :project_id => ":project_id", :action => "index")
  end

  test "deny access to non-members" do
    @request.session[:user_id] = User.find_by_login("nonmember").id
    get :show, :project_id => "cmi"
    assert_response :forbidden
  end

  test "metrics" do
    Time.stubs(:now).returns(Time.mktime(2011, 4, 1))
    @request.session[:user_id] = User.find_by_login("jp").id
    get :show, :project_id => "cmi"
    assert_response :success
    assert_template :show

    assert_select "#effort_done_JP_0", "52.0 hours"
    assert_select "#effort_done_JP_1", "44.0 hours"
    assert_select "#effort_done_JP_2", "28.0 hours"
    assert_select "#effort_done_AF_0", "162.5 hours"
    assert_select "#effort_done_AF_1", "127.5 hours"
    assert_select "#effort_done_AF_2", "77.5 hours"
    assert_select "#effort_done_AP_0", "260.0 hours"
    assert_select "#effort_done_AP_1", "204.0 hours"
    assert_select "#effort_done_AP_2", "124.0 hours"
    assert_select "#effort_done_PS_0", "520.0 hours"
    assert_select "#effort_done_PS_1", "408.0 hours"
    assert_select "#effort_done_PS_2", "248.0 hours"
    assert_select "#effort_done_PJ_0", "455.0 hours"
    assert_select "#effort_done_PJ_1", "357.0 hours"
    assert_select "#effort_done_PJ_2", "217.0 hours"
    assert_select "#effort_done_B_0", "325.0 hours"
    assert_select "#effort_done_B_1", "255.0 hours"
    assert_select "#effort_done_B_2", "155.0 hours"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:2.93,9.16,14.65,29.3,25.64,18.32&chl=JP: 2.93%|AF: 9.16%|AP: 14.65%|PS: 29.3%|PJ: 25.64%|B: 18.32%" />', css_select("#effort_done_total_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:3.15,9.14,14.62,29.24,25.58,18.27&chl=JP: 3.15%|AF: 9.14%|AP: 14.62%|PS: 29.24%|PJ: 25.58%|B: 18.27%" />', css_select("#effort_done_total_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:3.3,9.12,14.6,29.19,25.54,18.25&chl=JP: 3.3%|AF: 9.12%|AP: 14.6%|PS: 29.19%|PJ: 25.54%|B: 18.25%" />', css_select("#effort_done_total_2 img").first.to_s

    assert_select "#effort_remaining_JP_0", "98.0 hours"
    assert_select "#effort_remaining_JP_1", "106.0 hours"
    assert_select "#effort_remaining_JP_2", "72.0 hours"
    assert_select "#effort_remaining_AF_0", "237.5 hours"
    assert_select "#effort_remaining_AF_1", "272.5 hours"
    assert_select "#effort_remaining_AF_2", "222.5 hours"
    assert_select "#effort_remaining_AP_0", "340.0 hours"
    assert_select "#effort_remaining_AP_1", "396.0 hours"
    assert_select "#effort_remaining_AP_2", "376.0 hours"
    assert_select "#effort_remaining_PS_0", "680.0 hours"
    assert_select "#effort_remaining_PS_1", "792.0 hours"
    assert_select "#effort_remaining_PS_2", "752.0 hours"
    assert_select "#effort_remaining_PJ_0", "545.0 hours"
    assert_select "#effort_remaining_PJ_1", "643.0 hours"
    assert_select "#effort_remaining_PJ_2", "583.0 hours"
    assert_select "#effort_remaining_B_0", "275.0 hours"
    assert_select "#effort_remaining_B_1", "345.0 hours"
    assert_select "#effort_remaining_B_2", "445.0 hours"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:4.5,10.92,15.63,31.26,25.05,12.64&chl=JP: 4.5%|AF: 10.92%|AP: 15.63%|PS: 31.26%|PJ: 25.05%|B: 12.64%" />', css_select("#effort_remaining_total_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:4.15,10.67,15.5,31.0,25.17,13.51&chl=JP: 4.15%|AF: 10.67%|AP: 15.5%|PS: 31.0%|PJ: 25.17%|B: 13.51%" />', css_select("#effort_remaining_total_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:2.94,9.08,15.34,30.69,23.79,18.16&chl=JP: 2.94%|AF: 9.08%|AP: 15.34%|PS: 30.69%|PJ: 23.79%|B: 18.16%" />', css_select("#effort_remaining_total_2 img").first.to_s

    assert_select "#effort_planned_JP_0", "150 hours"
    assert_select "#effort_planned_JP_1", "150 hours"
    assert_select "#effort_planned_JP_2", "100 hours"
    assert_select "#effort_planned_AF_0", "400 hours"
    assert_select "#effort_planned_AF_1", "400 hours"
    assert_select "#effort_planned_AF_2", "300 hours"
    assert_select "#effort_planned_AP_0", "600 hours"
    assert_select "#effort_planned_AP_1", "600 hours"
    assert_select "#effort_planned_AP_2", "500 hours"
    assert_select "#effort_planned_PS_0", "1200 hours"
    assert_select "#effort_planned_PS_1", "1200 hours"
    assert_select "#effort_planned_PS_2", "1000 hours"
    assert_select "#effort_planned_PJ_0", "1000 hours"
    assert_select "#effort_planned_PJ_1", "1000 hours"
    assert_select "#effort_planned_PJ_2", "800 hours"
    assert_select "#effort_planned_B_0", "600 hours"
    assert_select "#effort_planned_B_1", "600 hours"
    assert_select "#effort_planned_B_2", "600 hours"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:3.8,10.13,15.19,30.38,25.32,15.19&chl=JP: 3.8%|AF: 10.13%|AP: 15.19%|PS: 30.38%|PJ: 25.32%|B: 15.19%" />', css_select("#effort_planned_total_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:3.8,10.13,15.19,30.38,25.32,15.19&chl=JP: 3.8%|AF: 10.13%|AP: 15.19%|PS: 30.38%|PJ: 25.32%|B: 15.19%" />', css_select("#effort_planned_total_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:3.03,9.09,15.15,30.3,24.24,18.18&chl=JP: 3.03%|AF: 9.09%|AP: 15.15%|PS: 30.3%|PJ: 24.24%|B: 18.18%" />', css_select("#effort_planned_total_2 img").first.to_s

    assert_select "#time_done_0", "60 days"
    assert_select "#time_done_1", "42 days"
    assert_select "#time_done_2", "14 days"
    assert_select "#time_remaining_0", "121 days"
    assert_select "#time_remaining_1", "139 days"
    assert_select "#time_remaining_2", "136 days"
    assert_select "#time_planned_0", "181 days"
    assert_select "#time_planned_1", "181 days"
    assert_select "#time_planned_2", "150 days"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:33.15|100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x50&chxt=x,y&chxl=0:|0|50|100|1:|33.15% |" />', css_select("#time_chart_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:23.2|100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x50&chxt=x,y&chxl=0:|0|50|100|1:|23.2% |" />', css_select("#time_chart_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:9.33|100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x50&chxt=x,y&chxl=0:|0|50|100|1:|9.33% |" />', css_select("#time_chart_2 img").first.to_s

    assert_select "#cost_hhrr_spent_0", "24797.5 &euro;"
    assert_select "#cost_hhrr_spent_1", "19552.5 &euro;"
    assert_select "#cost_hhrr_spent_2", "11922.5 &euro;"
    assert_select "#cost_other_spent_0", "0 &euro;"
    assert_select "#cost_other_spent_1", "0 &euro;"
    assert_select "#cost_other_spent_2", "0 &euro;"
    assert_select "#cost_total_spent_0", "24797.5 &euro;"
    assert_select "#cost_total_spent_1", "19552.5 &euro;"
    assert_select "#cost_total_spent_2", "11922.5 &euro;"
    assert_select "#cost_hhrr_remaining_0", "32702.5 &euro;"
    assert_select "#cost_hhrr_remaining_1", "37947.5 &euro;"
    assert_select "#cost_hhrr_remaining_2", "34577.5 &euro;"
    assert_select "#cost_other_remaining_0", "0 &euro;"
    assert_select "#cost_other_remaining_1", "0 &euro;"
    assert_select "#cost_other_remaining_2", "0 &euro;"
    assert_select "#cost_total_remaining_0", "32702.5 &euro;"
    assert_select "#cost_total_remaining_1", "37947.5 &euro;"
    assert_select "#cost_total_remaining_2", "34577.5 &euro;"
    assert_select "#cost_hhrr_planned_0", "57500.0 &euro;"
    assert_select "#cost_hhrr_planned_1", "57500.0 &euro;"
    assert_select "#cost_hhrr_planned_2", "46500.0 &euro;"
    assert_select "#cost_other_planned_0", "0 &euro;"
    assert_select "#cost_other_planned_1", "0 &euro;"
    assert_select "#cost_other_planned_2", "0 &euro;"
    assert_select "#cost_total_planned_0", "57500.0 &euro;"
    assert_select "#cost_total_planned_1", "57500.0 &euro;"
    assert_select "#cost_total_planned_2", "46500.0 &euro;"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:43.13,0.0,43.13|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Total: 43.13%|Otros: 0.0%|RRHH: 43.13%|" />', css_select("#cost_chart_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chd=t:100.0,0.0&chs=250x50&chl=RRHH: 100.0%|Otros: 0.0%|" />', css_select("#cost_chart_0 img").last.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:34.0,0.0,34.0|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Total: 34.0%|Otros: 0.0%|RRHH: 34.0%|" />', css_select("#cost_chart_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chd=t:100.0,0.0&chs=250x50&chl=RRHH: 100.0%|Otros: 0.0%|" />', css_select("#cost_chart_1 img").last.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:25.64,0.0,25.64|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Total: 25.64%|Otros: 0.0%|RRHH: 25.64%|" />', css_select("#cost_chart_2 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chd=t:100.0,0.0&chs=250x50&chl=RRHH: 100.0%|Otros: 0.0%|" />', css_select("#cost_chart_2 img").last.to_s

    assert_select "#advance_effort_JP_0", "34.67 %"
    assert_select "#advance_effort_JP_1", "29.33 %"
    assert_select "#advance_effort_JP_2", "28.0 %"
    assert_select "#advance_effort_AF_0", "40.63 %"
    assert_select "#advance_effort_AF_1", "31.88 %"
    assert_select "#advance_effort_AF_2", "25.83 %"
    assert_select "#advance_effort_AP_0", "43.33 %"
    assert_select "#advance_effort_AP_1", "34.0 %"
    assert_select "#advance_effort_AP_2", "24.8 %"
    assert_select "#advance_effort_PS_0", "43.33 %"
    assert_select "#advance_effort_PS_1", "34.0 %"
    assert_select "#advance_effort_PS_2", "24.8 %"
    assert_select "#advance_effort_PJ_0", "45.5 %"
    assert_select "#advance_effort_PJ_1", "35.7 %"
    assert_select "#advance_effort_PJ_2", "27.13 %"
    assert_select "#advance_effort_B_0", "54.17 %"
    assert_select "#advance_effort_B_1", "42.5 %"
    assert_select "#advance_effort_B_2", "25.83 %"
    assert_select "#advance_effort_total_0", "44.92 %"
    assert_select "#advance_effort_total_1", "35.33 %"
    assert_select "#advance_effort_total_2", "25.74 %"
    assert_select "#advance_time_0", "33.15 %"
    assert_select "#advance_time_1", "23.2 %"
    assert_select "#advance_time_2", "9.33 %"
    assert_select "#advance_hhrr_budget_0", "43.13 %"
    assert_select "#advance_hhrr_budget_1", "34.0 %"
    assert_select "#advance_hhrr_budget_2", "25.64 %"
    assert_select "#advance_other_budget_0", "0.0 %"
    assert_select "#advance_other_budget_1", "0.0 %"
    assert_select "#advance_other_budget_2", "0.0 %"
    assert_select "#advance_total_budget_0", "43.13 %"
    assert_select "#advance_total_budget_1", "34.0 %"
    assert_select "#advance_total_budget_2", "25.64 %"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:44.92,33.15,43.13|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Coste: 43.13%|Tiempo: 33.15%|Esfuerzo: 44.92%|" />', css_select("#advance_chart_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:35.33,23.2,34.0|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Coste: 34.0%|Tiempo: 23.2%|Esfuerzo: 35.33%|" />', css_select("#advance_chart_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:25.74,9.33,25.64|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Coste: 25.64%|Tiempo: 9.33%|Esfuerzo: 25.74%|" />', css_select("#advance_chart_2 img").first.to_s

    assert_select "#profitability_planned_initially_0", "95456.0 &euro; (77.0 %)"
    assert_select "#profitability_planned_initially_1", "95456.0 &euro; (77.0 %)"
    assert_select "#profitability_planned_initially_2", "95456.0 &euro; (77.0 %)"
    assert_select "#profitability_planned_currently_0", "65956.0 &euro; (53.0 %)"
    assert_select "#profitability_planned_currently_1", "65956.0 &euro; (53.0 %)"
    assert_select "#profitability_planned_currently_2", "76956.0 &euro; (62.0 %)"
    assert_select "#profitability_current_0", "98658.5 &euro; (80.0 %)"
    assert_select "#profitability_current_1", "103546.0 &euro; (84.0 %)"
    assert_select "#profitability_current_2", "111176.0 &euro; (90.0 %)"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:88.5,76.5,90.0|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Beneficio actual:80.0%|Prevista actual: 53.0%|Prevista inicial: 77.0%|" />', css_select("#profitability_chart_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:88.5,76.5,92.0|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Beneficio actual:84.0%|Prevista actual: 53.0%|Prevista inicial: 77.0%|" />', css_select("#profitability_chart_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:88.5,81.0,95.0|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Beneficio actual:90.0%|Prevista actual: 62.0%|Prevista inicial: 77.0%|" />', css_select("#profitability_chart_2 img").first.to_s

    assert_select "#deviation_effort_0", "-88.1 %"
    assert_select "#deviation_effort_1", "-88.1 %"
    assert_select "#deviation_effort_2", "-57.14 %"
    assert_select "#deviation_time_0", "0.0 %"
    assert_select "#deviation_time_1", "0.0 %"
    assert_select "#deviation_time_2", "17.13 %"
    assert_select "#deviation_cost_0", "-105.36 %"
    assert_select "#deviation_cost_1", "-105.36 %"
    assert_select "#deviation_cost_2", "-66.07 %"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:5.95,50.0,-2.68|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Coste: -105.36%|Tiempo: 0.0%|Esfuerzo: -88.1%|" />', css_select("#deviation_chart_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:5.95,50.0,-2.68|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Coste: -105.36%|Tiempo: 0.0%|Esfuerzo: -88.1%|" />', css_select("#deviation_chart_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:21.43,58.565,16.965|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Coste: -66.07%|Tiempo: 17.13%|Esfuerzo: -57.14%|" />', css_select("#deviation_chart_2 img").first.to_s

    assert_select "#risk_high_0", "0"
    assert_select "#risk_high_1", "0"
    assert_select "#risk_high_2", "0"
    assert_select "#risk_medium_0", "0"
    assert_select "#risk_medium_1", "0"
    assert_select "#risk_medium_2", "0"
    assert_select "#risk_low_0", "0"
    assert_select "#risk_low_1", "0"
    assert_select "#risk_low_2", "0"
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:0,0,0&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Bajo: 0|Medio: 0|Alto: 0|\" />", css_select("#risk_chart_0 img").first.to_s
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:0,0,0&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Bajo: 0|Medio: 0|Alto: 0|\" />", css_select("#risk_chart_1 img").first.to_s
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:0,0,0&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Bajo: 0|Medio: 0|Alto: 0|\" />", css_select("#risk_chart_2 img").first.to_s

    assert_select "#incident_high_0", "0"
    assert_select "#incident_high_1", "0"
    assert_select "#incident_high_2", "0"
    assert_select "#incident_medium_0", "0"
    assert_select "#incident_medium_1", "0"
    assert_select "#incident_medium_2", "0"
    assert_select "#incident_low_0", "0"
    assert_select "#incident_low_1", "0"
    assert_select "#incident_low_2", "0"
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:0,0,0&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Bajo: 0|Medio: 0|Alto: 0|\" />", css_select("#incident_chart_0 img").first.to_s
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:0,0,0&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Bajo: 0|Medio: 0|Alto: 0|\" />", css_select("#incident_chart_1 img").first.to_s
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:0,0,0&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Bajo: 0|Medio: 0|Alto: 0|\" />", css_select("#incident_chart_2 img").first.to_s

    assert_select "#changes_accepted_0", "0"
    assert_select "#changes_accepted_1", "0"
    assert_select "#changes_accepted_2", "0"
    assert_select "#changes_rejected_0", "0"
    assert_select "#changes_rejected_1", "0"
    assert_select "#changes_rejected_2", "0"
    assert_select "#changes_effort_0", "0.0 hours (0.0 %)"
    assert_select "#changes_effort_1", "0.0 hours (0.0 %)"
    assert_select "#changes_effort_2", "0.0 hours (0.0 %)"

    assert_select "#config_effort_0", "0.0 hours (0.0 %)"
    assert_select "#config_effort_1", "0.0 hours (0.0 %)"
    assert_select "#config_effort_2", "0.0 hours (0.0 %)"
    # TODO assert_select "#config_changes_0", "0.0 hours"
    # TODO assert_select "#config_changes_1", "0.0 hours"
    # TODO assert_select "#config_changes_2", "0.0 hours"

    assert_select "#qa_meets_done_0", "1 (0.33 %)"
    assert_select "#qa_meets_done_1", "1 (0.33 %)"
    assert_select "#qa_meets_done_2", "0 (0.0 %)"
    assert_select "#qa_nc_detected_0", "0"
    assert_select "#qa_nc_detected_1", "0"
    assert_select "#qa_nc_detected_2", "0"
    assert_select "#qa_nc_pending_0", "0"
    assert_select "#qa_nc_pending_1", "0"
    assert_select "#qa_nc_pending_2", "0"
    assert_select "#qa_pending_corrective_0", "0"
    assert_select "#qa_pending_corrective_1", "0"
    assert_select "#qa_pending_corrective_2", "0"
    assert_select "#qa_no_date_corrective_0", "0"
    assert_select "#qa_no_date_corrective_1", "0"
    assert_select "#qa_no_date_corrective_2", "0"
    assert_select "#qa_effort_corrective_0", "0.0 (0.0 %)"
    assert_select "#qa_effort_corrective_1", "0.0 (0.0 %)"
    assert_select "#qa_effort_corrective_2", "0.0 (0.0 %)"

    # TODO assert_select "#metrics_anual_revision_effort_0", "--"
    # TODO assert_select "#metrics_anual_revision_effort_1", "--"
    # TODO assert_select "#metrics_anual_revision_effort_2", "--"
    # TODO assert_select "#metrics_report_effort_0", "--"
    # TODO assert_select "#metrics_report_effort_1", "--"
    # TODO assert_select "#metrics_report_effort_2", "--"
  end
end
