#from distutils.command.install import value
import pytz

from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Appointment(models.Model):
    _name = 'appointment.appointment'
    _description = 'Appointment'
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _rec_name = 'name'
    _order = "name desc"

    _tzs = [(tz, tz) for tz in sorted(pytz.all_timezones, key=lambda tz: tz if not tz.startswith('Etc/') else '_')]
    def _tz_get(self):
        return _tzs


    name = fields.Char("Name")
    is_user = fields.Boolean("Is user?")
    user_ids = fields.Many2many(
        comodel_name='res.users',
        relation='appointment_user_rel',
        column1='appointment_id',
        column2='user_id',
        string="Users"
    )
    description = fields.Char("Description")
    image_1920 = fields.Image("Image")
    location = fields.Char("Location")
    fees = fields.Float("Fees")
    appointment_type = fields.Selection([
        ('online', 'Online'), ('offline', 'Offline')
    ], default='online', string='Appointment Type')
    user_tz_id = fields.Many2one('')
    user_timezone = fields.Char(
        string='User Timezone',
        default=lambda self: self.env.user.tz or 'UTC'
    )
    time_slot_ids = fields.One2many('time.slot', 'service_id', string='Generated Slots')
    time_slot_line_ids = fields.One2many('time.slot.line', 'service_id', string='Slots')
    slot_duration = fields.Integer('Slot Duration', help="Enter slot duration in minutes")
    start_time = fields.Float(string='Start Time', required=True)
    end_time = fields.Float(string='End Time', required=True)
    time_slot_id = fields.Many2one('time.slot')
    buffer_time = fields.Integer('Buffer Time',  help="Enter buffer time in minutes")
    mon = fields.Boolean(readonly=False)
    tue = fields.Boolean(readonly=False)
    wed = fields.Boolean(readonly=False)
    thu = fields.Boolean(readonly=False)
    fri = fields.Boolean(readonly=False)
    sat = fields.Boolean(readonly=False)
    sun = fields.Boolean(readonly=False)
    tz = fields.Selection(_tzs, string='Timezone', default=lambda self: self._context.get('tz'),
                          help="When printing documents and exporting/importing data, time values are computed according to this timezone.\n"
                               "If the timezone is not set, UTC (Coordinated Universal Time) is used.\n"
                               "Anywhere else, time values are computed according to the time offset of your web client.")


    @api.constrains('start_time', 'end_time')
    def _check_times(self):
        for record in self:
            if record.start_time and record.end_time and record.end_time <= record.start_time:
                raise ValidationError("End Time must be greater than Start Time.")

    def action_generate_slots_appointment(self):
        if not self.start_time or not self.end_time:
            raise ValidationError("Please provide both Start Time and End Time before generating slots.")
        if not self.slot_duration:
            raise ValidationError("Please set a Slot Duration before generating slots.")
        self.ensure_one()
        weekday_map = {
            'mon': self.mon,
            'tue': self.tue,
            'wed': self.wed,
            'thu': self.thu,
            'fri': self.fri,
            'sat': self.sat,
            'sun': self.sun,
        }

        for day_code, is_selected in weekday_map.items():
            if is_selected:
                values = {
                    'day': day_code,
                    'start_time': self.start_time,
                    'end_time': self.end_time,
                    'service_id': self.id,
                    'slot_duration': self.slot_duration,
                    'user_ids': self.user_ids,
                }
                time_slot = self.env['time.slot'].create(values)
                time_slot.action_generate_slots()

    def update_user(self):
        for line in self.time_slot_line_ids:
            line.write({'user_ids': [(6, 0, self.user_ids.ids)]})


