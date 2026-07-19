
import { registry } from '@web/core/registry';
const { Component, onWillStart, onMounted, useState, useRef } = owl
import { useService } from "@web/core/utils/hooks";
import { rpc } from "@web/core/network/rpc";
import { loadJS } from "@web/core/assets";
import { _t } from "@web/core/l10n/translation";

export class appointmentDashboard extends Component {
  setup() {
    this.action = useService("action");
    this.orm = useService("orm");
    this.rpc = this.env.services.rpc
    this.state = useState({

      user_name: { value: 'User Image' },
      user_img: { value: 'User Name' },
      total_appointment: [],
      draft_appointment_list: [],
      confirm_appointment_list: [],
      done_appointment_list: [],
      cancel_appointment_list: [],

      upcoming_appointment_list: {},
      rowsPerPage: 6,
      upcoming_appointment_list_length: 0,
      current_upcoming_appointment_page: 1,

    })
    onMounted(this.onMounted);
    onWillStart(this.onWillStart)

  }

  async onWillStart() {
    await this.getCardData()
    await this.getGreetings()
    await loadJS("https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js")
  }

  async getGreetings() {
    var self = this;
    const now = new Date();
    const hours = now.getHours();
    if (hours >= 5 && hours < 12) {
      self.greetings = "Good Morning";
    }
    else if (hours >= 12 && hours < 18) {
      self.greetings = "Good Afternoon";
    }
    else {
      self.greetings = "Good Evening";
    }
  }

  async onMounted() {
    this.month_wise_appointmentChart();
    this.top_demanded_service_chart();
    this.top_revenue_service_chart();
    this.render_upcoming_appointment_list(this.state.rowsPerPage, this.state.current_upcoming_appointment_page);
    this.render_appointment_filter();
  }

  _onchangeAppointmentFilter(ev) {
    this.flag = 1
    var user_selection = document.querySelector('#user_selection').value;
    var duration_selection = document.querySelector('#request_date').value;
    this.month_wise_appointmentChart();
    this.top_demanded_service_chart();
    this.top_revenue_service_chart();
    this.render_upcoming_appointment_list(this.state.rowsPerPage, this.state.current_upcoming_appointment_page);



    var self = this;
    rpc('/appointment/filter-apply', {
      'data': {
        'user': user_selection,
        'duration': duration_selection,

      }
    }).then(function (data) {

      self.state.total_appointment = data['total_appointment']
      self.state.draft_appointment_list = data['draft_appointment_list']
      self.state.confirm_appointment_list = data['confirm_appointment_list']
      self.state.done_appointment_list = data['done_appointment_list'],
        self.state.cancel_appointment_list = data['cancel_appointment_list']
    })
  }

  _downloadChart(e) {
    var chartId = e.target.id.slice(0, e.target.id.length - 4)
    var chartEle = document.querySelector("#" + chartId)
    const imageDataURL = chartEle.toDataURL('image/png');
    const filename = chartId + '.png';
    const link = document.createElement('a');
    link.href = imageDataURL;
    link.download = filename;
    link.click();
  }

  downloadReport(e) {
    window.print();

  }

  // Month wise appointment chart
  async month_wise_appointmentChart(ev) {
    var user_selection = document.querySelector('#user_selection').value;
    var month_chart_selection = document.querySelector('#month_chart_selection').value;

    
    var self = this;
    await rpc("/month_wise/appointment/chart/data",
      {
        'data':
        {
          'user_id': user_selection,
        }
      }).then(function (data) {
        var ctx = document.querySelector("#month_wise_appointment_chart_data");
        new Chart(ctx, {
          type: month_chart_selection,
          data: data.appointment_chart_data,
          options: {
            maintainAspectRatio: false,
            onClick: (evt, elements) => {
              if (elements.length > 0) {
                const element = elements[0];
                const clickedIndex = element.index;
                const clickedLabel = data.appointment_chart_data.labels[clickedIndex];
                const clickedValue = data.appointment_chart_data.datasets[0].detail[clickedIndex]

                var options = {
                };
                self.action.doAction({
                  name: _t(clickedLabel),
                  type: 'ir.actions.act_window',
                  res_model: 'calendar.event',
                  domain: [["id", "in", clickedValue]],
                  view_mode: 'list,form',
                  views: [
                    [false, 'list'],
                    [false, 'form']
                  ],
                  target: 'current'
                }, options)
              } else {

              }
            }
          }
        });
      });
  }

  // Top demanded service chart
  async top_demanded_service_chart(ev) {
    var user_selection = document.querySelector('#user_selection').value;
    var duration_selection = document.querySelector('#request_date').value;
    var service_chart_selection = document.querySelector('#service_chart_selection').value;
    var service_range_selection = document.querySelector('#service_range_selection').value;

    var self = this;

    await rpc("/top/demanded/service/chart/data", {

      'data': {
        'user_id': user_selection,
        'duration': duration_selection,
        'top_demanded_service_count': service_range_selection,
      }
    }).then(function (data) {
      var ctx = document.querySelector("#top_demanded_service_chart");
      new Chart(ctx, {
        type: service_chart_selection,
        data: data.top_demanded_service_chart_data,
        options: {
          maintainAspectRatio: false,
          onClick: (evt, elements) => {
            if (elements.length > 0) {
              const element = elements[0];
              const clickedIndex = element.index;
              const clickedLabel = data.top_demanded_service_chart_data.labels[clickedIndex];
              const clickedValue = data.top_demanded_service_chart_data.datasets[0].detail[clickedIndex];
              self.action.doAction({
                name: _t(clickedLabel),
                type: 'ir.actions.act_window',
                res_model: 'calendar.event',
                domain: [["id", "in", clickedValue]],
                view_mode: 'list,form',
                views: [
                  [false, 'list'],
                  [false, 'form']
                ],
                target: 'current'
              });
            }
          }
        }
      });
    });
  }

  // Top Revenue by service
  async top_revenue_service_chart(ev) {
    var user_selection = document.querySelector('#user_selection').value;
    var duration_selection = document.querySelector('#request_date').value;
    var service_revenue_chart_selection = document.querySelector('#service_revenue_chart_selection').value;
    var service_revenue_range_selection = document.querySelector('#service_revenue_range_selection').value;

    var self = this;

    await rpc("/top/revenue/service/chart/data", {

      'data': {
        'user_id': user_selection,
        'duration': duration_selection,
        'top_revenue_service_count': service_revenue_range_selection,
      }
    }).then(function (data) {
      var ctx = document.querySelector("#top_revenue_by_service_chart");
      new Chart(ctx, {
        type: service_revenue_chart_selection,
        data: data.top_revenue_service_chart_data,
        options: {
          maintainAspectRatio: false,
          onClick: (evt, elements) => {
            if (elements.length > 0) {
              const element = elements[0];
              const clickedIndex = element.index;
              const clickedLabel = data.top_revenue_service_chart_data.labels[clickedIndex];
              const clickedValue = data.top_revenue_service_chart_data.datasets[0].detail[clickedIndex];
              self.action.doAction({
                name: _t(clickedLabel),
                type: 'ir.actions.act_window',
                res_model: 'calendar.event',
                domain: [["id", "in", clickedValue]],
                view_mode: 'list,form',
                views: [
                  [false, 'list'],
                  [false, 'form']
                ],
                target: 'current'
              });
            }
          }
        }
      });
    });
  }


  // Upcoming appointment 
  async render_upcoming_appointment_list(rowsPerPage, page) {
    var appointment_upcoming_selection = document.querySelector('#appointment_upcoming_selection').value;
    var user_selection = document.querySelector('#user_selection').value;


    self = this
    await rpc("/upcoming/appointment/list/data", {
      'data':
      {
        'upc_duration': appointment_upcoming_selection,
        'user_id': user_selection,

      }
    }).then(function (data) {
      self.state.upcoming_appointment_list = data['all_upcoming_appointment_lst'];
      var tbody = document.querySelector("#all_upcoming_appointment_lst tbody");
      tbody.innerHTML = '';

      self.state.upcoming_appointment_list_length = self.state.upcoming_appointment_list.length

      const start = (page - 1) * rowsPerPage;
      const end = start + rowsPerPage;
      const paginatedData = self.state.upcoming_appointment_list.slice(start, end)

      for (var i = 0; i < paginatedData.length; i++) {
        var row = document.createElement("tr");
        for (var key in paginatedData[i]) {
          if (key !== 'id') {
            var cell = document.createElement("td");
            if (paginatedData[i][key].length == 2) {
              cell.textContent = paginatedData[i][key][1];
              row.appendChild(cell);
            }
            else if (key === 'start') {
              var cell = document.createElement("td");
              var date = paginatedData[i]['start']
              if (date) {
                var date_splited = date.split(' ')[0].split('-');
                cell.textContent = date_splited[2] + '-' + date_splited[1] + '-' + date_splited[0];
              }
              else {
                cell.textContent = '-'
              }
              row.appendChild(cell);
            }
            else if (key === 'state') {
              var cell = document.createElement("td");
              var value = paginatedData[i]['state'];
              if (value) {
                var formatted = value.charAt(0).toUpperCase() + value.slice(1).toLowerCase();
                cell.textContent = formatted;
              } else {
                cell.textContent = '-';
              }
              row.appendChild(cell);
            }

            else {
              if (paginatedData[i][key] == false) {
                cell.textContent = '-';
                row.appendChild(cell);
              }
              else {
                cell.textContent = paginatedData[i][key];
                row.appendChild(cell);
              }
            }

          }
        }
        var buttonCell = document.createElement("td");
        var button = document.createElement("button");
        button.textContent = "View";
        button.style.backgroundColor = "#2a34bb";
        button.style.color = "#ffffff";
        button.className = "btn-primary rounded p-2";
        button.style.border = "none";

        button.setAttribute("data-id", paginatedData[i].id);
        button.addEventListener("click", function () {
          var id = this.getAttribute("data-id");
          // Call your function with the ID
          appointment_tree_button_function(id);
        });
        buttonCell.appendChild(button);
        row.appendChild(buttonCell);
        tbody.appendChild(row);
      }

      function appointment_tree_button_function(id) {
        var options = {
        };
        self.action.doAction({
          name: _t("Lesson"),
          type: 'ir.actions.act_window',
          res_model: 'calendar.event',
          domain: [["id", "=", id]],
          view_mode: 'list,form',
          views: [
            [false, 'list'],
            [false, 'form']
          ],
          target: 'current'
        }, options)

      }
    });
  }

  upcomingPrevPage(e) {
    if (this.state.current_upcoming_appointment_page > 1) {
      this.state.current_upcoming_appointment_page--;
      this.render_upcoming_appointment_list(this.state.rowsPerPage, this.state.current_upcoming_appointment_page);
      document.getElementById("upcoming_next_button").disabled = false;
    }
    if (this.state.current_upcoming_appointment_page == 1) {
      document.getElementById("upcoming_prev_button").disabled = true;
    } else {
      document.getElementById("upcoming_prev_button").disabled = false;
    }
  }

  upcomingNextPage() {
    if ((this.state.current_upcoming_appointment_page * this.state.rowsPerPage) < this.state.upcoming_appointment_list_length) {
      this.state.current_upcoming_appointment_page++;
      this.render_upcoming_appointment_list(this.state.rowsPerPage, this.state.current_upcoming_appointment_page);
      document.getElementById("upcoming_prev_button").disabled = false;
    }
    if (Math.ceil(this.state.upcoming_appointment_list_length / this.state.rowsPerPage) == this.state.upcoming_appointment_list_length) {
      document.getElementById("upcoming_next_button").disabled = true;
    } else {
      document.getElementById("upcoming_next_button").disabled = false;
    }
  }


  action_all_appointment_counter(e) {
    e.stopPropagation();
    e.preventDefault();
    var cont = { search_default_no_share: true };
    var options = {
      on_reverse_breadcrumb: this.on_reverse_breadcrumb,
    };
    var rec_id = e.currentTarget.getAttribute('rec-id');
    var action = e.currentTarget.id || false;
    var domain = false;

    var title_name = ' ';

    if (action == 'all_appointment_id') {
      domain = [["id", "in", this.state.total_appointment]];
      title_name = 'Total Appointment'

    }
    else if (action == 'draft_appointment_id') {
      domain = [["id", "in", this.state.draft_appointment_list]];
      title_name = 'Draft Appointment'

    }
    else if (action == 'confirm_appointment_id') {
      domain = [["id", "in", this.state.confirm_appointment_list]];
      title_name = 'Confirm Appointment'

    }
    else if (action == 'done_appointment_id') {
      domain = [["id", "in", this.state.done_appointment_list]]
      title_name = 'Done Appointment'
    }

    else if (action == 'cancel_appointment_id') {
      domain = [["id", "in", this.state.cancel_appointment_list]]
      title_name = 'Cancel Appointment'
    }

    else if (rec_id != 'undefined') {
      domain = [["id", "=", rec_id]]
    }
    this.action.doAction({
      name: _t(title_name),
      type: 'ir.actions.act_window',
      res_model: 'calendar.event',
      domain: domain,
      view_mode: 'list,form',
      views: [
        [false, 'list'],
        [false, 'form']
      ],
      target: 'current'
    }, options)
  }


  render_appointment_filter() {
    rpc('/appointment/all_filter').then(function (data) {
      var users = data[0]
      users?.forEach(user => {
        const option = document.createElement('option');
        option.value = user?.id;
        option.textContent = user?.name;
        document.querySelector('#user_selection')?.appendChild(option);
      });

    })
  }

  async getCardData() {
    var self = this;
    var data = await rpc('/get/appointment/tiles/data')

    self.state.total_appointment = data['total_appointment']
    self.state.draft_appointment_list = data['draft_appointment_list']
    self.state.confirm_appointment_list = data['confirm_appointment_list']
    self.state.done_appointment_list = data['done_appointment_list'],
      self.state.cancel_appointment_list = data['cancel_appointment_list'],
      self.state.user_name.value = data['user_name'],
      self.state.user_img.value = data['user_img']

  }
}

appointmentDashboard.template = "appointmentDashboard"
registry.category("actions").add("appointment_dashboard", appointmentDashboard)
