# -*- coding: utf-8 -*-
##############################################################################
#
#    OpenERP, Open Source Management Solution
#    Copyright (C) 2015 DevIntelle Consulting Service Pvt.Ltd (<http://www.devintellecs.com>).
#
#    For Module Support : devintelle@gmail.com  or Skype : devintelle 
#
##############################################################################

{
    'name': 'Appointment Management | Appointment Website',
    'version': '18.0.1.0',
    'sequence': 1,
    'category': 'Generic Modules/Discuss',
    'description': """
    	Appointment Management | Appointment Website
    	Appointment Management Appointment Website Appointment Form Create Meeting from Website Book Appointment Slots Management User wise appointment service wise appointment service appointment
    """,
    'summary' : "Appointment Management Appointment Website Appointment Form Create Meeting from Website Book Appointment Slots Management User wise appointment service wise appointment service appointment Online Appointment Booking Appointment Scheduling Booking System Consultation Booking App Appointment Calendar Service Booking Customer Appointment Time Slot Management Salon Booking System Healthcare Booking System",
    'depends': ['website','hr', 'calendar', 'portal'],
    'data': [
        'data/mail_template.xml',
        'security/ir.model.access.csv',
        'views/root_menu.xml',
        'views/appointment_appointment.xml',
        'views/minutes_of_meetings.xml',
        'views/time_slot_view.xml',
        'portal_view/website_menu.xml',
        'portal_view/appointment_request_view.xml',
        'views/dashboard_menu.xml',

    ],
    'assets': {
        'web.assets_frontend': [
            'dev_appointment/static/src/js/CalendarView.js',
            'dev_appointment/static/src/img/k.png',
        ],
        'web.assets_backend': [
       'dev_appointment/static/src/css/dashboard_new.css',
       'dev_appointment/static/src/js/appointment_dashboard.js',
       'dev_appointment/static/src/xml/appointment_dashboard.xml',
       'dev_appointment/static/src/js/chart_chart.js'
       
   ],
    },
    'demo': [],
    'test': [],
    'css': [],
    'qweb': [],
    'js': [],
    'images': ['images/main_screenshot.gif'],
    'installable': True,
    'application': True,
    'auto_install': False,
    
    #author and support Details
    'author': 'DevIntelle Consulting Service Pvt.Ltd',
    'website': 'https://www.devintellecs.com',    
    'maintainer': 'DevIntelle Consulting Service Pvt.Ltd', 
    'support': 'devintelle@gmail.com',
    'price':39.0,
    'currency':'EUR',
    #'live_test_url':'https://youtu.be/A5kEBboAh_k',
}
