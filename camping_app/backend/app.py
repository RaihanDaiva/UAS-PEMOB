# Flask Backend - Quick Start Code Examples
# File: app.py (Main Flask Application)

from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from flask_cors import CORS
import bcrypt
from datetime import timedelta
import os

# Initialize Flask app
app = Flask(__name__)

# Configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/camping_booking_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = 'mysecret'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(days=7)

# Initialize extensions
db = SQLAlchemy(app)
jwt = JWTManager(app)
CORS(app)

# ============================================
# DATABASE MODELS
# ============================================

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(255), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    full_name = db.Column(db.String(255), nullable=False)
    phone_number = db.Column(db.String(20))
    role = db.Column(db.Enum('admin', 'client'), nullable=False, default='client')
    registration_status = db.Column(db.Enum('pending', 'approved', 'rejected'), 
                                   nullable=False, default='pending')
    address = db.Column(db.Text)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, server_default=db.func.current_timestamp())
    
    def to_dict(self):
        return {
            'id': self.id,
            'email': self.email,
            'full_name': self.full_name,
            'phone_number': self.phone_number,
            'role': self.role,
            'registration_status': self.registration_status,
            'address': self.address,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

class Campsite(db.Model):
    __tablename__ = 'campsites'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    location_name = db.Column(db.String(255), nullable=False)
    latitude = db.Column(db.Numeric(10, 8), nullable=False)
    longitude = db.Column(db.Numeric(11, 8), nullable=False)
    capacity = db.Column(db.Integer, nullable=False, default=50)
    price_per_night = db.Column(db.Numeric(10, 2), nullable=False)
    facilities = db.Column(db.Text)
    image_url = db.Column(db.String(500))
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, server_default=db.func.current_timestamp())
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'location_name': self.location_name,
            'latitude': float(self.latitude),
            'longitude': float(self.longitude),
            'capacity': self.capacity,
            'price_per_night': float(self.price_per_night),
            'facilities': self.facilities,
            'image_url': self.image_url,
            'is_active': self.is_active
        }

class Booking(db.Model):
    __tablename__ = 'bookings'
    
    id = db.Column(db.Integer, primary_key=True)
    booking_code = db.Column(db.String(20), unique=True, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    campsite_id = db.Column(db.Integer, db.ForeignKey('campsites.id'), nullable=False)
    check_in_date = db.Column(db.Date, nullable=False)
    check_out_date = db.Column(db.Date, nullable=False)
    num_people = db.Column(db.Integer, nullable=False)
    num_tents = db.Column(db.Integer, default=1)
    total_nights = db.Column(db.Integer, nullable=False)
    price_per_night = db.Column(db.Numeric(10, 2), nullable=False)
    subtotal = db.Column(db.Numeric(10, 2), nullable=False)
    tax_amount = db.Column(db.Numeric(10, 2), default=0.00)
    total_price = db.Column(db.Numeric(10, 2), nullable=False)
    booking_status = db.Column(db.Enum('pending', 'confirmed', 'cancelled', 'completed'), 
                              nullable=False, default='pending')
    special_requests = db.Column(db.Text)
    created_at = db.Column(db.DateTime, server_default=db.func.current_timestamp())
    
    # Relationships
    user = db.relationship('User', backref='bookings')
    campsite = db.relationship('Campsite', backref='bookings')
    
    def to_dict(self):
        return {
            'id': self.id,
            'booking_code': self.booking_code,
            'user_id': self.user_id,
            'campsite_id': self.campsite_id,
            'check_in_date': self.check_in_date.isoformat() if self.check_in_date else None,
            'check_out_date': self.check_out_date.isoformat() if self.check_out_date else None,
            'num_people': self.num_people,
            'num_tents': self.num_tents,
            'total_nights': self.total_nights,
            'price_per_night': float(self.price_per_night),
            'subtotal': float(self.subtotal),
            'tax_amount': float(self.tax_amount),
            'total_price': float(self.total_price),
            'booking_status': self.booking_status,
            'special_requests': self.special_requests,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

# ============================================
# AUTHENTICATION ROUTES
# ============================================

@app.route('/api/auth/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['email', 'password', 'full_name', 'phone_number']
        for field in required_fields:
            if field not in data:
                return jsonify({'success': False, 'message': f'{field} is required'}), 400
        
        # Check if user exists
        if User.query.filter_by(email=data['email']).first():
            return jsonify({'success': False, 'message': 'Email already registered'}), 400
        
        # Hash password
        password_hash = bcrypt.hashpw(data['password'].encode('utf-8'), bcrypt.gensalt())
        
        # Create new user
        new_user = User(
            email=data['email'],
            password_hash=password_hash.decode('utf-8'),
            full_name=data['full_name'],
            phone_number=data['phone_number'],
            address=data.get('address', ''),
            role='client',
            registration_status='pending'
        )
        
        db.session.add(new_user)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Registration successful. Waiting for admin approval.',
            'user_id': new_user.id
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/auth/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        # Validate required fields
        if 'email' not in data or 'password' not in data:
            return jsonify({'success': False, 'message': 'Email and password required'}), 400
        
        # Find user
        user = User.query.filter_by(email=data['email']).first()
        
        if not user:
            return jsonify({'success': False, 'message': 'Invalid email or password'}), 401
        
        # Check password
        if not bcrypt.checkpw(data['password'].encode('utf-8'), 
                             user.password_hash.encode('utf-8')):
            return jsonify({'success': False, 'message': 'Invalid email or password'}), 401
        
        # Check if user is approved
        if user.registration_status != 'approved':
            return jsonify({
                'success': False, 
                'message': 'Your account is pending approval'
            }), 403
        
        # Check if user is active
        if not user.is_active:
            return jsonify({'success': False, 'message': 'Account is deactivated'}), 403
        
        # Create access token
        access_token = create_access_token(identity=str(user.id))
        
        return jsonify({
            'success': True,
            'access_token': access_token,
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/auth/profile', methods=['GET'])
@jwt_required()
def get_profile():
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({'success': False, 'message': 'User not found'}), 404
        
        return jsonify({
            'success': True,
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# CAMPSITE ROUTES
# ============================================

@app.route('/api/campsites', methods=['GET'])
@jwt_required(optional=True)
def get_campsites():
    try:
        campsites = Campsite.query.filter_by(is_active=True).all()
        
        return jsonify({
            'success': True,
            'campsites': [campsite.to_dict() for campsite in campsites]
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/campsites/<int:campsite_id>', methods=['GET'])
@jwt_required()
def get_campsite_detail(campsite_id):
    try:
        campsite = Campsite.query.get(campsite_id)
        
        if not campsite:
            return jsonify({'success': False, 'message': 'Campsite not found'}), 404
        
        return jsonify({
            'success': True,
            'campsite': campsite.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# WEATHER ROUTES
# ============================================

import requests
from datetime import datetime, timedelta

@app.route('/api/weather/forecast', methods=['GET'])
@jwt_required()
def get_weather_forecast():
    try:
        campsite_id = request.args.get('campsite_id', type=int)
        days = request.args.get('days', default=7, type=int)
        
        if not campsite_id:
            return jsonify({'success': False, 'message': 'campsite_id is required'}), 400
        
        # Get campsite
        campsite = Campsite.query.get(campsite_id)
        if not campsite:
            return jsonify({'success': False, 'message': 'Campsite not found'}), 404
        
        # Call Open-Meteo API
        url = "https://api.open-meteo.com/v1/forecast"
        params = {
            'latitude': float(campsite.latitude),
            'longitude': float(campsite.longitude),
            'daily': 'temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max,weather_code',
            'hourly': 'temperature_2m',
            'timezone': 'auto',
            'past_days': 1,
            'forecast_days': days
        }
        
        response = requests.get(url, params=params)
        weather_data = response.json()
        
        # Process daily weather data
        daily_forecasts = []
        if 'daily' in weather_data:
            daily = weather_data['daily']
            for i in range(len(daily['time'])):
                forecast = {
                    'date': daily['time'][i],
                    'temperature_min': daily['temperature_2m_min'][i],
                    'temperature_max': daily['temperature_2m_max'][i],
                    'temperature_avg': (daily['temperature_2m_min'][i] + 
                                       daily['temperature_2m_max'][i]) / 2,
                    'precipitation_probability': daily.get('precipitation_probability_max', [0])[i] if i < len(daily.get('precipitation_probability_max', [])) else 0,
                    'wind_speed': daily.get('wind_speed_10m_max', [0])[i] if i < len(daily.get('wind_speed_10m_max', [])) else 0,
                    'weather_code': daily['weather_code'][i],
                    'weather_description': get_weather_description(daily['weather_code'][i])
                }
                
                # Calculate camping suitability
                forecast['camping_suitability'] = calculate_camping_suitability(forecast)
                forecast['recommendation'] = get_weather_recommendation(forecast)
                
                daily_forecasts.append(forecast)
        
        return jsonify({
            'success': True,
            'campsite': {
                'id': campsite.id,
                'name': campsite.name,
                'latitude': float(campsite.latitude),
                'longitude': float(campsite.longitude)
            },
            'weather': {
                'daily': daily_forecasts,
                'hourly': weather_data.get('hourly', {})
            },
            'api_source': 'Open-Meteo Weather API',
            'api_url': 'https://open-meteo.com',
            'cached': False
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

def get_weather_description(code):
    """Convert WMO weather code to description"""
    weather_codes = {
        0: "Clear sky",
        1: "Mainly clear",
        2: "Partly cloudy",
        3: "Overcast",
        45: "Foggy",
        48: "Depositing rime fog",
        51: "Light drizzle",
        53: "Moderate drizzle",
        55: "Dense drizzle",
        61: "Slight rain",
        63: "Moderate rain",
        65: "Heavy rain",
        71: "Slight snow",
        73: "Moderate snow",
        75: "Heavy snow",
        80: "Slight rain showers",
        81: "Moderate rain showers",
        82: "Violent rain showers",
        95: "Thunderstorm",
        96: "Thunderstorm with slight hail",
        99: "Thunderstorm with heavy hail"
    }
    return weather_codes.get(code, "Unknown")

def calculate_camping_suitability(forecast):
    """Calculate camping suitability score"""
    score = 100
    
    # Temperature check
    if forecast['temperature_max'] > 35 or forecast['temperature_min'] < 10:
        score -= 30
    
    # Precipitation check
    if forecast['precipitation_probability'] > 70:
        score -= 40
    elif forecast['precipitation_probability'] > 40:
        score -= 20
    
    # Wind check
    if forecast['wind_speed'] > 30:
        score -= 20
    
    if score >= 80:
        return "excellent"
    elif score >= 60:
        return "good"
    elif score >= 40:
        return "fair"
    else:
        return "poor"

def get_weather_recommendation(forecast):
    """Get camping recommendation based on weather"""
    if forecast['camping_suitability'] == 'excellent':
        return "Perfect weather for camping!"
    elif forecast['camping_suitability'] == 'good':
        return "Good camping conditions"
    elif forecast['camping_suitability'] == 'fair':
        if forecast['precipitation_probability'] > 40:
            return "Pack rain gear and waterproof equipment"
        else:
            return "Camping possible with proper preparation"
    else:
        return "Not recommended for camping. Consider rescheduling."

# ============================================
# BOOKING ROUTES
# ============================================

from datetime import date
import random
import string

def generate_booking_code():
    """Generate unique booking code"""
    date_str = datetime.now().strftime('%Y%m%d')
    random_str = ''.join(random.choices(string.digits, k=6))
    return f"BKG{date_str}{random_str}"

@app.route('/api/bookings', methods=['POST'])
@jwt_required()
def create_booking():
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['campsite_id', 'check_in_date', 'check_out_date', 'num_people']
        for field in required_fields:
            if field not in data:
                return jsonify({'success': False, 'message': f'{field} is required'}), 400
        
        # Get campsite
        campsite = Campsite.query.get(data['campsite_id'])
        if not campsite:
            return jsonify({'success': False, 'message': 'Campsite not found'}), 404
        
        # Parse dates
        check_in = datetime.strptime(data['check_in_date'], '%Y-%m-%d').date()
        check_out = datetime.strptime(data['check_out_date'], '%Y-%m-%d').date()
        
        # Validate dates
        if check_in >= check_out:
            return jsonify({
                'success': False, 
                'message': 'Check-out date must be after check-in date'
            }), 400
        
        if check_in < date.today():
            return jsonify({
                'success': False, 
                'message': 'Check-in date cannot be in the past'
            }), 400
        
        # Calculate prices
        total_nights = (check_out - check_in).days
        price_per_night = float(campsite.price_per_night)
        subtotal = price_per_night * total_nights
        tax_amount = subtotal * 0.10
        total_price = subtotal + tax_amount
        
        # Create booking
        booking_code = generate_booking_code()
        
        new_booking = Booking(
            booking_code=booking_code,
            user_id=user_id,
            campsite_id=data['campsite_id'],
            check_in_date=check_in,
            check_out_date=check_out,
            num_people=data['num_people'],
            num_tents=data.get('num_tents', 1),
            total_nights=total_nights,
            price_per_night=price_per_night,
            subtotal=subtotal,
            tax_amount=tax_amount,
            total_price=total_price,
            booking_status='pending',
            special_requests=data.get('special_requests', '')
        )
        
        db.session.add(new_booking)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Booking created successfully',
            'booking': new_booking.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/bookings/my-bookings', methods=['GET'])
@jwt_required()
def get_my_bookings():
    try:
        user_id = get_jwt_identity()
        
        bookings = Booking.query.filter_by(user_id=user_id)\
                                .order_by(Booking.created_at.desc())\
                                .all()
        
        result = []
        for booking in bookings:
            booking_dict = booking.to_dict()
            booking_dict['campsite_name'] = booking.campsite.name
            result.append(booking_dict)
        
        return jsonify({
            'success': True,
            'bookings': result
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# ADMIN ROUTES
# ============================================

@app.route('/api/admin/users/pending', methods=['GET'])
@jwt_required()
def get_pending_users():
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        # Check if user is admin
        if user.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403
        
        pending_users = User.query.filter_by(registration_status='pending')\
                                  .order_by(User.created_at.asc())\
                                  .all()
        
        result = []
        for pending_user in pending_users:
            user_dict = pending_user.to_dict()
            # Calculate days pending
            days_pending = (datetime.now() - pending_user.created_at).days
            user_dict['days_pending'] = days_pending
            result.append(user_dict)
        
        return jsonify({
            'success': True,
            'pending_users': result
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/admin/users/<int:target_user_id>/approval', methods=['PUT'])
@jwt_required()
def approve_reject_user(target_user_id):
    try:
        user_id = get_jwt_identity()
        admin = User.query.get(user_id)
        
        # Check if user is admin
        if admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403
        
        target_user = User.query.get(target_user_id)
        if not target_user:
            return jsonify({'success': False, 'message': 'User not found'}), 404
        
        data = request.get_json()
        action = data.get('action')  # 'approve' or 'reject'
        
        if action not in ['approve', 'reject']:
            return jsonify({'success': False, 'message': 'Invalid action'}), 400
        
        if action == 'approve':
            target_user.registration_status = 'approved'
            message = 'User approved successfully'
        else:
            target_user.registration_status = 'rejected'
            message = 'User rejected'
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': message
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# MAIN
# ============================================

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, host='0.0.0.0', port=5000)
