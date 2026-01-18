# Flask Backend - Quick Start Code Examples
# File: app.py (Main Flask Application)

from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from flask_cors import CORS
import bcrypt
import requests
from datetime import datetime, timedelta
import os

# Initialize Flask app
app = Flask(__name__)

# Configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/camping_booking_db'
# Struktur: 'mysql+pymysql://{username}:{password}@{host}/{database_name}'

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
# 1. AUTHENTICATION ROUTES
# ============================================

# 1.1 Register new client user (registration status: pending)
@app.route('/api/auth/register', methods=['POST'])
# No jwt_required() or authentication needed since here for registration
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

# 1.2 Login for both Admin and Client
@app.route('/api/auth/login', methods=['POST'])
# No jwt_required() or authentication needed here since it's login
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
        access_token = create_access_token(
            identity=str(user.id),
            additional_claims={
                "role": user.role
            }
        )
        
        return jsonify({
            'success': True,
            'access_token': access_token,
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# 1.3 Get logged in user profile information [by user_id from JWT]
@app.route('/api/auth/profile', methods=['GET'])
@jwt_required() # Authentication required
def get_profile():
    try:
        # Read identity from JWT
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        total_trips = Booking.query.filter_by(user_id=user_id, booking_status='completed').count()
        upcoming_trips = (
            Booking.query
            .filter(
                Booking.user_id == user_id,
                Booking.booking_status.in_(["pending", "confirmed", "cancelled"])
            )
            .count()
        )
        
        if not user:
            return jsonify({'success': False, 'message': 'User not found'}), 404
        
        return jsonify({
            'success': True,
            'user': user.to_dict(),
            'total_trips': total_trips,
            'upcoming_trips': upcoming_trips
        }), 200
        
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# 2. CAMPSITE ROUTES
# ============================================

# 2.1 Get list of all active campsites (not active campsites are hidden)
@app.route('/api/campsites', methods=['GET'])
@jwt_required(optional=True) # Whether logged in or not, can access and will result the same output
def get_campsites():
    try:
        campsites = Campsite.query.filter_by(is_active=True).all() # Only active campsites
        return jsonify({
            'success': True,
            'campsites': [campsite.to_dict() for campsite in campsites]
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# 2.2 Get detailed information of a specific campsite [by campsite_id]
@app.route('/api/campsites/<int:campsite_id>', methods=['GET'])
@jwt_required(optional=True) # Whether logged in or not, can access and will result the same output
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

# 2.3 Create a new campsite (admin only)
@app.route('/api/admin/campsites', methods=['POST'])
@jwt_required() # Admin authentication required
def create_campsite():
    try:
        # Read identity from JWT
        user = User.query.get(get_jwt_identity())
        
        # Admin check
        if user.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403

        data = request.get_json()

        campsite = Campsite(
            name=data['name'],
            description=data.get('description'),
            location_name=data['location_name'],
            latitude=data['latitude'],
            longitude=data['longitude'],
            capacity=data['capacity'],
            price_per_night=data['price_per_night'],
            facilities=data.get('facilities'),
            image_url=data.get('image_url'),
            is_active=True
        )

        db.session.add(campsite)
        db.session.commit()

        return jsonify({
            'success': True,
            'message': 'Campsite created',
            'campsite': campsite.to_dict()
        }), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

# 2.4 Update an existing campsite (admin only) [by campsite_id]
@app.route('/api/admin/campsites/<int:campsite_id>', methods=['PUT'])
@jwt_required() # Admin authentication required
def update_campsite(campsite_id):
    try:
        # Read identity from JWT
        user = User.query.get(get_jwt_identity())

        # Admin check
        if user.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403

        campsite = Campsite.query.get(campsite_id)
        if not campsite:
            return jsonify({'success': False, 'message': 'Not found'}), 404

        data = request.get_json()

        campsite.name = data.get('name', campsite.name)
        campsite.description = data.get('description', campsite.description)
        campsite.location_name = data.get('location_name', campsite.location_name)
        campsite.latitude = data.get('latitude', campsite.latitude)
        campsite.longitude = data.get('longitude', campsite.longitude)
        campsite.capacity = data.get('capacity', campsite.capacity)
        campsite.price_per_night = data.get('price_per_night', campsite.price_per_night)
        campsite.facilities = data.get('facilities', campsite.facilities)
        campsite.image_url = data.get('image_url', campsite.image_url)
        campsite.is_active = data.get('is_active', campsite.is_active)

        db.session.commit()

        return jsonify({
            'success': True,
            'message': 'Campsite updated',
            'campsite': campsite.to_dict()
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

# 2.5 Delete (deactivate, not delete fully) a campsite (admin only) [by campsite_id]
@app.route('/api/admin/campsites/<int:campsite_id>', methods=['DELETE'])
@jwt_required() # Admin authentication required
def delete_campsite(campsite_id):
    try:
        # Read identity from JWT
        user = User.query.get(get_jwt_identity())
       
        # Admin check
        if user.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403

        campsite = Campsite.query.get(campsite_id)
        if not campsite:
            return jsonify({'success': False, 'message': 'Not found'}), 404

        campsite.is_active = False # Soft delete by deactivating (it's not removed from DB or deleted fully)
        db.session.commit() # Commit the change to the database
        # Purposely not deleting fully to preserve historical booking data and integrity

        return jsonify({
            'success': True,
            'message': 'Campsite deactivated'
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

# 2.6 Get total number of active campsites (admin only)
@app.route('/api/admin/campsites/total', methods=['GET'])
@jwt_required() # Admin authentication required
def get_total_campsites():
    try:
        # Read identity from JWT
        user_id = get_jwt_identity()
        user = User.query.get(user_id)

        # Admin check
        if user.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403

        total_campsites = Campsite.query.filter_by(is_active=True).count() # Only count active campsites
        return jsonify({
            'success': True,
            'total_campsites': total_campsites
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# 3. WEATHER ROUTES
# ============================================

import requests
from datetime import datetime, timedelta

# 3.1 Get weather forecast for a campsite location (also uses free Public API) [by campsite_id]
@app.route('/api/weather/forecast', methods=['GET'])
@jwt_required() # Authentication or login required
def get_weather_forecast():
    """
    Get weather forecast for a campsite location
    Query params:
        - campsite_id (required): ID of the campsite
        - days (optional): Number of forecast days (default: 8, max: 16)
    """
    try:
        # Get query parameters
        campsite_id = request.args.get('campsite_id', type=int)
        days = request.args.get('days', default=8, type=int)
        
        # Validate parameters
        if not campsite_id:
            return jsonify({
                'success': False, 
                'message': 'campsite_id is required'
            }), 400
        
        if days > 16:
            days = 16  # Open-Meteo API maximum
        
        # Get campsite from database
        campsite = Campsite.query.get(campsite_id)
        if not campsite:
            return jsonify({
                'success': False, 
                'message': 'Campsite not found'
            }), 404
        
        # Log request
        print(f"🌤️  Weather Request")
        print(f"   Campsite: {campsite.name} (ID: {campsite_id})")
        print(f"   Location: {float(campsite.latitude)}, {float(campsite.longitude)}")
        print(f"   Days: {days}")
        
        # Call Open-Meteo API (Free weather Public API, no key or auth needed)
        weather_api_url = "https://api.open-meteo.com/v1/forecast"
        params = {
            'latitude': float(campsite.latitude),
            'longitude': float(campsite.longitude),
            'daily': 'temperature_2m_max,temperature_2m_min,weathercode,precipitation_probability_mean,windspeed_10m_max',
            'timezone': 'Asia/Jakarta',
            'forecast_days': days
        }
        
        # Make request to weather API
        response = requests.get(weather_api_url, params=params, timeout=10)
        
        # Check response status
        if response.status_code != 200:
            print(f"❌ Open-Meteo API error: Status {response.status_code}")
            print(f"   Response: {response.text[:200]}")
            return jsonify({
                'success': False, 
                'message': f'Weather API returned status {response.status_code}'
            }), 500
        
        # Parse weather data
        weather_data = response.json()
        
        # Extract daily data
        daily = weather_data.get('daily', {})
        dates = daily.get('time', [])
        temps_max = daily.get('temperature_2m_max', [])
        temps_min = daily.get('temperature_2m_min', [])
        weather_codes = daily.get('weathercode', [])
        precipitation = daily.get('precipitation_probability_mean', [])
        wind_speeds = daily.get('windspeed_10m_max', [])
        
        # Check if we got data
        if not dates:
            print(f"❌ No forecast data from API")
            return jsonify({
                'success': False, 
                'message': 'No forecast data available'
            }), 500
        
        # Format forecast data for Flutter
        forecast = []
        for i in range(len(dates)):
            forecast.append({
                'date': dates[i],
                'temperature_max': round(temps_max[i], 1) if i < len(temps_max) else 25,
                'temperature_min': round(temps_min[i], 1) if i < len(temps_min) else 20,
                'weather_code': int(weather_codes[i]) if i < len(weather_codes) else 0,
                'precipitation_probability': round(precipitation[i], 1) if i < len(precipitation) else 0,
                'wind_speed': round(wind_speeds[i], 1) if i < len(wind_speeds) else 0,
            })
        
        # Log success
        print(f"✅ Successfully fetched {len(forecast)} days of forecast")
        print(f"   Sample: {forecast[0] if forecast else 'No data'}")
        
        # Return formatted response
        return jsonify({
            'success': True,
            'campsite': {
                'id': campsite.id,
                'name': campsite.name,
                'location': campsite.location_name
            },
            'forecast': forecast,
            'total_days': len(forecast)
        }), 200
        
    except requests.Timeout:
        print("❌ Weather API timeout (10s)")
        return jsonify({
            'success': False, 
            'message': 'Weather API request timed out'
        }), 504
        
    except requests.ConnectionError as e:
        print(f"❌ Weather API connection error: {str(e)}")
        return jsonify({
            'success': False, 
            'message': 'Could not connect to weather service'
        }), 503
        
    except requests.RequestException as e:
        print(f"❌ Weather API request error: {str(e)}")
        return jsonify({
            'success': False, 
            'message': f'Weather API error: {str(e)}'
        }), 500
        
    except KeyError as e:
        print(f"❌ Missing key in weather data: {str(e)}")
        return jsonify({
            'success': False, 
            'message': 'Invalid weather data format'
        }), 500
        
    except Exception as e:
        print(f"❌ Unexpected error in weather endpoint: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'success': False, 
            'message': f'Server error: {str(e)}'
        }), 500

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
# 4. BOOKING ROUTES
# ============================================

from datetime import date
from flask_jwt_extended import jwt_required, get_jwt
import random
import string

def generate_booking_code():
    """Generate unique booking code"""
    date_str = datetime.now().strftime('%Y%m%d')
    random_str = ''.join(random.choices(string.digits, k=6))
    return f"BKG{date_str}{random_str}"

# 4.1 Create a new campsite booking
@app.route('/api/bookings', methods=['POST'])
@jwt_required() # Authentication or login required
def create_booking():
    try:
        # Read identity from JWT
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

# 4.2 Get list of bookings for logged in user (client) [by user_id from JWT, by bookings]
@app.route('/api/bookings/my-bookings', methods=['GET'])
@jwt_required() # Authentication or login required
def get_my_bookings():
    try:
        # Read identity from JWT
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

# 4.3 Get list of all bookings for admin management (admin only)    
@app.route('/api/bookings/bookings-list', methods=['GET'])
@jwt_required() # Admin authentication required
def get_bookings_list():
    try:
        # Read identity from JWT
        claims = get_jwt()

        # Admin check
        if claims.get('role') != 'admin':
            return jsonify({
                'success': False,
                'message': 'Access denied. Admin only.'
            }), 403
        
        bookings = Booking.query.order_by(Booking.created_at.desc())\
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

# 4.4 Get total count of all bookings (admin only)
@app.route('/api/admin/bookings/total', methods=['GET'])
@jwt_required() # Admin authentication required
def get_total_bookings():
    try:
        # Read identity from JWT
        claims = get_jwt()

        # Admin check
        if claims.get('role') != 'admin':
            return jsonify({
                'success': False,
                'message': 'Access denied. Admin only.'
            }), 403

        total_bookings = Booking.query.count()

        return jsonify({
            'success': True,
            'total_bookings': total_bookings
        }), 200

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

from datetime import datetime, date

# 4.5 Get total count of today's bookings (admin only) [by created_at date]
@app.route('/api/admin/bookings/today', methods=['GET'])
@jwt_required() # Admin authentication required
def get_today_bookings():
    try:
        # Read identity from JWT
        claims = get_jwt()

        # Admin check
        if claims.get('role') != 'admin':
            return jsonify({
                'success': False,
                'message': 'Access denied. Admin only.'
            }), 403

        today = date.today() # Get today's date

        total_today_bookings = Booking.query.filter(
            db.func.date(Booking.created_at) == today
        ).count()

        return jsonify({
            'success': True,
            'total_today_bookings': total_today_bookings
        }), 200

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# 4.6 Get detailed information of a specific booking (admin only) [by booking_id]
# WILL COME BACK TO THIS LATER TO CHECK AGAIN OF THE USES OF THIS ROUTE WAS FOR PUBLIC OR ADMIN ONLY
# BECAUSE IT HAS NO VERIFICATION OF USER ID OR JWT IDENTITY    
@app.route('/api/admin/bookings/<int:booking_id>', methods=['GET'])
@jwt_required() # Admin authentication required
def get_booking_detail(booking_id):
    booking = Booking.query.filter_by(id=booking_id).first()

    if not booking:
        return jsonify({
            'success': False,
            'message': 'Booking not found'
        }), 404

    return jsonify({
        'success': True,
        'booking': {
            'id': booking.id,
            'booking_code': booking.booking_code,
            'booking_status': booking.booking_status,
            'campsite_id': booking.campsite_id,
            'campsite_name': booking.campsite.name,
            'check_in_date': booking.check_in_date.strftime('%Y-%m-%d'),
            'check_out_date': booking.check_out_date.strftime('%Y-%m-%d'),
            'num_people': booking.num_people,
            'num_tents': booking.num_tents,
            'price_per_night': booking.price_per_night,
            'total_nights': booking.total_nights,
            'subtotal': booking.subtotal,
            'tax_amount': booking.tax_amount,
            'total_price': booking.total_price,
            'special_requests': booking.special_requests,
            'created_at': booking.created_at.isoformat()
        }
    }), 200

@app.route('/api/admin/bookings/<int:booking_id>/status', methods=['PUT'])
@jwt_required()
def update_booking_status(booking_id):
    try:
        claims = get_jwt()

        # Hanya admin
        if claims.get('role') != 'admin':
            return jsonify({
                'success': False,
                'message': 'Access denied. Admin only.'
            }), 403

        booking = Booking.query.get(booking_id)
        if not booking:
            return jsonify({
                'success': False,
                'message': 'Booking not found'
            }), 404

        data = request.get_json()
        new_status = data.get('booking_status')

        # Validasi status
        allowed_status = ['pending', 'confirmed','cancelled', 'completed']
        if new_status not in allowed_status:
            return jsonify({
                'success': False,
                'message': f"Invalid status. Allowed: {', '.join(allowed_status)}"
            }), 400

        # Update
        booking.booking_status = new_status
        db.session.commit()

        return jsonify({
            'success': True,
            'message': 'Booking status updated successfully',
            'booking': booking.to_dict()
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500


# ============================================
# 5. ADMIN ROUTES
# ============================================

# 5.1 Get list of pending user registrations (admin only) [by registration_status]
@app.route('/api/admin/users/pending', methods=['GET'])
@jwt_required() # Admin authentication required
def get_pending_users():
    try:
        # Read identity from JWT
        user_id = get_jwt_identity()
        user = User.query.get(user_id)

        print(get_jwt_identity)
        
        # Admin check
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

# 5.2 Approve or reject a pending user registration (admin only) [by target_user_id]
@app.route('/api/admin/users/<int:target_user_id>/approval', methods=['PUT'])
@jwt_required() # Admin authentication required
def approve_reject_user(target_user_id):
    try:
        # Read identity from JWT
        user_id = get_jwt_identity()
        admin = User.query.get(user_id)
        
        # Admin check
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

# 5.3 Get total count of registered users (including active and inactive) (admin only)
# WILL COME BACK TO THIS LATER TO CONFIGURE BETWEEN ACTIVE/INACTIVE/TOTAL
# IF NEED TO MONTIOR THE EXACT AND DETAILED AMOUNT OF USERS
# ESPECIALLY FOR ADMIN PURPOSES AND FROM DASHBOARD VIEW
@app.route('/api/admin/users/total', methods=['GET'])
@jwt_required() # Admin authentication required
def get_total_users():
    try:
        # Read identity from JWT
        user_id = get_jwt_identity()
        user = User.query.get(user_id)

        # Admin check
        if user.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403

        total_users = User.query.count()
        return jsonify({
            'success': True,
            'total_users': total_users
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# 5.4 Get list of all registered users with their infos (including active and inactive) (admin only)
# Active and inactive users included for admin monitoring
@app.route('/api/admin/users', methods=['GET'])
@jwt_required() # Admin authentication required
def get_all_users():
    try:
        # Read identity from JWT
        user_id = get_jwt_identity()
        admin = User.query.get(user_id)

        # Admin check
        if not admin or admin.role != 'admin':
            return jsonify({
                'success': False,
                'message': 'Unauthorized'
            }), 403

        users = User.query.order_by(User.created_at.desc()).all()

        users_data = []
        for u in users:
            users_data.append({
                'id': u.id,
                'name': u.full_name,
                'email': u.email,
                'status': 'active' if u.is_active else 'inactive',
                'role': u.role,
                'joined': u.created_at.strftime('%Y-%m-%d'),
                'bookings': Booking.query.filter_by(user_id=u.id).count()
            })

        return jsonify({
            'success': True,
            'total_users': len(users_data),
            'users': users_data
        }), 200

    except Exception as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 500
    
# 5.5 Get detailed information of a specific user (admin only) [by user_id]
@app.route('/api/admin/users/<int:user_id>', methods=['GET'])
@jwt_required() # Admin authentication required
def get_user_detail(user_id):
    try:
        # Read identity from JWT
        admin_id = get_jwt_identity()
        admin = User.query.get(admin_id)

        # Admin check
        if not admin or admin.role != 'admin':
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403

        user = User.query.get(user_id)
        if not user:
            return jsonify({'success': False, 'message': 'User not found'}), 404

        # Hitung total bookings user
        total_bookings = Booking.query.filter_by(user_id=user.id).count()

        user_data = user.to_dict()
        user_data['total_bookings'] = total_bookings

        return jsonify({'success': True, 'user': user_data}), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# MAIN
# ============================================

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, host='0.0.0.0', port=5000)
