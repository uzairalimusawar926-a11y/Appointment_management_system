from odoo import api, models, fields
from datetime import datetime, timedelta
from odoo.tools import format_datetime

class CalendarEvent(models.Model):
    _inherit = 'calendar.event'

    state = fields.Selection([
        ('draft', 'Draft'),
        ('confirm', 'Confirmed'),
        ('done', 'Done'),
        ('cancel', 'Cancelled')
    ], default='draft', string="State")
    appointment_id = fields.Many2one('appointment.appointment', string='Appointment')
    booking_date = fields.Date(string='Booking Date')
    fess_fees = fields.Float(string="Fees")
    time_slot_ids = fields.Many2many(
        'time.slot.line',
        'calendar_event_time_slot_rel',
        'event_id',
        'slot_id',
        string='Time Slots'
    )
    company_id = fields.Many2one('res.company', string='Company', default=lambda self: self.env.company, tracking=1,
                                 required=True)
    email = fields.Char('Email')
    mobile_number = fields.Char('Mobile Number')

    # def _get_calendar_data(self):
    #     res = super()._get_calendar_data()
    #     for r in res:
    #         # Add the service_ids with names
    #         r['service_ids'] = [{'id': s.id, 'name': s.name} for s in self.browse(r['id']).service_ids]
    #     return res


    def action_confirm(self):
        for record in self:
            template = self.env.ref('dev_appointment.appointment_confirmation_email_template_id')
            if template:
                template.send_mail(record.id, force_send=True)
            record.state = 'confirm'

    def action_cancel(self):
        for record in self:
            record.state = 'cancel'

    def action_done(self):
        for record in self:
            record.state = 'done'

    def action_reset_to_draft(self):
        for record in self:
            record.state = 'draft'

