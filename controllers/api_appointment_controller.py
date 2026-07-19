# -*- coding: utf-8 -*-
from odoo import http, _
from odoo.http import request
import json
import logging
from datetime import datetime, timedelta
import base64
import odoo
from odoo.modules.registry import Registry

_logger = logging.getLogger(__name__)


class AppointmentAPIController(http.Controller):
    """
    JSON API Controller for Flutter Mobile App - Version 1
    All endpoints return JSON responses
    """

    def _check_authentication(self):
        """Verify user is authenticated"""
        if not request.env.user or request.env.user._is_public():
            return {
                'success': False,
                'error': 'Authentication required',
                'error_code': 'AUTH_REQUIRED'
            }
        return {'success': True}

    def _response(self, success=True, data=None, message=None, error=None, error_code=None):
        """Standard JSON response format"""
        response = {'success': success}
        if data is not None:
            response['data'] = data
        if message:
            response['message'] = message
        if error:
            response['error'] = error
        if error_code:
            response['error_code'] = error_code
        return response

    # ==================== AUTHENTICATION ====================

    @http.route('/api/v1/auth/login', type='json', auth='none', methods=['POST'], csrf=False)
    def api_login(self, **kwargs):
        """
        Login endpoint for Flutter app
        Expected params: login, password, db
        """
        try:
            _logger.info(f"Login request params: {kwargs}")
            login = kwargs.get('login')
            password = kwargs.get('password')
            db = kwargs.get('db')

            if not login or not password:
                return self._response(
                    success=False,
                    error='Login and password are required',
                    error_code='MISSING_CREDENTIALS'
                )

            # Get database name if not provided
            if not db:
                from odoo.service.db import list_dbs
                db_list = list_dbs(force=True)
                if len(db_list) == 1:
                    db = db_list[0]
                else:
                    return self._response(
                        success=False,
                        error='Database name is required',
                        error_code='DB_REQUIRED'
                    )

            try:
                # Use Odoo's standard authentication
                request.session.authenticate(db, login, password)

                # Get session info like the standard endpoint
                session_info = request.env['ir.http'].session_info()

                if session_info.get('uid'):
                    user = request.env['res.users'].browse(session_info['uid'])

                    # Get user details
                    user_data = {
                        'id': user.id,
                        'name': user.name,
                        'email': user.email,
                        'login': user.login,
                        'partner_id': user.partner_id.id,
                        'company_id': user.company_id.id,
                        'company_name': user.company_id.name,
                        'timezone': user.tz or 'UTC',
                        'session_id': request.session.sid,
                        'db': db,
                        'session_info': session_info,  # Include full session info
                    }

                    return self._response(
                        success=True,
                        data=user_data,
                        message='Login successful'
                    )
                else:
                    return self._response(
                        success=False,
                        error='Invalid credentials',
                        error_code='INVALID_CREDENTIALS'
                    )

            except Exception as auth_error:
                _logger.error(f"Authentication failed: {str(auth_error)}")
                return self._response(
                    success=False,
                    error='Invalid credentials',
                    error_code='INVALID_CREDENTIALS'
                )

        except Exception as e:
            _logger.error(f"Login error: {str(e)}")
            return self._response(
                success=False,
                error=str(e),
                error_code='LOGIN_ERROR'
            )

    @http.route('/api/v1/auth/signup', type='json', auth='none', methods=['POST'], csrf=False)
    def api_signup(self, **kwargs):
        """
        Signup endpoint for new portal users
        Expected params: name, email, password, phone, db
        """
        try:
            name = kwargs.get('name')
            email = kwargs.get('email')
            password = kwargs.get('password')
            phone = kwargs.get('phone')
            db = kwargs.get('db')

            if not all([name, email, password]):
                return self._response(
                    success=False,
                    error='Name, email and password are required',
                    error_code='MISSING_FIELDS'
                )

            # Get database name if not provided
            if not db:
                from odoo.service.db import list_dbs
                db_list = list_dbs(force=True)
                if len(db_list) == 1:
                    db = db_list[0]
                else:
                    return self._response(
                        success=False,
                        error='Database name is required',
                        error_code='DB_REQUIRED'
                    )

            reg = Registry(db)
            # Create environment with superuser
            with reg.cursor() as cr:
                env = odoo.api.Environment(cr, odoo.SUPERUSER_ID, {})

                # Check if user already exists
                existing_user = env['res.users'].search([('login', '=', email)], limit=1)
                if existing_user:
                    return self._response(
                        success=False,
                        error='User with this email already exists',
                        error_code='USER_EXISTS'
                    )

                # Create partner
                partner_vals = {
                    'name': name,
                    'email': email,
                    'phone': phone,
                }
                partner = env['res.partner'].create(partner_vals)

                # Get portal group
                portal_group = env.ref('base.group_portal')

                # Create portal user
                user_vals = {
                    'name': name,
                    'login': email,
                    'email': email,
                    'partner_id': partner.id,
                    'groups_id': [(6, 0, [portal_group.id])],
                }
                user = env['res.users'].create(user_vals)

                # Set password
                user.write({'password': password})

                # Commit the transaction
                cr.commit()

                _logger.info(f"✅ User created successfully: {email}")

                return self._response(
                    success=True,
                    data={'user_id': user.id, 'email': email, 'db': db},
                    message='Signup successful. Please login.'
                )

        except Exception as e:
            _logger.error(f"Signup error: {str(e)}")
            import traceback
            _logger.error(traceback.format_exc())
            return self._response(
                success=False,
                error=str(e),
                error_code='SIGNUP_ERROR'
            )

    @http.route('/api/v1/auth/logout', type='json', auth='user', methods=['POST'], csrf=False)
    def api_logout(self):
        """Logout endpoint"""
        try:
            request.session.logout()
            return self._response(success=True, message='Logout successful')
        except Exception as e:
            _logger.error(f"Logout error: {str(e)}")
            return self._response(success=False, error=str(e))

    @http.route('/api/v1/auth/check', type='json', auth='user', methods=['POST'], csrf=False)
    def api_check_auth(self):
        """Check if user is authenticated"""
        try:
            session_info = request.env['ir.http'].session_info()

            if session_info.get('uid'):
                user = request.env.user
                return self._response(
                    success=True,
                    data={
                        'authenticated': True,
                        'user_id': user.id,
                        'name': user.name,
                        'email': user.email,
                        'session_info': session_info
                    }
                )
            return self._response(success=False, data={'authenticated': False})
        except Exception as e:
            return self._response(success=False, error=str(e))

    # ==================== COMPANY SETTINGS ====================

    @http.route('/api/v1/company/settings', type='json', auth='public', methods=['POST'], csrf=False)
    def api_company_settings(self):
        """Get company settings including logo"""
        try:
            company = request.env['res.company'].sudo().search([], limit=1)

            if not company:
                return self._response(
                    success=False,
                    error='Company not found',
                    error_code='COMPANY_NOT_FOUND'
                )

            logo_base64 = None
            if company.logo:
                logo_base64 = base64.b64encode(company.logo).decode('utf-8')

            company_data = {
                'id': company.id,
                'name': company.name,
                'email': company.email,
                'phone': company.phone,
                'website': company.website,
                'street': company.street,
                'street2': company.street2,
                'city': company.city,
                'state': company.state_id.name if company.state_id else None,
                'zip': company.zip,
                'country': company.country_id.name if company.country_id else None,
                'logo': logo_base64,
                'currency': company.currency_id.name if company.currency_id else None,
                'currency_symbol': company.currency_id.symbol if company.currency_id else None,
            }

            return self._response(success=True, data=company_data)

        except Exception as e:
            _logger.error(f"Company settings error: {str(e)}")
            return self._response(success=False, error=str(e))

    # ==================== APPOINTMENTS ====================

    @http.route('/api/v1/appointments/list', type='json', auth='public', methods=['POST'], csrf=False)
    def api_appointments_list(self):
        """Get list of all available appointments/services"""
        try:
            appointments = request.env['appointment.appointment'].sudo().search([])

            appointments_data = []
            for appt in appointments:
                image_base64 = None
                if appt.image_1920:
                    image_base64 = base64.b64encode(appt.image_1920).decode('utf-8')

                appointments_data.append({
                    'id': appt.id,
                    'name': appt.name,
                    'description': appt.description,
                    'location': appt.location,
                    'fees': appt.fees,
                    'appointment_type': appt.appointment_type,
                    'appointment_type_display': dict(appt._fields['appointment_type'].selection).get(
                        appt.appointment_type),
                    'slot_duration': appt.slot_duration,
                    'image': image_base64,
                    'user_ids': appt.user_ids.ids,
                    'users': [{'id': u.id, 'name': u.name} for u in appt.user_ids],
                })

            return self._response(success=True, data=appointments_data)

        except Exception as e:
            _logger.error(f"Appointments list error: {str(e)}")
            return self._response(success=False, error=str(e))

    @http.route('/api/v1/appointments/detail', type='json', auth='public', methods=['POST'], csrf=False)
    def api_appointment_detail(self, appointment_id=None, **kwargs):
        """Get detailed information about a specific appointment"""
        try:
            if not appointment_id:
                appointment_id = kwargs.get('appointment_id')

            if not appointment_id:
                return self._response(
                    success=False,
                    error='Appointment ID is required',
                    error_code='MISSING_ID'
                )

            appointment = request.env['appointment.appointment'].sudo().browse(int(appointment_id))

            if not appointment.exists():
                return self._response(
                    success=False,
                    error='Appointment not found',
                    error_code='NOT_FOUND'
                )

            image_base64 = None
            if appointment.image_1920:
                image_base64 = base64.b64encode(appointment.image_1920).decode('utf-8')

            appointment_data = {
                'id': appointment.id,
                'name': appointment.name,
                'description': appointment.description,
                'location': appointment.location,
                'fees': appointment.fees,
                'appointment_type': appointment.appointment_type,
                'appointment_type_display': dict(appointment._fields['appointment_type'].selection).get(
                    appointment.appointment_type),
                'slot_duration': appointment.slot_duration,
                'buffer_time': appointment.buffer_time,
                'image': image_base64,
                'users': [{'id': u.id, 'name': u.name, 'timezone': u.tz or 'UTC'} for u in appointment.user_ids],
            }

            return self._response(success=True, data=appointment_data)

        except Exception as e:
            _logger.error(f"Appointment detail error: {str(e)}")
            return self._response(success=False, error=str(e))

    @http.route('/api/v1/appointments/available-slots', type='json', auth='public', methods=['POST'], csrf=False)
    def api_available_slots(self, **kwargs):
        """
        Get available time slots for a specific date and appointment
        Expected params: appointment_id, selected_date, user_id (optional)
        """
        try:
            appointment_id = kwargs.get('appointment_id')
            selected_date = kwargs.get('selected_date')  # Format: YYYY-MM-DD
            user_id = kwargs.get('user_id')

            if not appointment_id or not selected_date:
                return self._response(
                    success=False,
                    error='Appointment ID and date are required',
                    error_code='MISSING_PARAMS'
                )

            # Parse date and get day of week
            date_obj = datetime.strptime(selected_date, '%Y-%m-%d')
            day_name = date_obj.strftime('%a').lower()  # mon, tue, wed, etc.

            # Build domain for time slot lines
            domain = [
                ('day', '=', day_name),
                ('service_id', '=', int(appointment_id))
            ]

            if user_id:
                domain.append(('user_ids', 'in', [int(user_id)]))

            time_slot_lines = request.env['time.slot.line'].sudo().search(domain)

            # Find booked slots for the selected date
            booked_events = request.env['calendar.event'].sudo().search([
                ('booking_date', '=', selected_date),
                ('time_slot_ids', '!=', False),
            ])

            booked_slot_ids = set()
            for event in booked_events:
                booked_slot_ids.update(event.time_slot_ids.ids)

            # Prepare slots data
            slots_data = []
            for slot in time_slot_lines:
                slots_data.append({
                    'id': slot.id,
                    'name': slot.name,
                    'day': slot.day,
                    'is_booked': slot.id in booked_slot_ids,
                    'user_ids': slot.user_ids.ids,
                })

            return self._response(success=True, data=slots_data)

        except Exception as e:
            _logger.error(f"Available slots error: {str(e)}")
            return self._response(success=False, error=str(e))

    @http.route('/api/v1/appointments/book', type='json', auth='user', methods=['POST'], csrf=False)
    def api_book_appointment(self, **kwargs):
        """
        Book an appointment
        Expected params: appointment_id, slot_id, selected_date, contact_name, email, mobile, description
        """
        try:
            # Extract parameters
            appointment_id = kwargs.get('appointment_id')
            slot_id = kwargs.get('slot_id')
            selected_date = kwargs.get('selected_date')
            contact_name = kwargs.get('contact_name')
            email = kwargs.get('email')
            mobile = kwargs.get('mobile')
            description = kwargs.get('description', '')
            user_id = kwargs.get('user_id')

            # Validate required fields
            if not all([appointment_id, slot_id, selected_date, contact_name, email, mobile]):
                return self._response(
                    success=False,
                    error='All fields are required',
                    error_code='MISSING_FIELDS'
                )

            # Get appointment and slot
            appointment = request.env['appointment.appointment'].sudo().browse(int(appointment_id))
            time_slot = request.env['time.slot.line'].sudo().browse(int(slot_id))

            if not appointment.exists() or not time_slot.exists():
                return self._response(
                    success=False,
                    error='Invalid appointment or time slot',
                    error_code='INVALID_DATA'
                )

            # Check if slot is already booked
            existing_booking = request.env['calendar.event'].sudo().search([
                ('booking_date', '=', selected_date),
                ('time_slot_ids', 'in', [int(slot_id)]),
            ], limit=1)

            if existing_booking:
                return self._response(
                    success=False,
                    error='This slot is already booked',
                    error_code='SLOT_BOOKED'
                )

            # Get or create partner
            partner = request.env['res.partner'].sudo().search([('email', '=', email)], limit=1)
            if not partner:
                partner = request.env['res.partner'].sudo().create({
                    'name': contact_name,
                    'email': email,
                    'phone': mobile,
                })

            # Parse slot time and create datetime
            date_obj = datetime.strptime(selected_date, '%Y-%m-%d')

            # Extract start and end time from slot name (format: "HH:MM – HH:MM")
            import re
            slot_times = re.split(r'\s*[-–—]\s*', time_slot.name.strip())

            if len(slot_times) == 2:
                start_time_str = slot_times[0].strip()
                end_time_str = slot_times[1].strip()

                start_datetime = datetime.strptime(f"{selected_date} {start_time_str}", "%Y-%m-%d %H:%M")
                end_datetime = datetime.strptime(f"{selected_date} {end_time_str}", "%Y-%m-%d %H:%M")
            else:
                # Default times if parsing fails
                start_datetime = date_obj.replace(hour=9, minute=0)
                end_datetime = date_obj.replace(hour=10, minute=0)

            # Create calendar event
            event_vals = {
                'name': contact_name,
                'description': description,
                'mobile_number': mobile,
                'email': email,
                'partner_id': partner.id,
                'appointment_id': appointment.id,
                'booking_date': selected_date,
                'fess_fees': appointment.fees,
                'time_slot_ids': [(6, 0, [time_slot.id])],
                'start': start_datetime,
                'stop': end_datetime,
                'state': 'draft',
            }

            if user_id:
                event_vals['user_id'] = int(user_id)

            event = request.env['calendar.event'].sudo().create(event_vals)

            return self._response(
                success=True,
                data={
                    'event_id': event.id,
                    'reference_number': event.name,
                },
                message='Appointment booked successfully'
            )

        except Exception as e:
            _logger.error(f"Book appointment error: {str(e)}")
            return self._response(success=False, error=str(e))

    # my booking list
    @http.route('/api/v1/appointments/my-bookings', type='json', auth='user', methods=['POST'], csrf=False)
    def api_my_bookings(self, **kwargs):
        """
        Get all bookings for the logged-in user
        Now searches by BOTH partner_id AND email to include web bookings
        """
        try:
            user = request.env.user
            partner = user.partner_id
            email = user.email

            _logger.info(f"📧 Fetching bookings - Email: {email}, Partner ID: {partner.id}")

            # Build domain to search by BOTH partner_id and email
            # 1. Appointments booked in the app (linked to partner_id)
            # 2. Appointments booked on website (might have different partner but same email)
            domain = [
                '|',
                ('partner_id', '=', partner.id),  # App bookings
                ('email', '=', email)  # Web bookings
            ]

            events = request.env['calendar.event'].sudo().search(
                domain,
                order='booking_date desc'
            )

            _logger.info(f"✅ Found {len(events)} appointments")

            bookings_data = []
            for event in events:
                slot_names = ', '.join(event.time_slot_ids.mapped('name'))

                bookings_data.append({
                    'id': event.id,
                    'name': event.name,
                    'booking_date': event.booking_date.strftime('%Y-%m-%d') if event.booking_date else None,
                    'time_slots': slot_names,
                    'appointment_name': event.appointment_id.name if event.appointment_id else None,
                    'appointment_location': event.appointment_id.location if event.appointment_id else None,
                    'fees': event.fess_fees,
                    'state': event.state,
                    'state_display': dict(event._fields['state'].selection).get(event.state),
                    'start': event.start.strftime('%Y-%m-%d %H:%M:%S') if event.start else None,
                    'stop': event.stop.strftime('%Y-%m-%d %H:%M:%S') if event.stop else None,
                    'partner_id': event.partner_id.id if event.partner_id else None,
                    'email': event.email,
                    'source': 'web' if event.partner_id.id != partner.id else 'app',  # Track source
                })

            return self._response(success=True, data=bookings_data)

        except Exception as e:
            _logger.error(f"❌ My bookings error: {str(e)}")
            import traceback
            _logger.error(traceback.format_exc())
            return self._response(success=False, error=str(e))

    @http.route('/api/v1/appointments/cancel', type='json', auth='user', methods=['POST'], csrf=False)
    def api_cancel_appointment(self, event_id=None, **kwargs):
        """Cancel an appointment"""
        try:
            if not event_id:
                event_id = kwargs.get('event_id')

            if not event_id:
                return self._response(
                    success=False,
                    error='Event ID is required',
                    error_code='MISSING_ID'
                )

            event = request.env['calendar.event'].sudo().browse(int(event_id))

            if not event.exists():
                return self._response(
                    success=False,
                    error='Appointment not found',
                    error_code='NOT_FOUND'
                )

            # Check if user owns this appointment
            user = request.env.user
            if event.partner_id.id != user.partner_id.id:
                return self._response(
                    success=False,
                    error='Unauthorized',
                    error_code='UNAUTHORIZED'
                )

            event.action_cancel()

            return self._response(
                success=True,
                message='Appointment cancelled successfully'
            )

        except Exception as e:
            _logger.error(f"Cancel appointment error: {str(e)}")
            return self._response(success=False, error=str(e))

    # ==================== PORTAL ACCESS ====================

    @http.route('/api/v1/portal/orders', type='json', auth='user', methods=['POST'], csrf=False)
    def api_portal_orders(self, **kwargs):
        """Get user's orders"""
        try:
            user = request.env.user
            partner = user.partner_id

            limit = kwargs.get('limit', 20)
            offset = kwargs.get('offset', 0)

            orders = request.env['sale.order'].sudo().search([
                ('partner_id', 'child_of', [partner.commercial_partner_id.id])
            ], limit=limit, offset=offset, order='date_order desc')

            orders_data = []
            for order in orders:
                orders_data.append({
                    'id': order.id,
                    'name': order.name,
                    'date_order': order.date_order.strftime('%Y-%m-%d') if order.date_order else None,
                    'state': order.state,
                    'state_display': dict(order._fields['state'].selection).get(order.state),
                    'amount_total': order.amount_total,
                    'currency_symbol': order.currency_id.symbol if order.currency_id else None,
                })

            total_count = request.env['sale.order'].sudo().search_count([
                ('partner_id', 'child_of', [partner.commercial_partner_id.id])
            ])

            return self._response(
                success=True,
                data={
                    'orders': orders_data,
                    'total_count': total_count,
                    'limit': limit,
                    'offset': offset
                }
            )

        except Exception as e:
            _logger.error(f"Portal orders error: {str(e)}")
            return self._response(success=False, error=str(e))

    @http.route('/api/v1/portal/invoices', type='json', auth='user', methods=['POST'], csrf=False)
    def api_portal_invoices(self, **kwargs):
        """Get user's invoices"""
        try:
            user = request.env.user
            partner = user.partner_id

            limit = kwargs.get('limit', 20)
            offset = kwargs.get('offset', 0)

            invoices = request.env['account.move'].sudo().search([
                ('partner_id', 'child_of', [partner.commercial_partner_id.id]),
                ('move_type', 'in', ['out_invoice', 'out_refund'])
            ], limit=limit, offset=offset, order='invoice_date desc')

            invoices_data = []
            for invoice in invoices:
                invoices_data.append({
                    'id': invoice.id,
                    'name': invoice.name,
                    'invoice_date': invoice.invoice_date.strftime('%Y-%m-%d') if invoice.invoice_date else None,
                    'state': invoice.state,
                    'state_display': dict(invoice._fields['state'].selection).get(invoice.state),
                    'amount_total': invoice.amount_total,
                    'amount_residual': invoice.amount_residual,
                    'currency_symbol': invoice.currency_id.symbol if invoice.currency_id else None,
                    'payment_state': invoice.payment_state,
                })

            total_count = request.env['account.move'].sudo().search_count([
                ('partner_id', 'child_of', [partner.commercial_partner_id.id]),
                ('move_type', 'in', ['out_invoice', 'out_refund'])
            ])

            return self._response(
                success=True,
                data={
                    'invoices': invoices_data,
                    'total_count': total_count,
                    'limit': limit,
                    'offset': offset
                }
            )

        except Exception as e:
            _logger.error(f"Portal invoices error: {str(e)}")
            return self._response(success=False, error=str(e))

    @http.route('/api/v1/portal/profile', type='json', auth='user', methods=['POST'], csrf=False)
    def api_portal_profile(self):
        """Get user profile information"""
        try:
            user = request.env.user
            partner = user.partner_id

            profile_data = {
                'id': user.id,
                'name': user.name,
                'email': user.email,
                'phone': partner.phone,
                'mobile': partner.mobile,
                'street': partner.street,
                'street2': partner.street2,
                'city': partner.city,
                'state': partner.state_id.name if partner.state_id else None,
                'zip': partner.zip,
                'country': partner.country_id.name if partner.country_id else None,
            }

            return self._response(success=True, data=profile_data)

        except Exception as e:
            _logger.error(f"Portal profile error: {str(e)}")
            return self._response(success=False, error=str(e))

    @http.route('/api/v1/portal/update-profile', type='json', auth='user', methods=['POST'], csrf=False)
    def api_update_profile(self, **kwargs):
        """Update user profile"""
        try:
            user = request.env.user
            partner = user.partner_id

            # Update allowed fields
            update_vals = {}
            if 'name' in kwargs:
                update_vals['name'] = kwargs['name']
            if 'phone' in kwargs:
                update_vals['phone'] = kwargs['phone']
            if 'mobile' in kwargs:
                update_vals['mobile'] = kwargs['mobile']
            if 'street' in kwargs:
                update_vals['street'] = kwargs['street']
            if 'street2' in kwargs:
                update_vals['street2'] = kwargs['street2']
            if 'city' in kwargs:
                update_vals['city'] = kwargs['city']
            if 'zip' in kwargs:
                update_vals['zip'] = kwargs['zip']

            if update_vals:
                partner.sudo().write(update_vals)

                # Update user name if provided
                if 'name' in update_vals:
                    user.sudo().write({'name': update_vals['name']})

            return self._response(
                success=True,
                message='Profile updated successfully'
            )

        except Exception as e:
            _logger.error(f"Update profile error: {str(e)}")
            return self._response(success=False, error=str(e))
