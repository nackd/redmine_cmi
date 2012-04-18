# -*- coding: utf-8 -*-
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
    assert_select "#effort_done_AF_1", "130.0 hours"
    assert_select "#effort_done_AF_2", "80.0 hours"
    assert_select "#effort_done_AP_0", "260.0 hours"
    assert_select "#effort_done_AP_1", "208.0 hours"
    assert_select "#effort_done_AP_2", "128.0 hours"
    assert_select "#effort_done_PS_0", "520.0 hours"
    assert_select "#effort_done_PS_1", "416.0 hours"
    assert_select "#effort_done_PS_2", "256.0 hours"
    assert_select "#effort_done_PJ_0", "455.0 hours"
    assert_select "#effort_done_PJ_1", "364.0 hours"
    assert_select "#effort_done_PJ_2", "224.0 hours"
    assert_select "#effort_done_B_0", "325.0 hours"
    assert_select "#effort_done_B_1", "260.0 hours"
    assert_select "#effort_done_B_2", "160.0 hours"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:2.93,9.16,14.65,29.3,25.64,18.32&chl=JP: 2.93%|AF: 9.16%|AP: 14.65%|PS: 29.3%|PJ: 25.64%|B: 18.32%" />', css_select("#effort_done_total_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:3.09,9.14,14.63,29.25,25.6,18.28&chl=JP: 3.09%|AF: 9.14%|AP: 14.63%|PS: 29.25%|PJ: 25.6%|B: 18.28%" />', css_select("#effort_done_total_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:3.2,9.13,14.61,29.22,25.57,18.26&chl=JP: 3.2%|AF: 9.13%|AP: 14.61%|PS: 29.22%|PJ: 25.57%|B: 18.26%" />', css_select("#effort_done_total_2 img").first.to_s

    assert_select "#effort_remaining_JP_0", "98.0 hours"
    assert_select "#effort_remaining_JP_1", "106.0 hours"
    assert_select "#effort_remaining_JP_2", "72.0 hours"
    assert_select "#effort_remaining_AF_0", "237.5 hours"
    assert_select "#effort_remaining_AF_1", "270.0 hours"
    assert_select "#effort_remaining_AF_2", "220.0 hours"
    assert_select "#effort_remaining_AP_0", "340.0 hours"
    assert_select "#effort_remaining_AP_1", "392.0 hours"
    assert_select "#effort_remaining_AP_2", "372.0 hours"
    assert_select "#effort_remaining_PS_0", "680.0 hours"
    assert_select "#effort_remaining_PS_1", "784.0 hours"
    assert_select "#effort_remaining_PS_2", "744.0 hours"
    assert_select "#effort_remaining_PJ_0", "545.0 hours"
    assert_select "#effort_remaining_PJ_1", "636.0 hours"
    assert_select "#effort_remaining_PJ_2", "576.0 hours"
    assert_select "#effort_remaining_B_0", "275.0 hours"
    assert_select "#effort_remaining_B_1", "340.0 hours"
    assert_select "#effort_remaining_B_2", "440.0 hours"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:4.5,10.92,15.63,31.26,25.05,12.64&chl=JP: 4.5%|AF: 10.92%|AP: 15.63%|PS: 31.26%|PJ: 25.05%|B: 12.64%" />', css_select("#effort_remaining_total_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:4.19,10.68,15.51,31.01,25.16,13.45&chl=JP: 4.19%|AF: 10.68%|AP: 15.51%|PS: 31.01%|PJ: 25.16%|B: 13.45%" />', css_select("#effort_remaining_total_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:2.97,9.08,15.35,30.69,23.76,18.15&chl=JP: 2.97%|AF: 9.08%|AP: 15.35%|PS: 30.69%|PJ: 23.76%|B: 18.15%" />', css_select("#effort_remaining_total_2 img").first.to_s

    assert_select "#effort_planned_JP_0", "150.0 hours"
    assert_select "#effort_planned_JP_1", "150.0 hours"
    assert_select "#effort_planned_JP_2", "100.0 hours"
    assert_select "#effort_planned_AF_0", "400.0 hours"
    assert_select "#effort_planned_AF_1", "400.0 hours"
    assert_select "#effort_planned_AF_2", "300.0 hours"
    assert_select "#effort_planned_AP_0", "600.0 hours"
    assert_select "#effort_planned_AP_1", "600.0 hours"
    assert_select "#effort_planned_AP_2", "500.0 hours"
    assert_select "#effort_planned_PS_0", "1200.0 hours"
    assert_select "#effort_planned_PS_1", "1200.0 hours"
    assert_select "#effort_planned_PS_2", "1000.0 hours"
    assert_select "#effort_planned_PJ_0", "1000.0 hours"
    assert_select "#effort_planned_PJ_1", "1000.0 hours"
    assert_select "#effort_planned_PJ_2", "800.0 hours"
    assert_select "#effort_planned_B_0", "600.0 hours"
    assert_select "#effort_planned_B_1", "600.0 hours"
    assert_select "#effort_planned_B_2", "600.0 hours"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:3.8,10.13,15.19,30.38,25.32,15.19&chl=JP: 3.8%|AF: 10.13%|AP: 15.19%|PS: 30.38%|PJ: 25.32%|B: 15.19%" />', css_select("#effort_planned_total_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:3.8,10.13,15.19,30.38,25.32,15.19&chl=JP: 3.8%|AF: 10.13%|AP: 15.19%|PS: 30.38%|PJ: 25.32%|B: 15.19%" />', css_select("#effort_planned_total_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:3.03,9.09,15.15,30.3,24.24,18.18&chl=JP: 3.03%|AF: 9.09%|AP: 15.15%|PS: 30.3%|PJ: 24.24%|B: 18.18%" />', css_select("#effort_planned_total_2 img").first.to_s

    assert_select "#time_done_0", "60 days"
    assert_select "#time_done_1", "43 days"
    assert_select "#time_done_2", "15 days"
    assert_select "#time_remaining_0", "122 days"
    assert_select "#time_remaining_1", "139 days"
    assert_select "#time_remaining_2", "136 days"
    assert_select "#time_planned_0", "182 days"
    assert_select "#time_planned_1", "182 days"
    assert_select "#time_planned_2", "151 days"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:32.97|100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x50&chxt=x,y&chxl=0:|0|50|100|1:|32.97 %|" />', css_select("#time_chart_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:23.63|100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x50&chxt=x,y&chxl=0:|0|50|100|1:|23.63 %|" />', css_select("#time_chart_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:9.93|100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x50&chxt=x,y&chxl=0:|0|50|100|1:|9.93 %|" />', css_select("#time_chart_2 img").first.to_s

    assert_select "#cost_hhrr_spent_0", "$24,797.50"
    assert_select "#cost_hhrr_spent_1", "$19,910.00"
    assert_select "#cost_hhrr_spent_2", "$12,280.00"
    assert_select "#cost_other_spent_0", "$0.00"
    assert_select "#cost_other_spent_1", "$0.00"
    assert_select "#cost_other_spent_2", "$0.00"
    assert_select "#cost_total_spent_0", "$24,797.50"
    assert_select "#cost_total_spent_1", "$19,910.00"
    assert_select "#cost_total_spent_2", "$12,280.00"
    assert_select "#cost_hhrr_remaining_0", "$32,702.50"
    assert_select "#cost_hhrr_remaining_1", "$37,590.00"
    assert_select "#cost_hhrr_remaining_2", "$34,220.00"
    assert_select "#cost_other_remaining_0", "$0.00"
    assert_select "#cost_other_remaining_1", "$0.00"
    assert_select "#cost_other_remaining_2", "$0.00"
    assert_select "#cost_total_remaining_0", "$32,702.50"
    assert_select "#cost_total_remaining_1", "$37,590.00"
    assert_select "#cost_total_remaining_2", "$34,220.00"
    assert_select "#cost_hhrr_planned_0", "$57,500.00"
    assert_select "#cost_hhrr_planned_1", "$57,500.00"
    assert_select "#cost_hhrr_planned_2", "$46,500.00"
    assert_select "#cost_other_planned_0", "$0.00"
    assert_select "#cost_other_planned_1", "$0.00"
    assert_select "#cost_other_planned_2", "$0.00"
    assert_select "#cost_total_planned_0", "$57,500.00"
    assert_select "#cost_total_planned_1", "$57,500.00"
    assert_select "#cost_total_planned_2", "$46,500.00"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:43.13,0.0,43.13|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Total: 43.13 %|Otros: 0.0 %|RRHH: 43.13 %|" />', css_select("#cost_chart_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chd=t:100.0,0.0&chs=250x50&chl=RRHH: 100.0 %|Otros: 0.0 %|" />', css_select("#cost_chart_0 img").last.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:34.63,0.0,34.63|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Total: 34.63 %|Otros: 0.0 %|RRHH: 34.63 %|" />', css_select("#cost_chart_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chd=t:100.0,0.0&chs=250x50&chl=RRHH: 100.0 %|Otros: 0.0 %|" />', css_select("#cost_chart_1 img").last.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:26.41,0.0,26.41|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Total: 26.41 %|Otros: 0.0 %|RRHH: 26.41 %|" />', css_select("#cost_chart_2 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=p3&chd=t:100.0,0.0&chs=250x50&chl=RRHH: 100.0 %|Otros: 0.0 %|" />', css_select("#cost_chart_2 img").last.to_s

    assert_select "#advance_effort_JP_0", "34.67 %"
    assert_select "#advance_effort_JP_1", "29.33 %"
    assert_select "#advance_effort_JP_2", "28.0 %"
    assert_select "#advance_effort_AF_0", "40.63 %"
    assert_select "#advance_effort_AF_1", "32.5 %"
    assert_select "#advance_effort_AF_2", "26.67 %"
    assert_select "#advance_effort_AP_0", "43.33 %"
    assert_select "#advance_effort_AP_1", "34.67 %"
    assert_select "#advance_effort_AP_2", "25.6 %"
    assert_select "#advance_effort_PS_0", "43.33 %"
    assert_select "#advance_effort_PS_1", "34.67 %"
    assert_select "#advance_effort_PS_2", "25.6 %"
    assert_select "#advance_effort_PJ_0", "45.5 %"
    assert_select "#advance_effort_PJ_1", "36.4 %"
    assert_select "#advance_effort_PJ_2", "28.0 %"
    assert_select "#advance_effort_B_0", "54.17 %"
    assert_select "#advance_effort_B_1", "43.33 %"
    assert_select "#advance_effort_B_2", "26.67 %"
    assert_select "#advance_effort_total_0", "44.92 %"
    assert_select "#advance_effort_total_1", "36.0 %"
    assert_select "#advance_effort_total_2", "26.55 %"
    assert_select "#advance_time_0", "32.97 %"
    assert_select "#advance_time_1", "23.63 %"
    assert_select "#advance_time_2", "9.93 %"
    assert_select "#advance_hhrr_budget_0", "43.13 %"
    assert_select "#advance_hhrr_budget_1", "34.63 %"
    assert_select "#advance_hhrr_budget_2", "26.41 %"
    assert_select "#advance_other_budget_0", "0.0 %"
    assert_select "#advance_other_budget_1", "0.0 %"
    assert_select "#advance_other_budget_2", "0.0 %"
    assert_select "#advance_total_budget_0", "43.13 %"
    assert_select "#advance_total_budget_1", "34.63 %"
    assert_select "#advance_total_budget_2", "26.41 %"
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:44.92,32.97,43.13|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Coste: 43.13 %|Tiempo: 32.97 %|Esfuerzo: 44.92 %|" />', css_select("#advance_chart_0 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:36.0,23.63,34.63|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Coste: 34.63 %|Tiempo: 23.63 %|Esfuerzo: 36.0 %|" />', css_select("#advance_chart_1 img").first.to_s
    assert_equal '<img src="http://chart.apis.google.com/chart?cht=bhs&chd=t:26.55,9.93,26.41|100,100,100&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|0|50|100|1:|Coste: 26.41 %|Tiempo: 9.93 %|Esfuerzo: 26.55 %|" />', css_select("#advance_chart_2 img").first.to_s

    assert_select "#profitability_planned_initially_0", "$95,456.00 (77.32 %)"
    assert_select "#profitability_planned_initially_1", "$95,456.00 (77.32 %)"
    assert_select "#profitability_planned_initially_2", "$95,456.00 (77.32 %)"
    assert_select "#profitability_planned_currently_0", "$65,956.00 (53.42 %)"
    assert_select "#profitability_planned_currently_1", "$65,956.00 (53.42 %)"
    assert_select "#profitability_planned_currently_2", "$76,956.00 (62.33 %)"
    assert_select "#profitability_current_0", "$98,658.50 (79.91 %)"
    assert_select "#profitability_current_1", "$103,546.00 (83.87 %)"
    assert_select "#profitability_current_2", "$111,176.00 (90.05 %)"
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:88.66,76.71,89.955|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Beneficio actual:79.91 %|Prevista actual: 53.42 %|Prevista inicial: 77.32 %|\" />", css_select("#profitability_chart_0 img").first.to_s
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:88.66,76.71,91.935|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Beneficio actual:83.87 %|Prevista actual: 53.42 %|Prevista inicial: 77.32 %|\" />", css_select("#profitability_chart_1 img").first.to_s
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:88.66,81.165,95.025|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Beneficio actual:90.05 %|Prevista actual: 62.33 %|Prevista inicial: 77.32 %|\" />", css_select("#profitability_chart_2 img").first.to_s

    assert_select "#deviation_effort_0", "88.1 %"
    assert_select "#deviation_effort_1", "88.1 %"
    assert_select "#deviation_effort_2", "57.14 %"
    assert_select "#deviation_time_0", "0.55 %"
    assert_select "#deviation_time_1", "0.55 %"
    assert_select "#deviation_time_2", "-16.57 %"
    assert_select "#deviation_cost_0", "105.36 %"
    assert_select "#deviation_cost_1", "105.36 %"
    assert_select "#deviation_cost_2", "66.07 %"
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:94.05,50.275,102.68|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Coste: 105.36 %|Tiempo: 0.55 %|Esfuerzo: 88.1 %|\" />", css_select("#deviation_chart_0 img").first.to_s
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:94.05,50.275,102.68|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Coste: 105.36 %|Tiempo: 0.55 %|Esfuerzo: 88.1 %|\" />", css_select("#deviation_chart_1 img").first.to_s
    assert_equal "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chd=t:78.57,41.715,83.035|100,100,100&chp=.5&&chxr=0,-100,100&chm=h,000000,0,0.5,0.5&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=250x70&chxt=x,y&chxl=0:|-100|-50|0|50|100|1:|Coste: 66.07 %|Tiempo: -16.57 %|Esfuerzo: 57.14 %|\" />", css_select("#deviation_chart_2 img").first.to_s

    unless Setting.plugin_redmine_cmi['risks_tracker'].blank?
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
    end

    unless Setting.plugin_redmine_cmi['incidents_tracker'].blank?
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
      end

    unless Setting.plugin_redmine_cmi['changes_tracker'].blank?
      assert_select "#changes_accepted_0", "0"
      assert_select "#changes_accepted_1", "0"
      assert_select "#changes_accepted_2", "0"
      assert_select "#changes_rejected_0", "0"
      assert_select "#changes_rejected_1", "0"
      assert_select "#changes_rejected_2", "0"
      assert_select "#changes_effort_0", "0.0 hours (0.0 %)"
      assert_select "#changes_effort_1", "0.0 hours (0.0 %)"
      assert_select "#changes_effort_2", "0.0 hours (0.0 %)"
    end

    unless Setting.plugin_redmine_cmi['conf_category'].blank?
      assert_select "#config_effort_0", "0.0 hours (0.0 %)"
      assert_select "#config_effort_1", "0.0 hours (0.0 %)"
      assert_select "#config_effort_2", "0.0 hours (0.0 %)"
      # TODO assert_select "#config_changes_0", "0.0 hours"
      # TODO assert_select "#config_changes_1", "0.0 hours"
      # TODO assert_select "#config_changes_2", "0.0 hours"
    end

    unless Setting.plugin_redmine_cmi['qa_tracker'].blank?
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
    end

    # TODO assert_select "#metrics_anual_revision_effort_0", "--"
    # TODO assert_select "#metrics_anual_revision_effort_1", "--"
    # TODO assert_select "#metrics_anual_revision_effort_2", "--"
    # TODO assert_select "#metrics_report_effort_0", "--"
    # TODO assert_select "#metrics_report_effort_1", "--"
    # TODO assert_select "#metrics_report_effort_2", "--"
  end
end
