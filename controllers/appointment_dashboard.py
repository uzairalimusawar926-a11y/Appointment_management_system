import datetime
from odoo import http
from odoo.http import request
from odoo import models, fields, api, _
from operator import itemgetter
import itertools
import operator
from datetime import date, timedelta
from collections import defaultdict
import calendar
from itertools import chain
from datetime import datetime, timedelta, date

class ProjectFilter(http.Controller):
    """The ProjectFilter class provides the filter option to the js.
    When applying the filter returns the corresponding data."""



    @http.route('/appointment/all_filter', auth='public', type='json')
    def all_filter(self):
        user_list =[]
        user_ids = request.env['res.users'].search([])
        for user_id in user_ids:
            dic = {'name': user_id.name,
                   'id': user_id.id}
            user_list.append(dic)

        
        return [user_list]

    @http.route('/get/appointment/tiles/data', auth='public', type='json')
    def get_appointment_tiles_data(self, **kwargs):
        today = date.today()
        appointment_domain =[]

        if not kwargs.get('duration'):
            appointment_domain += [('start', '>=', today),('start', '<=', today)]

        if kwargs:

            if kwargs['user_id']:
                if kwargs['user_id'] != 'all':
                    user_id = int(kwargs['user_id'])
                    appointment_domain += [('user_id', '=', user_id)]
                    

            if kwargs['duration']:
                duration = kwargs['duration']
                if duration != "all":
                    duration = int(duration)
                    filter_date = today - timedelta(days=duration)
                    appointment_domain += [('start', '>=', filter_date), ('start', '<=', today)]
                      
        draft_appointment_list =[]
        confirm_appointment_list=[]
        done_appointment_list = []
        cancel_appointment_list = []
        total_appointment = request.env['calendar.event'].search([]+appointment_domain)
        for appointment in total_appointment:
            if appointment.state == 'draft':
                draft_appointment_list.append(appointment.id)
            if appointment.state == 'confirm':
                confirm_appointment_list.append(appointment.id)
            if appointment.state == 'done':
                done_appointment_list.append(appointment.id)
            if appointment.state == 'cancel':
                cancel_appointment_list.append(appointment.id)
                
       
        user_name = request.env.user.name
        user_img = request.env.user.image_1920  

        return {
            'total_appointment':total_appointment.ids,
            'draft_appointment_list':draft_appointment_list,
            'confirm_appointment_list':confirm_appointment_list,
            'done_appointment_list':done_appointment_list,
            'cancel_appointment_list':cancel_appointment_list,
            'user_img': user_img,
            'user_name': user_name,

        }
    
# Month Wise appoitment
    @http.route('/month_wise/appointment/chart/data', auth='public', type='json')
    def get_appointment_chart_data(self, **kw):
        appointment_domain = []
        data = kw.get('data', {})

        if data:
            if data.get('user_id') and data['user_id'] != 'all':
                user_id = int(data['user_id'])
                appointment_domain += [('user_id', '=', user_id)]


        current_year = date.today().year
        appointment_domain += [
            ('start', '>=', f'{current_year}-01-01'),
            ('start', '<=', f'{current_year}-12-31'),
        ]

        # Prepare month labels and default structure
        monthly_labels = []
        monthly_counts = []
        monthly_appointments = []

        month_map = {
            datetime(current_year, m, 1).strftime('%b %Y'): []
            for m in range(1, 13)
        }

        # Fetch appointments
        appointments = request.env['calendar.event'].search_read(
            appointment_domain, fields=['id', 'start'], order='start asc'
        )

        for appt in appointments:
            start_date = appt.get('start')
            if start_date:
                if isinstance(start_date, str):
                    start_date = datetime.strptime(start_date, '%Y-%m-%d %H:%M:%S')
                if start_date.year == current_year:
                    label = start_date.strftime('%b %Y')
                    if label in month_map:
                        month_map[label].append(appt['id'])

        # Now prepare final structure
        for label in month_map:
            monthly_labels.append(label)
            monthly_counts.append(len(month_map[label]))
            monthly_appointments.append(month_map[label])

        chart_data = {
            'labels': monthly_labels,
            'datasets': [{
                'label': "Appointments",
                'backgroundColor': ['#eaebfa','#d2d5f5','#c1c4f1','#979de8','#6d75de','#444ed5','#2a34bb','#171d68','#171d68','#0e113e','#0a0c2d','#0a0c2d'],
                'borderRadius': 5,
                'data': monthly_counts,
                'detail': monthly_appointments,

            }]
        }
        return {
            'appointment_chart_data': chart_data,
        }

#  Top Demanaded service chart
    @http.route('/top/demanded/service/chart/data', auth='public', type='json')
    def get_top_demanded_services_chart_data(self, **kw):
        data=kw['data']
        # top_demanded_service_count=data['top_demanded_service_count'] or '5'
        top_demanded_service_count = int(data.get('top_demanded_service_count', 10))

        service_appointment_domain = []
        
        today = date.today()
        
        if not data.get('duration'):
            service_appointment_domain = [('start', '>=', today ),('start', '<=', today )]
        if data:
            if data['user_id']:
                if data['user_id'] != 'all':
                    user_id = int(data['user_id'])
                    service_appointment_domain += [('user_id','=',user_id)]

            if data['duration']:
                duration = data['duration']
                if duration != "all":
                    duration = int(duration)
                    filter_date = today - timedelta(days=duration)
                    service_appointment_domain += [('start', '>=', filter_date), ('start', '<=', today)]


        events = request.env['calendar.event'].sudo().search_read(
            [('appointment_id', '!=', False)]+service_appointment_domain,
            ['id', 'appointment_id'], order='start asc'
        )

        appointment_event_map = defaultdict(list)  
        appointment_count = defaultdict(int)

        for ev in events:
            appointment = ev.get('appointment_id')
            if appointment:
                appointment_id = appointment[0]
                appointment_name = appointment[1]
                appointment_event_map[appointment_name].append(ev['id'])
                appointment_count[appointment_name] += 1

        labels = list(appointment_count.keys())
        counts = [appointment_count[appt] for appt in labels][:int(top_demanded_service_count)]
        details = [appointment_event_map[appt] for appt in labels]

        chart_data = {
            'labels': labels,
            'datasets': [{
                'label': 'Service Appointment',
                'backgroundColor':['#e3e9f5','#e3e9f5','#becbe7','#abbce0','#99add9','#869ed2','#748fcb','#6180c4','#4e71bd','#4265b1','#3b5a9e','#344f8b','#2d4579','#263a66','#1f3054','#182541','#111a2e','#0a101c','#030509'],
                'borderRadius': 5,
                'data': counts,
                'detail': details,
            }]
        }

        return {
            'top_demanded_service_chart_data': chart_data
        }


#  Top revanu by service 

    @http.route('/top/revenue/service/chart/data', auth='public', type='json')
    def get_top_revenue_by_service_chart_data(self, **kw):
        data = kw.get('data', {})
        top_service_limit = int(data.get('top_revenue_service_count', 10))
        service_domain = [('appointment_id', '!=', False)]

        today = date.today()

        # Filter by user
        if data.get('user_id') and data['user_id'] != 'all':
            service_domain.append(('user_id', '=', int(data['user_id'])))

        # Filter by duration (last N days)
        if data.get('duration') and data['duration'] != "all":
            days = int(data['duration'])
            from_date = today - timedelta(days=days)
            service_domain.append(('start', '>=', from_date))
            service_domain.append(('start', '<=', today))

        # Fetch relevant events
        events = request.env['calendar.event'].sudo().search_read(
            service_domain, ['id', 'appointment_id', 'fess_fees'], order='start asc'
        )

        # Group by service (appointment name) and calculate revenue
        service_revenue_map = defaultdict(float)  # {appointment_name: total_revenue}
        service_event_map = defaultdict(list)     # {appointment_name: [event_ids]}

        for ev in events:
            appointment = ev.get('appointment_id')
            fess_fees = ev.get('fess_fees', 0.0)
            if appointment:
                appointment_id = appointment[0]
                appointment_name = appointment[1]
                service_revenue_map[appointment_name] += fess_fees
                service_event_map[appointment_name].append(ev['id'])

        # Sort by total revenue descending
        sorted_services = sorted(service_revenue_map.items(), key=lambda x: x[1], reverse=True)[:top_service_limit]

        labels = [s[0] for s in sorted_services]
        revenues = [round(s[1], 2) for s in sorted_services]
        details = [service_event_map[s[0]] for s in sorted_services]

        chart_data = {
            'labels': labels,
            'datasets': [{
                'label': 'Total Revenue by Service',
                'backgroundColor':['#e3e9f5','#e3e9f5','#becbe7','#abbce0','#99add9','#869ed2','#748fcb','#6180c4','#4e71bd','#4265b1','#3b5a9e','#344f8b','#2d4579','#263a66','#1f3054','#182541','#111a2e','#0a101c','#030509'],
                'borderRadius': 5,
                'data': revenues,
                'detail': details,
            }]
        }
        return {
            'top_revenue_service_chart_data': chart_data
        }


    @http.route('/upcoming/appointment/list/data', auth='public', type='json')
    def get_upcoming_appointment_list_data(self, **kw):
        today = date.today()
        
        data = kw['data']
        upc_appointment_domain = []
        if data:
            if data['user_id']:
                user_id = data['user_id']
                if user_id != 'all':
                    user_id = int(user_id)
                    upc_appointment_domain += [('user_id', '=', user_id)]


        if data['upc_duration']:
            duration = data['upc_duration']
            if duration == '0':
                upc_appointment_domain += [('start', '>=', today),('start', '<=', today)]
            elif duration.isdigit():
                days = int(duration)
                future_date = today + timedelta(days=days)
                upc_appointment_domain += [('start', '>=', today), ('start', '<=', future_date)]
        all_upcoming_appointment = request.env['calendar.event'].search_read(upc_appointment_domain,
            fields=['name', 'start', 'appointment_id','state']
        )
        return {
            'all_upcoming_appointment_lst': all_upcoming_appointment
        }


    @http.route('/appointment/filter-apply', auth='public', type='json')
    def garage_filter_apply(self, **kw):
        data = kw['data']
        user_id = data['user']
        duration = data['duration']
        result = self.get_appointment_tiles_data(user_id=user_id,duration=duration)
        return result
