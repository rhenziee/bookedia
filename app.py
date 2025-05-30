from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, send_from_directory
import mysql.connector
import os
import re  # Import regex module
import time
from datetime import datetime, date
from werkzeug.utils import secure_filename
from flask import session
import random  # para OTP 
import smtplib  # para mag send OTP via email
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from flask_cors import CORS





app = Flask(__name__)
CORS(app)
app.secret_key = 'your_secret_key' 

# Directory to save uploaded files
UPLOAD_FOLDER1 = 'id'
app.config['UPLOAD_FOLDER1'] = UPLOAD_FOLDER1
os.makedirs(UPLOAD_FOLDER1, exist_ok=True)

UPLOAD_FOLDER2 = 'cert'
app.config['UPLOAD_FOLDER2'] = UPLOAD_FOLDER2
os.makedirs(UPLOAD_FOLDER2, exist_ok=True)

UPLOAD_FOLDER3 = 'product_images'
app.config['UPLOAD_FOLDER3'] = UPLOAD_FOLDER3
os.makedirs(UPLOAD_FOLDER3, exist_ok=True)

UPLOAD_FOLDER4 = 'feedback_photos'
app.config['UPLOAD_FOLDER4'] = UPLOAD_FOLDER4
os.makedirs(UPLOAD_FOLDER4, exist_ok=True)

UPLOAD_FOLDER5 = 'profile_picture'
app.config['UPLOAD_FOLDER5'] = UPLOAD_FOLDER5
os.makedirs(UPLOAD_FOLDER5, exist_ok=True)

UPLOAD_FOLDER6 = os.path.join(app.root_path, 'drivers_license')
app.config['UPLOAD_FOLDER6'] = UPLOAD_FOLDER6
os.makedirs(UPLOAD_FOLDER6, exist_ok=True)

UPLOAD_FOLDER7 = os.path.join(app.root_path, 'resume')
app.config['UPLOAD_FOLDER7'] = UPLOAD_FOLDER7
os.makedirs(UPLOAD_FOLDER7, exist_ok=True)


# LOGIN
# Database connection
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",  
        database="bookedia"
    )
# Validation 
def validate_password(password):
    if len(password) < 10:
        return False, "Password must be at least 10 characters long."
    return True, ""

def validate_contact(contact):
    if not re.fullmatch(r'09\d{9}', contact):
        return False, "Invalid contact number. Contact must start with '09' and contain exactly 11 digits."
    return True, ""

def validate_names(surname, firstname, middle_initial):
    name_pattern = r'^[a-zA-Z\s]+$'  # Allows only letters and spaces
    if not (re.fullmatch(name_pattern, surname) and re.fullmatch(name_pattern, firstname) and re.fullmatch(name_pattern, middle_initial)):
        return False, "Invalid name. Only letters and spaces are allowed."
    return True, ""


# pinaka login
@app.route('/')
def home():
    return render_template('login.html')

# logout
@app.route('/logout')
def logout():
    session.clear()  
    return redirect(url_for('home'))  



# for otp
def generate_otp():
    """Generate a 6-digit OTP."""
    return str(random.randint(100000, 999999))

def send_otp_email(recipient_email, otp):
    """Send OTP to the provided email address."""
    sender_email = "urrizarhenzyy14@gmail.com"  
    sender_password = "jaac lcxl ftgt bvkx" 

    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = recipient_email
    msg['Subject'] = "Your OTP Code"
    
    body = f"Your OTP code is: {otp}. It is valid for 5 minutes."
    msg.attach(MIMEText(body, 'plain'))

    try:
        with smtplib.SMTP('smtp.gmail.com', 587) as server:
            server.starttls()
            server.login(sender_email, sender_password)
            server.send_message(msg)
            print("OTP email sent!")
    except Exception as e:
        print(f"Error sending email: {e}")
@app.route('/verify_email', methods=['GET', 'POST'])
def verify_email():
    if request.method == 'POST':
        email = request.form['email']
        otp = generate_otp()

        session['otp'] = otp
        session['email'] = email

        send_otp_email(email, otp)
        flash("OTP sent to your email. Please enter the OTP below.")
        return redirect(url_for('enter_otp'))

    return render_template('verify_email.html') 

@app.route('/enter_otp', methods=['GET', 'POST'])
def enter_otp():
    if request.method == 'POST':
        entered_otp = (
            request.form.get('otp1') +
            request.form.get('otp2') +
            request.form.get('otp3') +
            request.form.get('otp4') +
            request.form.get('otp5') +
            request.form.get('otp6')
        )

        if entered_otp == session.get('otp'):
            flash("Email verified! Proceed to registration.", "success")
            return redirect(url_for('enter_otp'))  
        else:
            flash("Invalid OTP. Please try again.", "error")
            return redirect(url_for('enter_otp')) 

    return render_template('enter_otp.html')

@app.route('/register')
def register():
    email = session.get('email', '')
    if 'email' not in session:
        flash("Please verify your email first.")
        return redirect(url_for('verify_email'))

    return render_template('registration.html', email=email)


address_data = {
    "CALABARZON": {
        "Laguna": {
            "Nagcarlan": {
                "Barangay Kanluran Lazaaan": "4002",
                "Barangay Silangan Poblacion": "4003",
                "Barangay Poblacion Uno": "4004"
            },
            "Santa Cruz": {
                "Barangay Bubukal": "4009",
                "Barangay Calios": "4010",
                "Barangay Bagumbayan": "4011"
            }
        },
        "Batangas": {
            "Lipa": {
                "Barangay Sabang": "4217",
                "Barangay Balintawak": "4218",
                "Barangay 1": "4219"
            },
            "San Juan": {
                "Barangay Laiya-Aplaya": "4226",
                "Barangay Laiya-Ibabao": "4227",
                "Barangay Calicanto": "4228"
            }
        },
        "Cavite": {
            "Tagaytay": {
                "Barangay Silang Junction South": "4120",
                "Barangay Silang Junction West": "4121",
                "Barangay Maharlika East": "4122"
            },
            "Dasmariñas": {
                "Barangay Zone I": "4114",
                "Barangay Zone II": "4115",
                "Barangay Zone III": "4116"
            }
        },
        "Rizal": {
            "Antipolo": {
                "Barangay San Roque": "1870",
                "Barangay Cupang": "1871",
                "Barangay Dalig": "1872"
            },
            "Cainta": {
                "Barangay San Isidro": "1900",
                "Barangay Sto. Domingo": "1901",
                "Barangay Karangalan": "1902"
            }
        },
        "Quezon": {
            "Lucena": {
                "Barangay Market View": "4301",
                "Barangay Ibabang Dupay": "4302",
                "Barangay Gulang-Gulang": "4303"
            },
            "Tayabas": {
                "Barangay Lalo": "4327",
                "Barangay Palale Ibaba": "4328",
                "Barangay Ipilan": "4329"
            }
        }
    },
    "NCR": {  # National Capital Region (Manila and surrounding cities)
        "Manila": {
            "Ermita": {
                "Barangay 675": "1000",
                "Barangay 681": "1001",
                "Barangay 683": "1002"
            },
            "Quiapo": {
                "Barangay San Sebastian": "1003",
                "Barangay Santo Cristo": "1004",
                "Barangay Bilibid": "1005"
            },
            "Malate": {
                "Barangay 745": "1006",
                "Barangay 747": "1007",
                "Barangay 753": "1008"
            }
        },
        "Mandaluyong": {
            "Barangka": {
                "Barangay Barangka Drive": "1550",
                "Barangay Barangka Ibaba": "1551"
            },
            "Wack-Wack": {
                "Barangay Wack-Wack Greenhills": "1552",
                "Barangay Wack-Wack Aseana": "1553"
            }
        },
        "Quezon City": {
            "Cubao": {
                "Barangay Cubao Proper": "1109",
                "Barangay Socorro": "1110",
                "Barangay Baño": "1111"
            },
            "Batasan": {
                "Barangay Batasan Hills": "1122",
                "Barangay Payatas": "1123",
                "Barangay Commonwealth": "1124"
            }
        },
        "Pasig": {
            "Ortigas": {
                "Barangay Ugong": "1600",
                "Barangay San Antonio": "1601"
            },
            "Kapitolyo": {
                "Barangay Kapitolyo Proper": "1602",
                "Barangay Maybunga": "1603"
            }
        },
        "Makati": {
            "Ayala": {
                "Barangay Ayala Triangle": "1200",
                "Barangay Bel-Air": "1201"
            },
            "Poblacion": {
                "Barangay Poblacion I": "1202",
                "Barangay Poblacion II": "1203"
            }
        }
    }
}

@app.route('/get_provinces', methods=['GET'])
def get_provinces():
    provinces = list(address_data["CALABARZON"].keys())
    return jsonify(provinces)

@app.route('/get_municipalities/<province>', methods=['GET'])
def get_municipalities(province):
    municipalities = list(address_data["CALABARZON"].get(province, {}).keys())
    return jsonify(municipalities)

@app.route('/get_barangays/<province>/<municipality>', methods=['GET'])
def get_barangays(province, municipality):
    barangays = address_data["CALABARZON"].get(province, {}).get(municipality, {})
    return jsonify(barangays)

@app.route('/get_zip_code/<province>/<municipality>/<barangay>', methods=['GET'])
def get_zip_code(province, municipality, barangay):
    zip_code = address_data["CALABARZON"].get(province, {}).get(municipality, {}).get(barangay)
    return jsonify(zip_code)




# Register new user
@app.route('/submit_form', methods=['POST'])
def submit_form():
    surname = request.form['surname']
    firstname = request.form['firstname']
    middle_initial = request.form['middle_initial']
    email = request.form['email']
    contact = request.form['contact']
    province = request.form['province']
    municipality = request.form['municipality']
    barangay = request.form['barangay']
    zip_code = request.form['zip_code']
    password = request.form['password']
    user_type = request.form['userType']
    
    address = f"{barangay}, {municipality}, {province}, {zip_code}"

    id_upload_filename = None
    business_cert_filename = None
    drivers_license_filename = None
    resume_filename = None

    # Validate contact, names, and password
    is_valid, msg = validate_contact(contact)
    if not is_valid:
        return jsonify(status="error", message=msg), 400
    
    is_valid, msg = validate_names(surname, firstname, middle_initial)
    if not is_valid:
        return jsonify(status="error", message=msg), 400

    is_valid, msg = validate_password(password)
    if not is_valid:
        return jsonify(status="error", message=msg), 400

    # Check if user is a seller and require ID + Business Cert
    if user_type == 'seller':
        id_upload = request.files.get('idUpload')
        business_cert_upload = request.files.get('businessCertUpload')

        if not id_upload or not business_cert_upload:
            return jsonify(status="error", message="ID and business certificate are required for sellers."), 400

        id_upload_filename = id_upload.filename
        id_upload.save(os.path.join(app.config['UPLOAD_FOLDER1'], id_upload_filename))
        
        business_cert_filename = business_cert_upload.filename
        business_cert_upload.save(os.path.join(app.config['UPLOAD_FOLDER2'], business_cert_filename))
    
    # Check if user is a courier and require Driver's License + Resume
    if user_type == 'courier':
        drivers_license = request.files.get('driversLicense')
        resume_upload = request.files.get('resumeUpload')

        if not drivers_license or not resume_upload:
            return jsonify(status="error", message="Driver's License and Resume are required for couriers."), 400
        
        drivers_license_filename = drivers_license.filename
        drivers_license.save(os.path.join(app.config['UPLOAD_FOLDER6'], drivers_license_filename))
        
        resume_filename = resume_upload.filename
        resume_upload.save(os.path.join(app.config['UPLOAD_FOLDER7'], resume_filename))

    # Save to Database
    conn = get_db_connection()
    cursor = conn.cursor()

    sql = """
        INSERT INTO users (surname, firstname, middle_initial, email, contact, password, address, user_type, id_upload, business_cert_upload, drivers_license, resume_upload) 
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    values = (surname, firstname, middle_initial, email, contact, password, address, user_type, id_upload_filename, business_cert_filename, drivers_license_filename, resume_filename)

    try:
        cursor.execute(sql, values)
        conn.commit()

        notification_message = (
            f"New seller registration: {firstname} {surname} is asking for approval."
            if user_type == 'seller' else
            f"New courier registration: {firstname} {surname} is asking for approval."
            if user_type == 'courier' else
            f"New buyer registration: {firstname} {surname} has registered."
        )
        notification_sql = """
            INSERT INTO notifications (user_id, user_type, message, activity_type) 
            VALUES (%s, %s, %s, %s)
        """
        cursor.execute(notification_sql, (1, 'admin', notification_message, 'registration'))
        conn.commit()

        return jsonify(status="success", message="Registration successful! You can now log in."), 200
    except mysql.connector.Error as err:
        return jsonify(status="error", message=f"Database error: {err}"), 500
    finally:
        cursor.close()
        conn.close()



# RETURN SA LOGIN
@app.route('/back')
def back():
    return render_template('login.html')



@app.route('/login', methods=['POST'])
def login():
    email = request.form['email']
    password = request.form['password']

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM users WHERE email = %s AND password = %s", (email, password))
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    if user:
        session['user_id'] = user['id']  
        session['user_surname'] = user['surname']  
        session['user_firstname'] = user['firstname']
        session['user_middle_initial'] = user['middle_initial']
        session['user_address'] = user.get('address')  
        user_type = user['user_type']
        status = user.get('status')  

        if user['is_admin'] == 1:
            return redirect(url_for('admin_home'))  
        elif user_type == 'buyer':
            return redirect(url_for('buyer_home')) 
        elif user_type == 'seller':
            if status == 'approved':
                return redirect(url_for('seller_home'))  
            elif status == 'pending':
                return render_template('pending_seller.html', message="Your account is pending approval. You will be notified once approved.")
            elif status == 'declined':
                decline_reason = get_decline_reason(user['id'])
                error_message = f"Your registration as a seller was declined. Reason: {decline_reason}. Please re-apply again."
                return render_template('login.html', error=error_message)
        elif user_type == 'courier':
            if status == 'approved':
                return redirect(url_for('courier_home'))  
            elif status == 'pending':
                return render_template('pending_courier.html', message="Your account is pending approval. You will be notified once approved.")
            elif status == 'declined':
                decline_reason = get_decline_reason(user['id'])
                error_message = f"Your registration as a courier was declined. Reason: {decline_reason}. Please re-apply again."
                return render_template('login.html', error=error_message)
    else:
        return render_template('login.html', error="Incorrect email or password. Please try again.")


def get_decline_reason(user_id):
    connection = get_db_connection()  
    cursor = connection.cursor()
    cursor.execute("SELECT decline_reason FROM users WHERE id = %s", (user_id,))
    result = cursor.fetchone()
    return result[0] if result else "No reason provided"






@app.route('/forgot', methods=['GET', 'POST'])
def forgot():
    if request.method == 'POST':
        new_password = request.form['new_password']

        email = session.get('email')

        if email:
            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute("UPDATE users SET password = %s WHERE email = %s", (new_password, email))
            conn.commit()
            cursor.close()
            conn.close()

            flash("Password has been successfully reset!", "success")
            return redirect(url_for('back'))  
        else:
            flash("Session expired. Please try again.", "error")
            return redirect(url_for('forgot_email_verify'))  
    return render_template('forgot.html')

@app.route('/forgot_email_verify', methods=['GET', 'POST'])
def forgot_email_verify():
    if request.method == 'POST':
        email = request.form['email']

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user:
            otp = generate_otp()

            session['otp'] = otp
            session['email'] = email

            send_otp_email(email, otp)
            flash("OTP sent to your email. Please enter the OTP below.")
            return redirect(url_for('forgot_email_otp'))
        else:
            flash("No user found with this email. Please try again.", "error")

    return render_template('forgot_email_verify.html')

@app.route('/forgot_email_otp', methods=['GET', 'POST'])
def forgot_email_otp():
    if request.method == 'POST':
        entered_otp = (
            request.form.get('otp1') +
            request.form.get('otp2') +
            request.form.get('otp3') +
            request.form.get('otp4') +
            request.form.get('otp5') +
            request.form.get('otp6')
        )

        if entered_otp == session.get('otp'):
            flash("Email verified! Proceed to password reset.", "success")
            return redirect(url_for('forgot'))  
        else:
            flash("Invalid OTP. Please try again.", "error")
            return redirect(url_for('forgot_email_otp'))  

    return render_template('forgot_email_otp.html')

@app.route('/reset_password', methods=['POST'])
def reset_password():
    data = request.json
    email = data.get('email')
    new_password = data.get('new_password')

    is_valid, msg = validate_password(new_password)
    if not is_valid:
        return jsonify({'success': False, 'message': msg}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute("UPDATE users SET password = %s WHERE email = %s", (new_password, email))
        conn.commit()
        if cursor.rowcount > 0:
            return jsonify({'success': True, 'message': 'Password reset successfully.'}), 200
        else:
            return jsonify({'success': False, 'message': 'Email not found.'}), 404
    except mysql.connector.Error as err:
        return jsonify({'success': False, 'message': f'Error: {err}'}), 500
    finally:
        cursor.close()
        conn.close()











# ADMIN PAGE
@app.route('/admin_home')
def admin_home():
    users_count = get_users_count()  
    pending_sellers_count = get_pending_sellers_count()  
    total_admin_commission = get_total_admin_commission() 
    return render_template('admin.html', users_count=users_count, 
                           pending_sellers_count=pending_sellers_count, 
                           total_admin_commission=total_admin_commission) 

# Function to get the sum of all admin commissions
def get_total_admin_commission():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT SUM(admin_commission) FROM orders")  
    total_admin_commission = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    return total_admin_commission if total_admin_commission else 0 


# Function to get the count of sellers with 'pending' status
def get_pending_sellers_count():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM users WHERE user_type = 'seller' AND status = 'pending'")  
    pending_sellers_count = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    return pending_sellers_count


# total count of users excluding admins
def get_users_count():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM users WHERE is_admin != 1")  
    users_count = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    return users_count




@app.route('/manageuser')
def manageuser():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # Pending sellers and couriers
    cursor.execute("""
        SELECT id, firstname, surname, email, contact, id_upload, business_cert_upload, 
               drivers_license, resume_upload, user_type
        FROM users 
        WHERE (user_type = 'seller' OR user_type = 'courier') 
        AND status = 'pending'
    """)
    pending_users = cursor.fetchall()

    # Declined sellers and couriers
    cursor.execute("""
        SELECT id, firstname, surname, email, contact, id_upload, business_cert_upload, 
               drivers_license, resume_upload, user_type
        FROM users 
        WHERE (user_type = 'seller' OR user_type = 'courier') 
        AND status = 'declined'
    """)
    decline_users = cursor.fetchall()

    # All users: Buyer, Approved Seller, and Approved Courier
    cursor.execute("""
        SELECT id, firstname, surname, middle_initial, email, contact, user_type, password 
        FROM users 
        WHERE 
            user_type = 'buyer' 
            OR (user_type = 'seller' AND status = 'approved') 
            OR (user_type = 'courier' AND status = 'approved')
    """)
    all_users = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template(
        'admin_manageuser.html', 
        pending_users=pending_users, 
        all_users=all_users, 
        decline_users=decline_users
    )

# Route to serve uploaded Driver's License images
@app.route('/drivers_license/<filename>')
def uploaded_license_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER6'], filename)

# Route to serve uploaded Resume images
@app.route('/resume/<filename>')
def uploaded_resume_file(filename):
    file_path = os.path.join(app.config['UPLOAD_FOLDER7'], filename)
    if not os.path.exists(file_path):
        print("File not found:", file_path)
       
    return send_from_directory(app.config['UPLOAD_FOLDER7'], filename, as_attachment=True)


# file upload ng files ni seller
@app.route('/uploads/id/<filename>')
def uploaded_id_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER1'], filename)

@app.route('/uploads/cert/<filename>')
def uploaded_cert_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER2'], filename)

app.config['MAIL_USERNAME'] = 'urrizarhenzyy14@gmail.com'
app.config['MAIL_PASSWORD'] = 'jaac lcxl ftgt bvkx'
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True

def send_email(recipient_email, subject, message):
    sender_email = app.config['MAIL_USERNAME']
    sender_password = app.config['MAIL_PASSWORD']
    
    msg = MIMEText(message, 'html')  
    msg['Subject'] = subject
    msg['From'] = sender_email
    msg['To'] = recipient_email

    try:
        with smtplib.SMTP(app.config['MAIL_SERVER'], app.config['MAIL_PORT']) as server:
            server.starttls()
            server.login(sender_email, sender_password)
            server.sendmail(sender_email, recipient_email, msg.as_string())
    except Exception as e:
        print(f"Failed to send email: {e}")
# Approve seller
@app.route('/approve_seller/<int:user_id>', methods=['POST'])
def approve_seller(user_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # Fetch seller details
    cursor.execute("SELECT email, firstname, surname FROM users WHERE id = %s", (user_id,))
    seller = cursor.fetchone()
    
    cursor.execute("UPDATE users SET status = 'approved' WHERE id = %s", (user_id,))
    conn.commit()

    if seller:
        recipient_email = seller['email']
        subject = "Your Seller Request Has Been Approved"
        message = f"""
        <p>Dear {seller['firstname']} {seller['surname']},</p>
        <p>We are pleased to inform you that your seller request has been approved. You can now access your account and start listing your products.</p>
        <p>Thank you!</p>
        """
        send_email(recipient_email, subject, message)

    cursor.close()
    conn.close()

    return redirect(url_for('manageuser'))


# Decline seller

def get_declined_sellers():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE user_type = 'seller' AND status = 'declined'")
    declined_sellers = cursor.fetchall()
    connection.close()
    return declined_sellers

@app.route('/declined_users')
def declined_users():
    # Fetch declined sellers from the database
    declined_sellers = get_declined_sellers()  
    return render_template('admin_manageuserarchive.html', decline_seller=declined_sellers)

@app.route('/decline_seller/<int:user_id>', methods=['POST'])
def decline_seller(user_id):
    reason = request.form.get('decline_reason')
    comment = request.form.get('decline_comment', '').strip()

    if not reason:
        flash("Decline reason is required.", "error")
        return redirect(url_for('manageuser'))

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT email, firstname, surname FROM users WHERE id = %s", (user_id,))
    seller = cursor.fetchone()
    
    query = """
        UPDATE users 
        SET status = 'declined', decline_reason = %s, decline_comment = %s
        WHERE id = %s
    """
    cursor.execute(query, (reason, comment, user_id))
    conn.commit()

    # Send email notification
    if seller:
        recipient_email = seller['email']
        subject = "Your Seller Request Has Been Declined"
        message = f"""
        <p>Dear {seller['firstname']} {seller['surname']},</p>
        <p>We regret to inform you that your seller request has been declined for the following reason:</p>
        <p><strong>{reason}</strong></p>
        <p>{comment}</p>
        <p>Please re-apply again. Thank you!</p>
        """
        send_email(recipient_email, subject, message)

    cursor.close()
    conn.close()

    flash("Seller request has been declined with reason: " + reason, "success")
    return redirect(url_for('manageuser'))


@app.route('/update_user/<int:user_id>', methods=['POST'])
def update_user(user_id):
    surname = request.form['surname']
    firstname = request.form['firstname']
    middle_initial = request.form['middle_initial']
    email = request.form['email']
    contact = request.form['contact']
    password = request.form['password']
    
    is_valid, msg = validate_contact(contact)
    if not is_valid:
        flash(msg, 'error')  
        return redirect(url_for('manageuser'))  
    
    is_valid, msg = validate_names(surname, firstname, middle_initial)
    if not is_valid:
        flash(msg, 'error')  
        return redirect(url_for('manageuser'))  

    is_valid, msg = validate_password(password)
    if not is_valid:
        flash(msg, 'error')  
        return redirect(url_for('manageuser'))
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""UPDATE users 
                      SET surname = %s, firstname = %s, middle_initial = %s, email = %s, contact = %s, password = %s 
                      WHERE id = %s""", (surname, firstname, middle_initial, email, contact, password, user_id))
    
    conn.commit()
    cursor.close()
    conn.close()

    flash('User updated successfully!', 'success') 
    return redirect(url_for('manageuser'))  

@app.route('/delete_user/<int:user_id>', methods=['POST'])
def delete_user(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))

    conn.commit()
    cursor.close()
    conn.close()

    flash('User deleted successfully!', 'success') 
    return redirect(url_for('manageuser')) 

@app.route('/admin_notif')
def admin_notif():
    user_id = session.get('user_id')  
    if not user_id:
        return redirect('/login')


    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, message, activity_type, is_read, created_at
        FROM notifications
        WHERE user_id = %s
        ORDER BY created_at DESC
    """, (user_id,))

    notifications = cursor.fetchall()  
    conn.close()

    print("Admin notifications:", notifications)

    return render_template('admin_notif.html', notifications=notifications)


@app.route('/manage_user/<int:notification_id>')
def manage_user(notification_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT * FROM notifications
        WHERE id = %s
    """, (notification_id,))
    notification = cursor.fetchone()
    conn.close()

    if notification:
        session['notification'] = notification

        if notification['activity_type'] == 'registration':
            return redirect('/manageuser')
        else:
            return redirect('/some_default_page')
    else:
        return redirect('/admin_notif')



@app.route('/admin_salesreport')
def admin_salesreport():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
SELECT 
    oi.id AS item_id,
    oi.product_name,
    oi.order_id,
    o.buyer_id,
    o.recipient_name,
    p.id AS product_id,
    p.user_id AS seller_id,
    oi.quantity,
    o.total_price AS total_sales_amount,  -- Changed from oi.total_price to o.total_price
    (o.total_price - o.admin_commission) AS seller_profit,  -- Use o.total_price instead of oi.total_price
    (o.total_price * 0.05) AS admin_commission, 
    o.estimated_delivery_date
FROM 
    orders o
JOIN 
    order_items oi ON o.id = oi.order_id
JOIN 
    products p ON p.product_name = oi.product_name
JOIN 
    users u_seller ON p.user_id = u_seller.id
WHERE 
    o.status = 'Completed'
ORDER BY 
    o.order_date DESC;
    """
    cursor.execute(query)
    sales_data = cursor.fetchall()

    return render_template('admin_salesreport.html', sales_data=sales_data)

@app.route('/fetch_filtered_sales', methods=['POST'])
def fetch_filtered_sales():
    from_date = request.form.get('from_date')
    to_date = request.form.get('to_date')

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
    SELECT 
        oi.id AS item_id,
        oi.product_name,
        oi.order_id,
        o.buyer_id,
        o.recipient_name,
        p.id AS product_id,
        p.user_id AS seller_id,
        oi.quantity,
        o.total_price,
        (o.total_price - o.admin_commission) AS seller_profit,
        o.estimated_delivery_date,
        o.admin_commission
    FROM 
        orders o
    JOIN 
        order_items oi ON o.id = oi.order_id
    JOIN 
        products p ON p.product_name = oi.product_name
    WHERE 
        o.status = 'Completed' AND
        o.order_date BETWEEN %s AND %s
    ORDER BY 
        o.order_date DESC;
    """
    cursor.execute(query, (from_date, to_date))
    sales_data = cursor.fetchall()
    
    return jsonify({"sales_data": sales_data})




@app.route('/admin_setting')
def admin_setting():
    return render_template('admin_setting.html')

@app.route('/update_adminpassword', methods=['POST'])
def update_adminpassword():
    if 'user_id' not in session:
        flash('You must be logged in to update the password.', 'error')
        return redirect(url_for('login'))

    user_id = session['user_id'] 
    old_password = request.form['oldpass']
    new_password = request.form['newpass']
    confirm_new_password = request.form['confirmnewpass']

    if new_password != confirm_new_password:
        flash('New password and confirmation do not match.', 'error')
        return redirect(url_for('admin_setting'))

    if old_password == new_password:
        flash('New password cannot be the same as the old password.', 'error')
        return redirect(url_for('admin_setting'))

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        cursor.execute("SELECT password FROM users WHERE id = %s AND is_admin = 1", (user_id,))
        result = cursor.fetchone()

        if not result:
            flash('Admin user not found.', 'error')
            return redirect(url_for('admin_setting'))

        current_password = result[0]

        if current_password != old_password:
            flash('Current password is incorrect.', 'error')
            return redirect(url_for('admin_setting'))

        cursor.execute("UPDATE users SET password = %s WHERE id = %s AND is_admin = 1", (new_password, user_id))
        connection.commit()

        flash('Password updated successfully.', 'success')
        return redirect(url_for('admin_setting'))

    except Exception as e:
        flash(f'An error occurred: {str(e)}', 'error')
        return redirect(url_for('admin_setting'))

    finally:
        cursor.close()
        connection.close()






# buyers page
# shipping status of orders
@app.route('/pending')
def pending_orders():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    query = """
    SELECT o.id, o.recipient_name, o.shipping_address, o.payment_method, o.total_price, o.order_date, 
           o.estimated_delivery_date, oi.product_name, oi.quantity
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    WHERE o.status = 'Pending'
    """
    
    cursor.execute(query)
    pending_orders = cursor.fetchall()
    conn.close()
    
    return render_template('orders_pending.html', orders=pending_orders)


@app.route('/toship')
def toship():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    query = """
        SELECT orders.id, order_items.product_name, order_items.quantity, orders.total_price, 
               orders.recipient_name, orders.shipping_address, orders.payment_method, 
               orders.order_date, orders.estimated_delivery_date
        FROM orders
        JOIN order_items ON orders.id = order_items.order_id
        WHERE orders.status = 'toship'
    """
    
    cursor.execute(query)
    toship_orders = cursor.fetchall()
    conn.close()
    
    return render_template('orders_toship.html', orders=toship_orders)


@app.route('/ofd')
def ofd():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    query = """
        SELECT orders.id, order_items.product_name, order_items.quantity, orders.total_price, 
               orders.recipient_name, orders.shipping_address, orders.payment_method, 
               orders.order_date, orders.estimated_delivery_date
        FROM orders
        JOIN order_items ON orders.id = order_items.order_id
        WHERE orders.status = 'outfordelivery'
    """
    
    cursor.execute(query)
    ofd_orders = cursor.fetchall()
    conn.close()
    
    return render_template('orders_outfordelivery.html', orders=ofd_orders)
@app.route('/mark_completed/<int:order_id>', methods=['POST'])
def mark_completed(order_id):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT o.id, o.buyer_id 
        FROM orders o 
        WHERE o.id = %s
    """, (order_id,))
    order = cursor.fetchone()

    if not order:
        return "Order not found.", 404

    try:
        cursor.execute("""
            UPDATE orders
            SET status = 'Completed', date_delivered = NOW()
            WHERE id = %s
        """, (order_id,))

        message = f"The order #{order_id} has been marked as completed."
        cursor.execute("""
            INSERT INTO notifications (user_id, user_type, message, activity_type)
            VALUES (%s, 'seller', %s, 'Order Completed')
        """, (order['buyer_id'], message))

        connection.commit()
    except Exception as e:
        connection.rollback()
        return f"An error occurred: {str(e)}", 500
    finally:
        cursor.close()
        connection.close()

    return redirect(url_for('ofd'))


@app.route('/completed')
def completed():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    query = """
        SELECT orders.id AS order_id, order_items.product_name, order_items.quantity,
               orders.total_price, orders.recipient_name, orders.shipping_address, 
               orders.payment_method, orders.order_date, orders.date_delivered
        FROM orders
        JOIN order_items ON orders.id = order_items.order_id
        WHERE orders.status = 'Completed'
    """
    cursor.execute(query)
    completed_orders = cursor.fetchall()

    for order in completed_orders:
        product_name = order['product_name']
        quantity_sold = order['quantity']
        
        update_stock_query = """
            UPDATE products
            SET product_quantity = product_quantity - %s
            WHERE product_name = %s AND product_quantity >= %s
        """
        cursor.execute(update_stock_query, (quantity_sold, product_name, quantity_sold))
    
    conn.commit()  
    conn.close()
    
    return render_template('orders_completed.html', orders=completed_orders)



@app.route('/cancelled')
def cancelled():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    query = """
    SELECT orders.id, order_items.product_name, order_items.quantity, orders.total_price, 
           orders.recipient_name, orders.shipping_address, orders.payment_method, 
           orders.order_date, orders.estimated_delivery_date, orders.cancellation_reason
    FROM orders
    JOIN order_items ON orders.id = order_items.order_id
    WHERE orders.status = 'Cancelled'
"""

    
    cursor.execute(query)
    cancelled_orders = cursor.fetchall()
    conn.close()
    return render_template('orders_cancelled.html', orders=cancelled_orders)


# cancellatuion of order
@app.route('/cancel_order/<int:order_id>', methods=['POST'])
def cancel_order(order_id):
    reason = request.form.get('cancellation_reason')
    if not reason:
        return "Cancellation reason is required.", 400

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT o.id, o.buyer_id 
        FROM orders o 
        WHERE o.id = %s
    """, (order_id,))
    order = cursor.fetchone()

    if not order:
        return "Order not found.", 404

    try:
        cursor.execute("""
            UPDATE orders
            SET status = 'Cancelled', cancellation_reason = %s
            WHERE id = %s
        """, (reason, order_id))

        message = f"Your order #{order_id} has been cancelled. Reason: {reason}."
        cursor.execute("""
            INSERT INTO notifications (user_id, user_type, message, activity_type)
            VALUES (%s, 'seller', %s, 'Order Cancellation')
        """, (order['buyer_id'], message))

        connection.commit()
    except Exception as e:
        connection.rollback()
        return f"An error occurred: {str(e)}", 500
    finally:
        cursor.close()
        connection.close()

    flash('Order has been cancelled successfully.', 'success')
    return redirect(url_for('pending_orders'))







@app.route('/uploads/feedback_photos/<filename>')
def uploaded_feedback_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER4'], filename)

@app.route('/submit_feedback', methods=['POST'])
def submit_feedback():
    order_id = request.form.get('order_id')
    comment = request.form.get('comment')
    rating = request.form.get('rating')
    product_name = request.form.get('product_name')  
    
    photo = request.files.get('photo')
    photo_filename = None
    if photo:
        photo_filename = secure_filename(photo.filename)
      
        photo.save(os.path.join(app.config['UPLOAD_FOLDER4'], photo_filename))
    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO feedback (order_id, comment, rating, product_name, photo) 
        VALUES (%s, %s, %s, %s, %s)
    """, (order_id, comment, rating, product_name, photo_filename))
    
    conn.commit()
    conn.close()
    
    return redirect('/completed')



# home buyer
# profile
@app.route('/uploads/<filename>')
def uploaded_profile_picture(filename):
    return send_from_directory(UPLOAD_FOLDER5, filename)



@app.route('/buyersetting', methods=['GET', 'POST'])
def edit_user_info():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)  

    user_id = session['user_id']
    if request.method == 'POST':
        surname = request.form['surname']
        firstname = request.form['firstname']
        middle_initial = request.form['middle_initial']
        email = request.form['email']
        contact = request.form['contact']
        address = request.form['address']
        profile_picture = request.files['profile_picture']

        password = request.form['password']
        if not password:
            cursor.execute('SELECT password FROM users WHERE id = %s', (user_id,))
            password = cursor.fetchone()['password']  
        cursor.execute("""
            UPDATE users SET surname = %s, firstname = %s, middle_initial = %s,
                            email = %s, contact = %s, address = %s, password = %s
            WHERE id = %s
        """, (surname, firstname, middle_initial, email, contact, address, password, user_id))
        
        if profile_picture:
            filename = profile_picture.filename
            profile_picture.save(os.path.join(app.config['UPLOAD_FOLDER5'], filename))

            cursor.execute("UPDATE users SET profile_picture = %s WHERE id = %s", (filename, user_id))

        conn.commit()
        flash("Profile updated successfully!")
        return redirect(url_for('edit_user_info'))

    cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    conn.close()
    return render_template('buyer_profile_settings.html', user=user)



@app.route('/profile')
def profile():
   
    user_id = session.get('user_id')
    
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute('SELECT profile_picture FROM users WHERE id = %s', (user_id,))
    user_data = cursor.fetchone()
    
    profile_picture = user_data['profile_picture'] if user_data['profile_picture'] else 'default_user.png'
    
    profile_picture_path = f"uploads/{profile_picture}" 
    return render_template('profile.html', profile_picture=profile_picture_path)



@app.route('/buyer_home')
def buyer_home():
    if 'user_id' not in session:
        return redirect(url_for('login'))  
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    user_id = session['user_id']
    
    cursor.execute("SELECT profile_picture FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()

    cursor.execute("""
        SELECT p.id, p.product_price, p.product_image, p.product_name, p.product_description, 
               p.product_quantity, 
               COALESCE(AVG(f.rating), 0) AS average_rating
        FROM products p
        LEFT JOIN feedback f ON p.product_name = f.product_name  # Join by product_name
        WHERE p.status = 'active'  # Only active products
        GROUP BY p.id
    """)
    products = cursor.fetchall()

    cursor.execute("""
        SELECT p.id, p.product_price, p.product_image, p.product_name, p.product_description, 
               p.product_category, p.user_id, p.product_quantity, 
               COALESCE(AVG(f.rating), 0) AS average_rating
        FROM products p
        LEFT JOIN feedback f ON p.product_name = f.product_name  # Join by product_name
        WHERE p.status = 'active' AND p.product_category IN ('Books', 'Magazines', 'Music', 'Movies', 'Gaming', 'Educational DVDs')
        GROUP BY p.id
        ORDER BY p.last_clicked DESC
        LIMIT 15
    """)
    trending_products = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('buyer_home.html', products=products, trending_products=trending_products, user=user)





@app.route('/uploads/product_images/<filename>')
def uploaded_product_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER3'], filename)



@app.route('/buyer_books')
def buyer_books():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    category = 'fiction'
    cursor.execute("""
        SELECT * FROM products 
        WHERE product_category = %s
        ORDER BY RAND() 
        LIMIT 1
    """, (category,))
    monthly_pick = cursor.fetchone()

    cursor.execute("""
                SELECT * FROM products
        WHERE product_category IN ('Books', 'Magazines', 'Music', 'Movies', 'Gaming', 'Educational DVDs')
        ORDER BY last_clicked DESC
        LIMIT 10
    """)
    trending_products = cursor.fetchall()

    categories = ['fiction', 'non-fiction', 'Childrens Literature']
    categorized_products = {}

    for cat in categories:
        cursor.execute("""
            SELECT * FROM products
            WHERE product_category = %s
            ORDER BY created_at DESC
        """, (cat,))
        categorized_products[cat] = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template('buyer_books.html', 
                           monthly_pick=monthly_pick, 
                           trending_products=trending_products,
                           categorized_products=categorized_products)




@app.route('/buyer_magazines')
def buyer_magazines():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    category = 'Lifestyle Magazine'
    cursor.execute("""
        SELECT * FROM products 
        WHERE product_category = %s
        ORDER BY RAND() 
        LIMIT 1
    """, (category,))
    monthly_pick = cursor.fetchone()

    cursor.execute("""
        SELECT * FROM products
        ORDER BY last_clicked DESC  -- Make sure last_clicked column exists and stores timestamp or click count
        LIMIT 10
    """)
    trending_products = cursor.fetchall()

    categories = ['Lifestyle Magazine', 'News and Current Affairs', 'Special Interest']
    categorized_products = {}

    for cat in categories:
        cursor.execute("""
            SELECT * FROM products
            WHERE product_category = %s
            ORDER BY created_at DESC
        """, (cat,))
        categorized_products[cat] = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template('buyer_magazines.html', 
                           monthly_pick=monthly_pick, 
                           trending_products=trending_products,
                           categorized_products=categorized_products)


@app.route('/buyer_music')
def buyer_music():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    # Monthly pick query (random product from 'Music' category)
    category = 'Music'
    cursor.execute("""
        SELECT * FROM products 
        WHERE product_category = %s
        ORDER BY RAND() 
        LIMIT 1
    """, (category,))
    monthly_pick = cursor.fetchone()

    cursor.execute("""
        SELECT * FROM products
        ORDER BY last_clicked DESC  -- Make sure last_clicked column exists and stores timestamp or click count
        LIMIT 10
    """)
    trending_products = cursor.fetchall()

    categories = ['Music']
    categorized_products = {}

    for cat in categories:
        cursor.execute("""
            SELECT * FROM products
            WHERE product_category = %s
            ORDER BY created_at DESC
        """, (cat,))
        categorized_products[cat] = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template('buyer_music.html', 
                           monthly_pick=monthly_pick, 
                           trending_products=trending_products,
                           categorized_products=categorized_products)



@app.route('/buyer_movies')
def buyer_movies():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    category = 'Movies'
    cursor.execute("""
        SELECT * FROM products 
        WHERE product_category = %s
        ORDER BY RAND() 
        LIMIT 1
    """, (category,))
    monthly_pick = cursor.fetchone()

    cursor.execute("""
        SELECT * FROM products
        ORDER BY last_clicked DESC  -- Make sure last_clicked column exists and stores timestamp or click count
        LIMIT 10
    """)
    trending_products = cursor.fetchall()

    categories = ['Music']
    categorized_products = {}

    for cat in categories:
        cursor.execute("""
            SELECT * FROM products
            WHERE product_category = %s
            ORDER BY created_at DESC
        """, (cat,))
        categorized_products[cat] = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template('buyer_movies.html', 
                           monthly_pick=monthly_pick, 
                           trending_products=trending_products,
                           categorized_products=categorized_products)



@app.route('/buyer_gaming')
def buyer_gaming():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    category = 'Video Games'
    cursor.execute("""
        SELECT * FROM products 
        WHERE product_category = %s
        ORDER BY RAND() 
        LIMIT 1
    """, (category,))
    monthly_pick = cursor.fetchone()

    cursor.execute("""
        SELECT * FROM products
        ORDER BY last_clicked DESC  -- Make sure last_clicked column exists and stores timestamp or click count
        LIMIT 10
    """)
    trending_products = cursor.fetchall()

    categories = ['Video Games', 'Consoles']
    categorized_products = {}

    for cat in categories:
        cursor.execute("""
            SELECT * FROM products
            WHERE product_category = %s
            ORDER BY created_at DESC
        """, (cat,))
        categorized_products[cat] = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template('buyer_gaming.html', 
                           monthly_pick=monthly_pick, 
                           trending_products=trending_products,
                           categorized_products=categorized_products)

@app.route('/buyer_educ')
def buyer_educ():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    category = 'Educational DVDs'
    cursor.execute("""
        SELECT * FROM products 
        WHERE product_category = %s
        ORDER BY RAND() 
        LIMIT 1
    """, (category,))
    monthly_pick = cursor.fetchone()

    cursor.execute("""
        SELECT * FROM products
        ORDER BY last_clicked DESC  -- Make sure last_clicked column exists and stores timestamp or click count
        LIMIT 10
    """)
    trending_products = cursor.fetchall()

    categories = ['Educational DVDs']
    categorized_products = {}

    for cat in categories:
        cursor.execute("""
            SELECT * FROM products
            WHERE product_category = %s
            ORDER BY created_at DESC
        """, (cat,))
        categorized_products[cat] = cursor.fetchall()

    cursor.close()
    connection.close()

  
    return render_template('buyer_educ.html', 
                           monthly_pick=monthly_pick, 
                           trending_products=trending_products,
                           categorized_products=categorized_products)


# adding to cart

def get_products_from_database():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = "SELECT id, product_image, product_name, product_category, product_quantity, product_price, product_description FROM products"
    cursor.execute(query)
    products = cursor.fetchall()

    cursor.close()
    conn.close()

    return products

@app.route('/your_route', methods=['GET'])
def your_view_function():
    user_surname = session.get('user_surname') 
    products = get_products_from_database()  
    return render_template('your_template.html', products=products, user_surname=user_surname)



@app.route('/add_to_cart', methods=['POST'])
def add_to_cart():
    user_id = session.get('user_id') 
    if not user_id:
        return jsonify({'success': False, 'error': 'User not logged in.'}), 401  

    data = request.get_json()
    product_name = data.get('product_name')
    quantity = data.get('quantity')
    price = data.get('price')
    product_image = data.get('product_image')

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute('''SELECT product_quantity FROM products WHERE product_name = %s''', (product_name,))
        product = cursor.fetchone()

        if not product:
            return jsonify({'success': False, 'error': 'Product not found.'}), 404

        available_stock = product[0]

        if quantity > available_stock:
            return jsonify({'success': False, 'error': 'Requested quantity exceeds available stock.'}), 400

        cursor.execute('''SELECT quantity FROM cart WHERE user_id = %s AND product_name = %s''', (user_id, product_name))
        existing_product = cursor.fetchone()

        if existing_product:
            new_quantity = existing_product[0] + quantity
            cursor.execute('''UPDATE cart SET quantity = %s, total_price = %s WHERE user_id = %s AND product_name = %s''', 
                           (new_quantity, price * new_quantity, user_id, product_name))
        else:
           
            cursor.execute('''INSERT INTO cart (user_id, product_name, quantity, price, product_image, total_price) 
                              VALUES (%s, %s, %s, %s, %s, %s)''', 
                           (user_id, product_name, quantity, price, product_image, price * quantity))
        
    
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'success': True})
    except Exception as e:
        print(f'Error occurred: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500





@app.route('/cart')
def cart():
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/login')

    cart_items = []
    products = []
    cart_updated = False
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Fetch the cart items for the user
        cursor.execute(
            '''SELECT c.id, c.product_image, c.product_name, c.quantity, c.price, 
                      (c.price * c.quantity) AS total_price, c.created_at, 
                      p.product_quantity AS stock_quantity 
               FROM cart c
               JOIN products p ON c.product_name = p.product_name
               WHERE c.user_id = %s''', (user_id,))
        cart_items = cursor.fetchall()

        for item in cart_items:
            if item['stock_quantity'] == 0:
                cursor.execute('DELETE FROM cart WHERE id = %s', (item['id'],))
                cart_updated = True
                flash(f"{item['product_name']} is out of stock and has been removed from your cart.", "warning")
            elif item['quantity'] > item['stock_quantity']:
                cursor.execute(
                    'UPDATE cart SET quantity = %s WHERE id = %s',
                    (item['stock_quantity'], item['id'])
                )
                cart_updated = True
                flash(
                    f"The quantity of {item['product_name']} in your cart has been adjusted to {item['stock_quantity']} due to limited stock.",
                    "info"
                )

        cursor.execute('SELECT id, product_name, product_image FROM products')
        products = cursor.fetchall()

        conn.commit()
        cursor.close()
        conn.close()

        if cart_updated:
            return redirect('/cart')

    except Exception as e:
        print(f"Error fetching data: {e}")
        cart_items = []
        products = []

    return render_template('cart.html', cart_items=cart_items, products=products)





@app.route('/delete_from_cart/<int:item_id>', methods=['DELETE'])
def delete_from_cart(item_id):
    user_id = session.get('user_id')  
    if not user_id:
        return jsonify({'success': False, 'error': 'User not logged in.'}), 401 

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute('DELETE FROM cart WHERE id = %s AND user_id = %s', (item_id, user_id))
        conn.commit()

        cursor.close()
        conn.close()
        
        return jsonify({'success': True})
    except Exception as e:
        print(f'Error occurred: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/delete_cart_items', methods=['DELETE'])
def delete_cart_items():
    data = request.get_json()
    item_ids = data.get('items', [])

    conn = get_db_connection()
    cursor = conn.cursor()
    if not item_ids:
        return jsonify({'success': False, 'message': 'No items to delete.'}), 400

    try:
        cursor.execute("DELETE FROM cart WHERE id IN (%s)" % ','.join(['%s'] * len(item_ids)), item_ids)
        conn.commit()
        return jsonify({'success': True, 'message': 'Items deleted successfully.'}), 200
    except Exception as e:
        conn.rollback() 
        return jsonify({'success': False, 'message': str(e)}), 500
    

# placing oredr
@app.route('/place_order', methods=['GET', 'POST'])
def place_order():
    user_id = session.get('user_id')

    if not user_id:
        return redirect('/login')  

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    if request.method == 'POST':
        data = request.get_json()
        new_address = data.get('new_address')

        if new_address:
            cursor.execute("SELECT COUNT(*) as address_count FROM addresses WHERE user_id = %s", (user_id,))
            address_count = cursor.fetchone()['address_count']

            if address_count >= 2:  
                return jsonify({
                    'success': False,
                    'message': "You can only add one additional address besides your default."
                })

            cursor.execute(
                "INSERT INTO addresses (user_id, address, is_default) VALUES (%s, %s, %s)",
                (user_id, new_address, 0)  # 0 means not default
            )
            connection.commit()
            return jsonify({'success': True, 'message': 'New address added successfully.'})

    cursor.execute("SELECT * FROM addresses WHERE user_id = %s", (user_id,))
    addresses = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template('place_order.html', addresses=addresses)



@app.route('/submit_order', methods=['POST'])
def submit_order():
    data = request.get_json()

    recipient_name = data.get('recipientName')
    shipping_address = data.get('shippingAddress')
    payment_method = data.get('paymentMethod')
    order_summary = data.get('orderSummary', [])
    buyer_id = session.get('user_id')  
    shipping_fee = data.get('shippingFee', 50)  # Default to 50 if not provided

    total_order_price = 0  

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        for item in order_summary:
            total_order_price += item['totalPrice']
        
        total_order_price += shipping_fee

        admin_commission = total_order_price * 0.05

        cursor.execute(""" 
            INSERT INTO orders (
                buyer_id, recipient_name, shipping_address, payment_method, total_price, shipping_fee, status, order_date, admin_commission
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, NOW(), %s)
        """, (
            buyer_id, recipient_name, shipping_address, payment_method, total_order_price, shipping_fee, 'Pending', admin_commission
        ))

        order_id = cursor.lastrowid

        for item in order_summary:
            cursor.execute(""" 
                INSERT INTO order_items (
                    order_id, product_name, quantity, total_price
                ) VALUES (%s, %s, %s, %s)
            """, (
                order_id, item['productName'], item['quantity'], item['totalPrice']
            ))

        conn.commit()

        return {'success': True, 'message': 'Order placed successfully!'}

    except Exception as e:
        conn.rollback()
        print(f"Error placing order: {e}")
        return {'success': False, 'message': 'Failed to place order.'}, 500

    finally:
        cursor.close()
        conn.close()






# for the saellers page

@app.route('/seller_home')
def seller_home():
    completed_orders_count = get_completed_orders_count()
    today_orders_count = get_today_orders_count()
    products_count = get_products_count()  
    return render_template('seller_dashboard.html', 
                           completed_orders_count=completed_orders_count, 
                           today_orders_count=today_orders_count,
                           products_count=products_count)  

def get_completed_orders_count():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM orders WHERE status = 'Completed'")
    completed_orders_count = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    return completed_orders_count

def get_today_orders_count():
    conn = get_db_connection()
    cursor = conn.cursor()
    today = datetime.today().date()
    query = """
        SELECT COUNT(*)
        FROM orders
        WHERE DATE(order_date) = %s AND status != 'Canceled'
    """
    cursor.execute(query, (today,))
    today_orders_count = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    return today_orders_count

def get_products_count():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM products")  
    products_count = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    return products_count





@app.route('/api/today_orders/<int:seller_id>')
def today_orders(seller_id):
    current_date=datetime.now().date()
    conn = get_db_connection()
    cursor = conn.cursor()
    
    today = date.today()
    
    cursor.execute("""
        SELECT COUNT(*) FROM orders 
        WHERE buyer_id = %s AND order_date = %s
    """, (seller_id, today))
    
    today_orders_count = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    return jsonify(today_orders=today_orders_count)



@app.route('/api/inventory/<int:seller_id>')
def inventory(seller_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT COUNT(*) FROM products 
        WHERE user_id = %s
    """, (seller_id,))
    
    inventory_count = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    return jsonify(inventory=inventory_count)

@app.route('/api/revenue/<int:seller_id>')
def revenue(seller_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT MONTH(order_date) AS month, SUM(total_price) AS total_revenue
        FROM orders
        WHERE buyer_id = %s AND status = 'Completed'
        GROUP BY month
    """, (seller_id,))
    
    revenue_data = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(revenue=revenue_data)

@app.route('/api/gross_sales/<int:seller_id>')
def gross_sales(seller_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT MONTH(order_date) AS month, SUM(total_price) AS gross_sales
        FROM orders
        WHERE buyer_id = %s
        GROUP BY month
    """, (seller_id,))
    
    sales_data = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(sales=sales_data)


@app.route('/archive_product/<int:id>', methods=['POST'])
def archive_product(id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("UPDATE products SET status = 'archived' WHERE id = %s", (id,))
        conn.commit()

    except Exception as e:
        print(f"Database error: {e}")
        return "An error occurred while archiving the product."

    finally:
        cursor.close()
        conn.close()

    return redirect(url_for('seller_inventory'))

@app.route('/archive_products')
def archive_products():
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/login')

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT id, product_name, product_description, product_category, 
                   product_price, product_quantity, product_image 
            FROM products 
            WHERE user_id = %s AND status = 'archived'
        """, (user_id,))
        archived_products = cursor.fetchall()

    except Exception as e:
        print(f"Database error: {e}")
        return "An error occurred while fetching archived products."

    finally:
        cursor.close()
        conn.close()

    return render_template('archive_products.html', archived_products=archived_products)

@app.route('/seller_inventory')
def seller_inventory():
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/login')

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(""" 
            SELECT id, product_name, product_description, product_category, 
                   product_price, product_quantity, product_image 
            FROM products WHERE user_id = %s AND status= 'active' """, (user_id,))

        products = cursor.fetchall()

    except Exception as e:
        print(f"Database error: {e}")
        return "An error occurred while fetching your inventory."

    finally:
        cursor.close()
        conn.close()

    return render_template('seller_inventory.html', products=products)

# para mag unarchive ng product

# Unarchive a product
@app.route('/unarchive_product/<int:id>', methods=['POST'])
def unarchive_product(id):
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/login')

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE products
            SET status = 'active'
            WHERE id = %s AND user_id = %s
        """, (id, user_id))

        conn.commit()

    except Exception as e:
        print(f"Database error: {e}")
        return "An error occurred while unarchiving the product."

    finally:
        cursor.close()
        conn.close()

    return redirect(url_for('archive_products'))




# Add new product
@app.route('/add_product', methods=['POST'])  
def add_product():
    if request.method == 'POST':
        product_name = request.form['product_name']
        product_description = request.form['product_description']
        product_category = request.form['product_category']
        product_price = request.form['product_price']
        product_quantity = request.form['product_quantity']


        user_id = session.get('user_id')
        if not user_id:
            return redirect('/login')  

        product_image = request.files['product_image']
        filename = secure_filename(product_image.filename)
        product_image.save(os.path.join(app.config['UPLOAD_FOLDER3'], filename))

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO products (user_id, product_name, product_description, 
                                  product_category, product_price, 
                                  product_quantity, product_image) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (user_id, product_name, product_description, product_category, 
              product_price, product_quantity, filename))
        conn.commit()

        cursor.close()
        conn.close()

        flash('New product added successfully!', 'success')
        return redirect(url_for('seller_inventory'))


@app.route('/update_product/<int:id>', methods=['POST'])
def update_product(id):
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/login') 

    product_name = request.form['product_name']
    product_description = request.form['product_description']
    product_category = request.form['product_category']
    product_price = request.form['product_price']
    product_quantity = request.form['product_quantity']
    product_image = request.files['product_image']

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT product_image FROM products WHERE id = %s", (id,))
        current_image = cursor.fetchone()[0]

        if product_image and product_image.filename != '':
            filename = secure_filename(product_image.filename)
            product_image.save(os.path.join(app.config['UPLOAD_FOLDER3'], filename))
        else:
            filename = current_image


        cursor.execute("""
            UPDATE products 
            SET product_name = %s, product_description = %s, 
                product_category = %s, product_price = %s, 
                product_quantity = %s, product_image = %s 
            WHERE id = %s AND user_id = %s
        """, (product_name, product_description, product_category, 
              product_price, product_quantity, filename, id, user_id))

        conn.commit()
        flash('Product updated successfully!', 'success')
    except Exception as e:
        conn.rollback()  
        flash(f'Error updating product: {str(e)}', 'danger')
    finally:
        cursor.close()
        conn.close()

    return redirect(url_for('seller_inventory'))


def get_completed_orders():
    connection = get_db_connection()
    cursor = connection.cursor()

    query = """
        SELECT id, recipient_name, total_price, shipping_fee, shipping_address, payment_method, status, order_date, estimated_delivery_date
        FROM orders
        WHERE status = 'Completed';
    """
    
    cursor.execute(query)
    completed_orders = cursor.fetchall()
    cursor.close()
    connection.close()

    return completed_orders


@app.route('/seller/transactions')
def seller_transactions():
    completed_orders = get_completed_orders()
    pending_orders = get_pending_orders()  # Fetch pending orders
    return render_template(
        'seller_transactions.html',
        completed_orders=completed_orders,
        pending_orders=pending_orders
    )
def get_pending_orders():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM orders WHERE status = 'Pending'")
    pending_orders = cursor.fetchall()
    conn.close()
    return pending_orders


@app.route('/update_status', methods=['POST'])
def update_status():
    data = request.json
    order_id = data.get('order_id')
    new_status = data.get('status')

    if not order_id or not new_status:
        return jsonify({'error': 'Order ID and status are required'}), 400

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    # Get current order status
    cursor.execute("SELECT status FROM orders WHERE id = %s", (order_id,))
    order = cursor.fetchone()

    if not order:
        cursor.close()
        connection.close()
        return jsonify({'error': 'Order not found'}), 404

    current_status = order['status']

    try:
        # ✅ Update order status
        cursor.execute("""
            UPDATE orders
            SET status = %s
            WHERE id = %s
        """, (new_status, order_id))
        connection.commit()

        # ✅ If status changed from 'Pending' to 'Pick Up', notify all couriers
        if current_status == "Pending" and new_status == "Pick Up":
            message = f"Order #{order_id} is ready for pick up."

            # 🔍 Get all courier user IDs
            cursor.execute("SELECT id FROM users WHERE user_type = 'courier'")
            couriers = cursor.fetchall()

            if couriers:  # Ensure couriers exist
                for courier in couriers:
                    courier_id = courier['id']
                    cursor.execute("""
                        INSERT INTO notifications (user_id, user_type, message, activity_type, is_read) 
                        VALUES (%s, %s, %s, %s, %s)
                    """, (courier_id, 'courier', message, 'Order Pick Up', 0))

                connection.commit()

        cursor.close()
        connection.close()
        return jsonify({'message': 'Order status updated successfully'})

    except Exception as e:
        connection.rollback()
        cursor.close()
        connection.close()
        return jsonify({'error': str(e)}), 500





# Seller's shipping status page
@app.route('/seller_shippingstatus')
def seller_shippingstatus():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
    SELECT 
        o.id AS order_id, 
        o.recipient_name, 
        o.shipping_address, 
        o.payment_method, 
        o.status, 
        GROUP_CONCAT(oi.product_name SEPARATOR ', ') AS products,  -- Combine product names
        GROUP_CONCAT(oi.quantity SEPARATOR ', ') AS quantities,  -- Combine product quantities
        SUM(oi.quantity) AS total_quantity,  -- Sum total quantities of products
        SUM(oi.total_price) + 50 AS total_price  -- Sum total prices and add shipping fee
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    WHERE o.status NOT IN ('Completed', 'Cancelled')  -- Exclude "Completed" and "Cancelled" statuses
    GROUP BY o.id, o.recipient_name, o.shipping_address, o.payment_method, o.status
    ORDER BY o.id
""")


    orders = cursor.fetchall()  # Fetch all results

    cursor.close()
    connection.close()

    return render_template('seller_shippingstatus.html', orders=orders)




@app.route('/seller_storesetting', methods=['GET', 'POST'])
def seller_storesetting():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    user_id = session.get('user_id')
    if not user_id:
        return redirect('/login')

    if request.method == 'POST':
        store_name = request.form.get('store_name')
        store_description = request.form.get('store_description')


        try:
            cursor.execute("SELECT * FROM stores WHERE seller_id = %s", (user_id,))
            store = cursor.fetchone()

            if store:
                cursor.execute("""
                    UPDATE stores
                    SET store_name = %s, store_description = %s
                    WHERE seller_id = %s
                """, (store_name, store_description,  user_id))
                flash("Store profile updated successfully!", "success")
            else:
                cursor.execute("""
                    INSERT INTO stores (seller_id, store_name, store_description)
                    VALUES (%s, %s, %s)
                """, (user_id, store_name, store_description))
                flash("Store profile created successfully!", "success")

            conn.commit()
        except Exception as e:
            conn.rollback()
            flash(f"An error occurred: {str(e)}", "danger")
        finally:
            return redirect(url_for('seller_storesetting'))

    cursor.execute("SELECT * FROM stores WHERE seller_id = %s", (user_id,))
    store = cursor.fetchone()

    conn.close()
    return render_template('seller_storesetting.html', store=store)



@app.route('/seller_accounts_changepass')
def seller_accounts_changepass():
    return render_template('seller_accounts_changepass.html')
@app.route('/update_password', methods=['POST'])
def update_password():
    if 'user_id' not in session:
        flash('You need to log in to change your password.', 'error')
        return redirect(url_for('login'))

    user_id = session['user_id']  
    old_password = request.form['oldpass']
    new_password = request.form['newpass']
    confirm_new_password = request.form['confirmnewpass']

    if new_password != confirm_new_password:
        flash('New password and confirmation do not match.', 'error')
        return redirect(url_for('seller_accounts_changepass'))

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        cursor.execute("SELECT password FROM users WHERE id = %s", (user_id,))
        result = cursor.fetchone()

        if not result:
            flash('User not found.', 'error')
            return redirect(url_for('seller_accounts_changepass'))

        current_password = result[0]

        if current_password != old_password:
            flash('Old password is incorrect.', 'error')
            return redirect(url_for('seller_accounts_changepass'))

        cursor.execute("UPDATE users SET password = %s WHERE id = %s", (new_password, user_id))
        connection.commit()

        flash('Password updated successfully.', 'success')
        return redirect(url_for('seller_accounts_changepass'))

    except Exception as e:
        flash(f'An error occurred: {str(e)}', 'error')
        return redirect(url_for('seller_accounts_changepass'))

    finally:
        cursor.close()
        connection.close()



@app.route('/seller_accounts_salesreport')
def seller_accounts_salesreport():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
SELECT 
    oi.id AS item_id,
    oi.product_name,
    oi.order_id,
    o.buyer_id,
    o.recipient_name,
    p.id AS product_id,
    p.user_id AS seller_id,
    oi.quantity,
    o.total_price AS total_sales_amount,  
    (o.total_price - o.admin_commission) AS seller_profit,  
    (o.total_price * 0.05) AS admin_commission, 
    o.estimated_delivery_date
FROM 
    orders o
JOIN 
    order_items oi ON o.id = oi.order_id
JOIN 
    products p ON p.product_name = oi.product_name
JOIN 
    users u_seller ON p.user_id = u_seller.id
WHERE 
    o.status = 'Completed'
ORDER BY 
    o.order_date DESC;
    """
    cursor.execute(query)
    sales_data = cursor.fetchall()
    
    return render_template('seller_accounts_salesreport.html', sales_data=sales_data)




@app.route('/seller_accounts', methods=['GET', 'POST'])
def seller_accounts():
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/login')

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        firstname = request.form['firstname']
        surname = request.form['surname']
        email = request.form['email']
        contact = request.form['contact']
        profile_picture = request.files.get('profile_picture')

        if profile_picture:
            filename = profile_picture.filename
            profile_picture_path = os.path.join('static', 'profile_pics', filename)
            profile_picture.save(profile_picture_path)
        else:
            profile_picture_path = request.form.get('current_profile_picture')

        # Update the seller's profile in the database
        cursor.execute("""
            UPDATE users
            SET firstname = %s, surname = %s, email = %s, contact = %s, profile_picture = %s
            WHERE id = %s AND user_type = 'seller'
        """, (firstname, surname, email, contact, profile_picture_path, user_id))

        conn.commit()
        conn.close()

        return redirect(url_for('seller_accounts'))

    cursor.execute("""
        SELECT firstname, surname, email, contact, profile_picture
        FROM users
        WHERE id = %s AND user_type = 'seller'
    """, (user_id,))
    seller_info = cursor.fetchone()
    conn.close()

    return render_template('seller_accounts.html', seller_info=seller_info)




@app.route('/seller_notification', methods=['GET'])
def seller_notification():
   

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, message, activity_type, is_read, created_at
        FROM notifications
        WHERE user_type = 'seller' 
        ORDER BY created_at DESC
    """, )

    notifications = cursor.fetchall()
    conn.close()

    print("Seller notifications:", notifications)

    return render_template('seller_notification.html', notifications=notifications)





# for messages
@app.route('/messages')
def messages():
    user_id = session.get('user_id')

    conn = get_db_connection()
    cursor = conn.cursor()
    query = '''
    SELECT m.product_name, m.message, m.sender_id, u.firstname, m.timestamp, m.recipient_id 
    FROM messages m
    JOIN users u ON u.id = m.sender_id
    WHERE m.sender_id = %s OR m.recipient_id = %s
    ORDER BY m.timestamp
    '''
    cursor.execute(query, (user_id, user_id))
    messages = cursor.fetchall()
    cursor.close()
    conn.close()

    conversations = {}
    for message in messages:
        key = (min(message[2], message[5]), max(message[2], message[5]), message[0])  # (buyer_id, seller_id, product_name)
        if key not in conversations:
            conversations[key] = []
        conversations[key].append(message)

    return render_template('messages.html', conversations=conversations)


@app.route('/send_reply', methods=['POST'])
def send_reply():
    data = request.get_json()
    message = data.get('message')
    sender_id = data.get('sender_id')
    recipient_id = data.get('recipient_id')
    product_name = data.get('product_name')

    if not message:
        return jsonify({'success': False, 'error': 'Message cannot be empty'})

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT user_type FROM users WHERE id = %s", (recipient_id,))
        recipient_user_type = cursor.fetchone()
        if not recipient_user_type:
            return jsonify({'success': False, 'error': 'Recipient not found'})

        recipient_user_type = recipient_user_type[0]

        cursor.execute('''
        INSERT INTO messages (sender_id, recipient_id, product_name, message, timestamp)
        VALUES (%s, %s, %s, %s, %s)
        ''', (sender_id, recipient_id, product_name, message, datetime.now()))

        cursor.execute('''
        INSERT INTO notifications (user_id, user_type, message, activity_type, is_read, created_at)
        VALUES (%s, %s, %s, %s, %s, %s)
        ''', (recipient_id, recipient_user_type, f"You have a new message about '{product_name}'", 'new_message', 0, datetime.now()))

        conn.commit()

    except Exception as e:
        conn.rollback()
        return jsonify({'success': False, 'error': str(e)})
    finally:
        cursor.close()
        conn.close()

    return jsonify({'success': True})


@app.route('/inquire.html', methods=['GET'])
def inquire():
    product_id = request.args.get('product_id')

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT product_name, user_id FROM products WHERE id = %s", (product_id,))
    product_info = cursor.fetchone()
    cursor.close()
    conn.close()

    if product_info:
        product_name = product_info[0]  
        seller_id = product_info[1]  
        return render_template('inquire.html', product_name=product_name, seller_id=seller_id, product_id=product_id)
    else:
        return "Product or seller not found", 404


@app.route('/send_inquiry', methods=['POST'])
def send_inquiry():
    product_id = request.form['product_id']
    seller_id = request.form['seller_id']
    buyer_id = session.get('user_id')  
    message = request.form['message']

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT product_name FROM products WHERE id = %s", (product_id,))
        product_info = cursor.fetchone()

        if product_info:
            product_name = product_info[0]

            query = """
            INSERT INTO messages (sender_id, recipient_id, product_name, message, timestamp)
            VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(query, (buyer_id, seller_id, product_name, message, datetime.now()))

            cursor.execute('''
            INSERT INTO notifications (user_id, user_type, message, activity_type, is_read, created_at)
            VALUES (%s, %s, %s, %s, %s, %s)
            ''', (seller_id, 'seller', f"New inquiry about '{product_name}' from Buyer ID {buyer_id}", 'new_inquiry', 0, datetime.now()))

            conn.commit()
            return jsonify({'success': True, 'message': 'Inquiry sent successfully!'}), 200
        else:
            return jsonify({'success': False, 'error': 'Failed to send inquiry. Product not found.'}), 404

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

    finally:
        cursor.close()
        conn.close()



# message naman sa pov ni seller
@app.route('/seller_accounts_message')
def seller_accounts_message():
    recipient_id = session.get('user_id') 
    return render_template('seller_accounts_message.html', recipient_id=recipient_id)


@app.route('/get_messages', methods=['GET'])
def get_messages():
    recipient_id = request.args.get('recipient_id')
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
    SELECT m.sender_id, m.recipient_id, m.product_name, m.message, m.timestamp
    FROM messages m
    WHERE m.recipient_id = %s OR m.sender_id = %s  -- Include both directions
    ORDER BY m.timestamp
    """
    
    cursor.execute(query, (recipient_id, recipient_id))  
    messages = cursor.fetchall()

    cursor.close()
    connection.close()
    return jsonify(messages)


@app.route('/seller/send_reply', methods=['POST'])
def seller_send_reply():
    data = request.get_json()
    message = data.get('message')
    sender_id = session.get('user_id')  
    recipient_id = data.get('recipient_id')  # Buyer's ID
    product_name = data.get('product_name', 'Unknown Product')

    if not message:
        return jsonify({'status': 'error', 'message': 'Message cannot be empty'}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        query = """
        INSERT INTO messages (sender_id, recipient_id, product_name, message, timestamp)
        VALUES (%s, %s, %s, %s, NOW())
        """
        cursor.execute(query, (sender_id, recipient_id, product_name, message))
        
        notification_query = """
        INSERT INTO notifications (user_id, user_type, message, activity_type, is_read, created_at)
        VALUES (%s, %s, %s, %s, %s, NOW())
        """
        notification_message = f"New reply from Seller about '{product_name}': {message[:50]}..."
        cursor.execute(notification_query, (recipient_id, 'buyer', notification_message, 'new_reply', 0))

        connection.commit()
        
    except Exception as e:
        connection.rollback()
        return jsonify({'status': 'error', 'message': str(e)}), 500
    
    finally:
        cursor.close()
        connection.close()

    return jsonify({'status': 'success', 'message': 'Reply sent and notification created successfully'})







@app.route('/search')
def search():
    query = request.args.get('query', '')
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if query:
        cursor.execute("""
            SELECT * FROM products 
            WHERE product_name LIKE %s OR product_category LIKE %s
        """, (f'%{query}%', f'%{query}%')) 
        results = cursor.fetchall()
    else:
        results = []  

    conn.close()

    return render_template('search_results.html', results=results, query=query)


# notif 


@app.route('/notifications')
def notifications():
    user_id = session.get('user_id')  
    if not user_id:
        return redirect('/login')


    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, message, activity_type, is_read, created_at
        FROM notifications
        WHERE user_id = %s
        ORDER BY created_at DESC
    """, (user_id,))

    notifications = cursor.fetchall() 
    conn.close()

    print("Admin notifications:", notifications)

    return render_template('notification.html', notifications=notifications)



# for courier

@app.route('/courier_home')
def courier_home():
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    # Get total number of orders
    cursor.execute("SELECT COUNT(*) AS total_orders FROM orders")
    total_orders = cursor.fetchone()['total_orders']
    
    # Get count of pending shipments
    cursor.execute("SELECT COUNT(*) AS pending_orders FROM orders WHERE status = 'Pending'")
    pending_orders = cursor.fetchone()['pending_orders']
    
    # Get count of completed shipments
    cursor.execute("SELECT COUNT(*) AS completed_orders FROM orders WHERE status = 'Completed'")
    completed_orders = cursor.fetchone()['completed_orders']
    
    cursor.close()
    db.close()

    return render_template(
        'courier_home.html', 
        total_orders=total_orders, 
        pending_orders=pending_orders, 
        completed_orders=completed_orders
    )

@app.route('/courier_topickup')
def courier_topickup():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
    SELECT 
        o.id AS parcel_id,
        p.user_id AS seller_id,
        CONCAT(u.firstname, ' ', u.surname) AS seller_name,
        u.address AS seller_address,
        GROUP_CONCAT(oi.product_name SEPARATOR ', ') AS products,
        GROUP_CONCAT(oi.quantity SEPARATOR ', ') AS quantities,
        SUM(oi.total_price) + 50 AS total_price,
        o.payment_method,
        o.status
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN products p ON oi.product_name = p.product_name
    JOIN users u ON p.user_id = u.id
    WHERE o.status = 'Pick Up'  -- Only include "To Pick Up" status
    GROUP BY o.id, u.firstname, u.surname, u.address, o.payment_method, o.status
    ORDER BY o.id
    """

    cursor.execute(query)
    topickup = cursor.fetchall()

    conn.close()

    return render_template('courier_topickup.html', orders=topickup)

@app.route('/courier_update_shipping_status/<int:order_id>', methods=['POST'])
def courier_update_shipping_status(order_id):
    new_status = request.form['status']
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT o.id, o.buyer_id, o.recipient_name, o.shipping_address 
        FROM orders o 
        WHERE o.id = %s
    """, (order_id,))
    order = cursor.fetchone()

    if not order:
        return "Order not found.", 404

    try:
        cursor.execute("""
            UPDATE orders 
            SET status = %s 
            WHERE id = %s
        """, (new_status, order_id))

        message = f"Your order #{order_id} has been updated to '{new_status}'."
        cursor.execute("""
            INSERT INTO notifications (user_id, user_type, message, activity_type)
            VALUES (%s, 'buyer', %s, 'Order Update')
        """, (order['buyer_id'], message))

        connection.commit()
    except Exception as e:
        connection.rollback()
        return f"An error occurred: {str(e)}", 500
    finally:
        cursor.close()
        connection.close()

    return redirect(url_for('courier_topickup'))


@app.route('/courier_pending')
def courier_pending():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
    SELECT 
        o.id AS order_id, 
        o.recipient_name, 
        o.shipping_address, 
        o.payment_method, 
        o.status, 
        GROUP_CONCAT(oi.product_name SEPARATOR ', ') AS products,  -- Combine product names
        GROUP_CONCAT(oi.quantity SEPARATOR ', ') AS quantities,  -- Combine product quantities
        SUM(oi.quantity) AS total_quantity,  -- Sum total quantities of products
        SUM(oi.total_price) + 50 AS total_price  -- Sum total prices and add shipping fee
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    WHERE o.status = 'toship'
    GROUP BY o.id, o.recipient_name, o.shipping_address, o.payment_method, o.status
    ORDER BY o.id
""")


    orders = cursor.fetchall()  # Fetch all results

    cursor.close()
    connection.close()



    return render_template('courier_pendings.html'  , orders=orders)

@app.route('/courier_update_order_status/<int:order_id>', methods=['POST'])
def courier_update_order_status(order_id):
    new_status = request.form['status']
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT o.id, o.buyer_id, o.recipient_name, o.shipping_address 
        FROM orders o 
        WHERE o.id = %s
    """, (order_id,))
    order = cursor.fetchone()

    if not order:
        return "Order not found.", 404

    try:
        cursor.execute("""
            UPDATE orders 
            SET status = %s 
            WHERE id = %s
        """, (new_status, order_id))

        message = f"Your order #{order_id} has been updated to '{new_status}'."
        cursor.execute("""
            INSERT INTO notifications (user_id, user_type, message, activity_type)
            VALUES (%s, 'buyer', %s, 'Order Update')
        """, (order['buyer_id'], message))

        connection.commit()
    except Exception as e:
        connection.rollback()
        return f"An error occurred: {str(e)}", 500
    finally:
        cursor.close()
        connection.close()

    return redirect(url_for('courier_pending'))



@app.route('/courier_delivered')
def courier_delivered():
    completed_orders = get_completed_orders()
    return render_template('courier_delivered.html', completed_orders=completed_orders)

@app.route('/courier_settings')
def courier_settings():

    return render_template('courier_settings.html')


@app.route('/courier_notification', methods=['GET'])
def courier_notification():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, message, activity_type, is_read, created_at
        FROM notifications
        WHERE user_type = 'courier' 
        ORDER BY created_at DESC
    """)

    notifications = cursor.fetchall()
    conn.close()

    print("Courier notifications:", notifications)

    return render_template('courier_notif.html', notifications=notifications)






# ********************************************************for mobile ******************************
@app.route('/api/login', methods=['POST'])
def api_login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM users WHERE email = %s AND password = %s", (email, password))
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    if user:
        user_type = user['user_type']
        status = user.get('status')
        is_admin = user['is_admin']

        # Send user info back to Flutter
        return jsonify({
            'success': True,
            'user_id': user['id'],
            'surname': user['surname'],
            'firstname': user['firstname'],
            'middle_initial': user['middle_initial'],
            'address': user.get('address'),
            'user_type': user_type,
            'is_admin': is_admin,
            'status': status
        })
    else:
        return jsonify({'success': False, 'message': 'Incorrect email or password'})


otp_store = {}
@app.route('/api/verify_email', methods=['POST'])
def api_verify_email():
    data = request.get_json()
    email = data.get('email')

    if not email or '@' not in email:
        return jsonify({'success': False, 'message': 'Invalid email address'}), 400

    otp = generate_otp()
    otp_store[email] = otp  # Store OTP in in-memory dictionary
    print(f"[API] Sent OTP to {email}: {otp}")

    # Send the email
    send_otp_email(email, otp)

    return jsonify({
        'success': True,
        'message': 'OTP sent to your email. Please check your inbox.'
    })


@app.route('/api/send_otp', methods=['POST'])
def send_otp():
    data = request.get_json()
    email = data.get('email')
    otp = generate_otp()

    otp_store[email] = otp  # Store OTP per email
    print(f"Generated OTP for {email}: {otp}")

    return jsonify({'success': True, 'message': 'OTP sent.'})

@app.route('/api/enter_otp', methods=['POST'])
def api_enter_otp():
    data = request.get_json()
    entered_otp = data.get('otp')
    email = data.get('email')

    expected_otp = otp_store.get(email)
    print(f"[VERIFY] Email: {email} | Entered OTP: {entered_otp} | Expected OTP: {expected_otp}")

    if entered_otp == expected_otp:
        return jsonify({'success': True, 'message': 'Email verified! Proceed to registration.'})
    else:
        return jsonify({'success': False, 'message': 'Invalid OTP. Please try again.'}), 400

# forgot password
@app.route('/api/forgot_verify_email', methods=['POST'])
def api_forgot_verify_email():
    data = request.get_json()
    email = data.get('email')

    if not email or '@' not in email:
        return jsonify({'success': False, 'message': 'Invalid email address'}), 400

    otp = generate_otp()
    otp_store[email] = otp  # Store OTP in in-memory dictionary
    print(f"[API] Sent OTP to {email}: {otp}")

    # Send the email
    send_otp_email(email, otp)

    return jsonify({
        'success': True,
        'message': 'OTP sent to your email. Please check your inbox.'
    })

    
@app.route('/api/forgot_verify_otp', methods=['POST'])
def forgot_verify_otp():
    data = request.get_json()
    entered_otp = data.get('otp')
    email = data.get('email')

    expected_otp = otp_store.get(email)
    print(f"[VERIFY] Email: {email} | Entered OTP: {entered_otp} | Expected OTP: {expected_otp}")

    if entered_otp == expected_otp:
        return jsonify({'success': True, 'message': 'Email verified! Proceed to registration.'})
    else:
        return jsonify({'success': False, 'message': 'Invalid OTP. Please try again.'}), 400


@app.route('/api/reset_password', methods=['POST'])
def api_reset_password():
    data = request.get_json()
    email = data.get('email')
    new_password = data.get('new_password')

    is_valid, msg = validate_password(new_password)
    if not is_valid:
        return jsonify({'success': False, 'message': msg}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE users SET password = %s WHERE email = %s", (new_password, email))
    conn.commit()
    updated = cursor.rowcount
    cursor.close()
    conn.close()

    if updated:
        return jsonify({'success': True, 'message': 'Password reset successfully.'})
    else:
        return jsonify({'success': False, 'message': 'Email not found.'}), 404


@app.route('/api/buyer_home_mobile')
def buyer_home_mobile():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT p.id, p.product_price, p.product_image, p.product_name, 
               p.product_quantity, COALESCE(AVG(f.rating), 0) AS average_rating
        FROM products p
        LEFT JOIN feedback f ON p.product_name = f.product_name
        WHERE p.status = 'active'
        GROUP BY p.id
    """)
    all_products = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify({'all_products': all_products})  # Changed key from 'trending_products' to 'all_products'

@app.route('/api/search_products', methods=['GET'])
def search_products():
    query = request.args.get('query', '').strip()

    if not query:
        return jsonify({'success': False, 'message': 'Query cannot be empty'}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT * FROM products 
        WHERE product_name LIKE %s OR product_description LIKE %s
    """, (f'%{query}%', f'%{query}%'))

    results = cursor.fetchall()
    cursor.close()
    conn.close()

    if not results:
        return jsonify({'success': False, 'message': 'No products found'}), 404

    return jsonify({'success': True, 'results': results})


# TRY WITH FEEDBACK
@app.route('/api/get_product_details/<int:product_id>', methods=['GET'])
def get_product_details(product_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Get product details with average rating
    cursor.execute("""
        SELECT p.id, p.product_price, p.product_image, p.product_name, 
            p.product_quantity, p.product_description, p.user_id,
            COALESCE(AVG(f.rating), 0) AS average_rating
        FROM products p
        LEFT JOIN feedback f ON p.product_name = f.product_name
        WHERE p.status = 'active' AND p.id = %s
        GROUP BY p.id
    """, (product_id,))

    
    product = cursor.fetchone()

    feedbacks = []
    if product:
        cursor.execute("""
            SELECT comment, rating, photo, created_at
            FROM feedback
            WHERE product_name = %s
            ORDER BY created_at DESC
        """, (product['product_name'],))
        feedbacks = cursor.fetchall()

    cursor.close()
    conn.close()

    if product:
        return jsonify({'product': product, 'feedbacks': feedbacks})
    else:
        return jsonify({'error': 'Product not found'}), 404



@app.route('/api/get_product_feedback/<int:product_id>', methods=['GET'])
def get_product_feedback(product_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Kunin ang product name gamit ang product_id
    cursor.execute("SELECT product_name FROM products WHERE id = %s", (product_id,))
    product = cursor.fetchone()

    if not product:
        return jsonify({'feedbacks': [], 'error': 'Product not found'}), 404

    product_name = product['product_name']

    # Kunin lahat ng feedback para sa product name
    cursor.execute("""
        SELECT comment, rating, created_at
        FROM feedback
        WHERE product_name = %s
        ORDER BY created_at DESC
    """, (product_name,))

    feedbacks = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify({'feedbacks': feedbacks})



@app.route('/api/add_to_cart', methods=['POST'])
def add_to_cart_mobile():
    data = request.get_json()

    # Check if user_id is provided in the request
    user_id = data.get('user_id')  # <-- galing sa Flutter POST body
    if not user_id:
        return jsonify({'success': False, 'error': 'User not logged in.'}), 401  # 401 Unauthorized if user_id is missing

    product_name = data.get('product_name')
    quantity = data.get('quantity')
    price = data.get('price')
    product_image = data.get('product_image')

    if not all([product_name, quantity, price, product_image]):
        return jsonify({'success': False, 'error': 'Missing fields'}), 400  # 400 Bad Request if missing other fields

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Fetch product quantity from the database
        cursor.execute('''SELECT product_quantity FROM products WHERE product_name = %s''', (product_name,))
        product = cursor.fetchone()

        if not product:
            return jsonify({'success': False, 'error': 'Product not found.'}), 404  # 404 Not Found if product is missing

        available_stock = product[0]

        # Check if the requested quantity is greater than available stock
        if quantity > available_stock:
            return jsonify({'success': False, 'error': 'Requested quantity exceeds available stock.'}), 400  # 400 Bad Request if stock is insufficient

        # Check if the product is already in the cart
        cursor.execute('''SELECT quantity FROM cart WHERE user_id = %s AND product_name = %s''', (user_id, product_name))
        existing_product = cursor.fetchone()

        if existing_product:
            # Update the quantity if product is already in the cart
            new_quantity = existing_product[0] + quantity
            cursor.execute('''UPDATE cart SET quantity = %s, total_price = %s 
                              WHERE user_id = %s AND product_name = %s''', 
                           (new_quantity, price * new_quantity, user_id, product_name))
        else:
            # Insert new product into the cart if it doesn't exist already
            cursor.execute('''INSERT INTO cart (user_id, product_name, quantity, price, product_image, total_price) 
                              VALUES (%s, %s, %s, %s, %s, %s)''',
                           (user_id, product_name, quantity, price, product_image, price * quantity))
        
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'success': True})

    except Exception as e:
        print(f'Error occurred: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500  # 500 Internal Server Error if there's any exception

@app.route('/api/cart', methods=['POST'])
def mobile_cart():
    user_id = request.json.get('user_id')
    if not user_id:
        return jsonify({'error': 'User ID is required'}), 400

    cart_items = []
    messages = []
    cart_updated = False

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Fetch cart items
        cursor.execute(
            '''SELECT c.id, c.product_image, c.product_name, c.quantity, c.price, 
                      (c.price * c.quantity) AS total_price, c.created_at, 
                      p.product_quantity AS stock_quantity 
               FROM cart c
               JOIN products p ON c.product_name = p.product_name
               WHERE c.user_id = %s''', (user_id,))
        cart_items = cursor.fetchall()

        for item in cart_items:
            if item['stock_quantity'] == 0:
                cursor.execute('DELETE FROM cart WHERE id = %s', (item['id'],))
                cart_updated = True
                messages.append({
                    "type": "warning",
                    "text": f"{item['product_name']} is out of stock and was removed."
                })
            elif item['quantity'] > item['stock_quantity']:
                cursor.execute(
                    'UPDATE cart SET quantity = %s WHERE id = %s',
                    (item['stock_quantity'], item['id'])
                )
                cart_updated = True
                messages.append({
                    "type": "info",
                    "text": f"{item['product_name']} quantity adjusted to {item['stock_quantity']}."
                })

        if cart_updated:
            conn.commit()

        # Fetch updated cart
        cursor.execute(
            '''SELECT c.id, c.product_image, c.product_name, c.quantity, c.price, 
                      (c.price * c.quantity) AS total_price, c.created_at 
               FROM cart c
               WHERE c.user_id = %s''', (user_id,))
        updated_cart_items = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify({
            "cart_items": updated_cart_items,
            "messages": messages
        }), 200

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': 'Failed to fetch cart'}), 500

# place order
# -----------------------------------------
# Add or fetch addresses for a mobile user
# -----------------------------------------
@app.route('/api/place_order', methods=['POST'])
def place_order_mobile():
    data = request.get_json()
    user_id = data.get('userId')  # From Flutter
    new_address = data.get('newAddress')

    if not user_id:
        return jsonify({'success': False, 'message': 'User ID is required'}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        if new_address:
            cursor.execute("SELECT COUNT(*) as address_count FROM addresses WHERE user_id = %s", (user_id,))
            address_count = cursor.fetchone()['address_count']

            if address_count >= 2:
                return jsonify({
                    'success': False,
                    'message': "You can only add one additional address besides your default."
                })

            cursor.execute("""
                INSERT INTO addresses (user_id, address, is_default)
                VALUES (%s, %s, %s)
            """, (user_id, new_address, 0))
            conn.commit()

        cursor.execute("SELECT * FROM addresses WHERE user_id = %s", (user_id,))
        addresses = cursor.fetchall()

        return jsonify({'success': True, 'addresses': addresses})

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'success': False, 'message': 'Error fetching/adding address'}), 500

    finally:
        cursor.close()
        conn.close()

# -----------------------------------------
# Submit order from mobile
# -----------------------------------------
@app.route('/api/submit_order', methods=['POST'])
def submit_order_mobile():
    data = request.get_json()

    buyer_id = data.get('userId')
    recipient_name = data.get('recipientName')
    shipping_address = data.get('shippingAddress')
    payment_method = data.get('paymentMethod')
    order_summary = data.get('orderSummary', [])
    shipping_fee = data.get('shippingFee', 50)

    if not all([buyer_id, recipient_name, shipping_address, payment_method]):
        return jsonify({'success': False, 'message': 'Missing required fields'}), 400

    total_order_price = sum(item['totalPrice'] for item in order_summary)
    total_order_price += shipping_fee
    admin_commission = total_order_price * 0.05

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Insert into orders
        cursor.execute("""
            INSERT INTO orders (
                buyer_id, recipient_name, shipping_address, payment_method,
                total_price, shipping_fee, status, order_date, admin_commission
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, NOW(), %s)
        """, (
            buyer_id, recipient_name, shipping_address, payment_method,
            total_order_price, shipping_fee, 'Pending', admin_commission
        ))

        order_id = cursor.lastrowid

        # Insert order items
        for item in order_summary:
            cursor.execute("""
                INSERT INTO order_items (order_id, product_name, quantity, total_price)
                VALUES (%s, %s, %s, %s)
            """, (
                order_id, item['productName'], item['quantity'], item['totalPrice']
            ))

        # Insert notification for buyer
        notification_message = f"Your order #{order_id} has been successfully placed!"
        cursor.execute("""
            INSERT INTO notifications (user_id, user_type, message, activity_type)
            VALUES (%s, %s, %s, %s)
        """, (
            buyer_id, 'buyer', notification_message, 'Order Placement'
        ))

        conn.commit()
        return jsonify({'success': True, 'message': 'Order placed successfully!'})

    except Exception as e:
        conn.rollback()
        print(f"Order Error: {e}")
        return jsonify({'success': False, 'message': 'Failed to place order'}), 500

    finally:
        cursor.close()
        conn.close()

@app.route('/api/get_buyer/<int:user_id>', methods=['GET'])
def get_buyer_mobile(user_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        
        cursor.execute("""
            SELECT CONCAT(firstname, ' ', surname) AS name, address 
            FROM users 
            WHERE id = %s AND user_type = 'buyer'
        """, (user_id,))
        buyer = cursor.fetchone()

        if not buyer:
            return jsonify({'error': 'Buyer not found'}), 404

        return jsonify({
            'name': buyer['name'],
            'address': buyer['address']
        })

    except Exception as e:
        print(f"API Error (get_buyer): {e}")
        return jsonify({'error': 'Failed to fetch buyer data'}), 500

    finally:
        cursor.close()
        conn.close()




# notif
@app.route('/api/notifications/<int:user_id>', methods=['GET'])
def get_notifications(user_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
    SELECT id, message, activity_type, user_type, created_at
    FROM notifications
    WHERE user_id = %s AND user_type = 'buyer'
    ORDER BY created_at DESC
    """, (user_id,))

    rows = cursor.fetchall()

    notifications = []
    for row in rows:
        activity_type = row['activity_type'] or ''
        title = ''

        if activity_type == 'order_completed':
            title = 'Order completed'
        elif activity_type == 'chat':
            title = 'New message'
        elif activity_type == 'order':
            title = 'Order update'
        else:
            title = activity_type.replace('_', ' ').title() if activity_type else 'Notification'

        notifications.append({
            'id': row['id'],
            'message': row['message'],
            'type': activity_type,
            'sender': row['user_type'],
            'time': row['created_at'].strftime('%Y-%m-%d %I:%M %p'),  # Updated format
            'datetime': row['created_at'].strftime('%Y-%m-%d %H:%M:%S'),
            'title': title
        })

    return jsonify(notifications)

# message
# chatlist
@app.route('/api/messages')
def api_get_messages():
    user_id = request.args.get('user_id', type=int)

    if not user_id:
        return jsonify({'error': 'Missing user_id'}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Group by conversation (other user + product name) and get latest message
    query = f"""
    SELECT
        IF(sender_id = %s, recipient_id, sender_id) AS other_user_id,
        product_name,
        (
            SELECT firstname  -- ← or full_name / username
            FROM users
            WHERE id = IF(sender_id = %s, recipient_id, sender_id)
        ) AS other_user_name,
        message AS last_message,
        timestamp
    FROM messages
    WHERE sender_id = %s OR recipient_id = %s
    ORDER BY timestamp DESC
"""


    cursor.execute(query, (user_id, user_id, user_id, user_id))
    rows = cursor.fetchall()

    seen = set()
    unique_conversations = []

    for row in rows:
        key = (row['other_user_id'], row['product_name'])
        if key not in seen:
            unique_conversations.append(row)
            seen.add(key)

    cursor.close()
    conn.close()

    return jsonify(unique_conversations)

# convo
@app.route('/api/conversation')
def api_get_conversation():
    user_id = request.args.get('user_id', type=int)
    other_user_id = request.args.get('other_user_id', type=int)
    product_name = request.args.get('product_name')

    if not user_id or not other_user_id or not product_name:
        return jsonify({'error': 'Missing parameters'}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
        SELECT sender_id, recipient_id, message, timestamp
        FROM messages
        WHERE
            (
                (sender_id = %s AND recipient_id = %s)
                OR
                (sender_id = %s AND recipient_id = %s)
            )
            AND product_name = %s
        ORDER BY timestamp ASC
    """
    cursor.execute(query, (user_id, other_user_id, other_user_id, user_id, product_name))
    messages = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify(messages)


# makapag send si buyer
@app.route('/api/send_message', methods=['POST'])
def send_message():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    data = request.json
    sender_id = data.get('sender_id')
    recipient_id = data.get('recipient_id')
    product_name = data.get('product_name')
    message = data.get('message')

    if not all([sender_id, recipient_id, product_name, message]):
        return jsonify({'error': 'Missing required fields'}), 400

    try:
        query = """
            INSERT INTO messages (sender_id, recipient_id, product_name, message)
            VALUES (%s, %s, %s, %s)
        """
        cursor.execute(query, (sender_id, recipient_id, product_name, message))
        conn.commit()
        return jsonify({'status': 'Message sent'}), 200
    except Exception as e:
        print("Error sending message:", e)
        return jsonify({'error': 'Internal server error'}), 500
    finally:
        cursor.close()
        conn.close()




# order history
@app.route('/api/orders/<status>', methods=['GET'])
def get_orders_by_status(status):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
    SELECT o.id AS order_id, o.recipient_name, o.shipping_address, o.payment_method,
           o.total_price, o.order_date, o.estimated_delivery_date, o.date_delivered,
           oi.product_name, oi.quantity, p.product_image
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN products p ON oi.product_name = p.product_name
    WHERE LOWER(o.status) = %s
    ORDER BY o.order_date DESC
"""

    cursor.execute(query, (status.lower(),))
    orders = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify(orders)


# order history (cancel orders)
@app.route('/api/cancel_order/<int:order_id>', methods=['POST'])
def api_cancel_order(order_id):
    data = request.form or request.get_json()
    reason = data.get('cancellation_reason')

    if not reason:
        return jsonify({'error': 'Cancellation reason is required.'}), 400

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("SELECT id, buyer_id FROM orders WHERE id = %s", (order_id,))
    order = cursor.fetchone()

    if not order:
        return jsonify({'error': 'Order not found.'}), 404

    try:
        cursor.execute("""
            UPDATE orders
            SET status = 'Cancelled', cancellation_reason = %s
            WHERE id = %s
        """, (reason, order_id))

        message = f"Your order #{order_id} has been cancelled. Reason: {reason}."
        cursor.execute("""
            INSERT INTO notifications (user_id, user_type, message, activity_type)
            VALUES (%s, 'seller', %s, 'Order Cancellation')
        """, (order['buyer_id'], message))

        connection.commit()
    except Exception as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

    return jsonify({'message': 'Order cancelled successfully.'}), 200

# order history (order received)
@app.route('/api/order_received/<int:order_id>', methods=['POST'])
def mark_order_received(order_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM orders WHERE id = %s", (order_id,))
    order = cursor.fetchone()

    if not order:
        return jsonify({'error': 'Order not found'}), 404

    try:
        cursor.execute("""
            UPDATE orders
            SET status = 'Completed', date_delivered = NOW()
            WHERE id = %s
        """, (order_id,))

        message = f"Order #{order_id} was marked as received by the buyer."

        cursor.execute("""
            INSERT INTO notifications (user_id, user_type, message, activity_type)
            VALUES (%s, 'seller', %s, 'Order Completed')
        """, (order['buyer_id'], message))

        conn.commit()
        return jsonify({'message': 'Order marked as received'})
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# order history (return)
@app.route('/api/return_order/<int:order_id>', methods=['POST'])
def return_order(order_id):
    data = request.get_json()
    reason = data.get('reason')

    if not reason:
        return jsonify({'error': 'Return reason is required'}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM orders WHERE id = %s", (order_id,))
    order = cursor.fetchone()

    if not order:
        return jsonify({'error': 'Order not found'}), 404

    try:
        cursor.execute("""
            UPDATE orders
            SET status = 'Returned', return_reasons = %s, return_date = NOW()
            WHERE id = %s
        """, (reason, order_id))

        message = f"Order #{order_id} was returned. Reason: {reason}"

        cursor.execute("""
            INSERT INTO notifications (user_id, user_type, message, activity_type)
            VALUES (%s, 'seller', %s, 'Order Returned')
        """, (order['buyer_id'], message))

        conn.commit()
        return jsonify({'message': 'Order marked as returned'})
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()



@app.route('/api/submit_feedback', methods=['POST'])
def api_submit_feedback():
    order_id = request.form.get('order_id')
    comment = request.form.get('comment')
    rating = request.form.get('rating')
    product_name = request.form.get('product_name')  
    
    photo = request.files.get('photo')
    photo_filename = None

    if photo:
        photo_filename = secure_filename(photo.filename)
        photo.save(os.path.join(app.config['UPLOAD_FOLDER4'], photo_filename))

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO feedback (order_id, comment, rating, product_name, photo) 
            VALUES (%s, %s, %s, %s, %s)
        """, (order_id, comment, rating, product_name, photo_filename))
        
        conn.commit()
        conn.close()

        return jsonify({'success': True, 'message': 'Feedback submitted successfully'}), 200

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# profile
@app.route('/api/buyer/profile/<int:user_id>', methods=['GET'])
def get_buyer_profile(user_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT id, firstname, email, id_upload FROM users WHERE id = %s", (user_id,))
        user = cursor.fetchone()

        if user:
            return jsonify(user), 200
        else:
            return jsonify({'error': 'User not found'}), 404

    except Exception as e:
        return jsonify({'error': str(e)}), 500

    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

# edit profile
@app.route('/api/buyer/<int:user_id>/profile', methods=['GET'])
def api_get_buyer_profile(user_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT id, surname, firstname, middle_initial, email, contact, address, password FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    conn.close()

    if user:
        return jsonify(user), 200
    else:
        return jsonify({'error': 'User not found'}), 404


@app.route('/api/buyer/<int:user_id>/profile', methods=['POST'])
def update_buyer_profile(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    surname = request.form.get('surname')
    firstname = request.form.get('firstname')
    middle_initial = request.form.get('middle_initial')
    email = request.form.get('email')
    contact = request.form.get('contact')
    address = request.form.get('address')
    password = request.form.get('password')  # Only if you're allowing password update

    try:
        cursor.execute("""
            UPDATE users
            SET surname = %s, firstname = %s, middle_initial = %s,
                email = %s, contact = %s, address = %s, password = %s
            WHERE id = %s
        """, (surname, firstname, middle_initial, email, contact, address, password, user_id))

        conn.commit()
        return jsonify({'message': 'Profile updated successfully!'}), 200
    except Exception as e:
        print("Update Error:", e)
        return jsonify({'message': 'Failed to update profile.', 'error': str(e)}), 500
    finally:
        conn.close()




# **********************************************COURIER*********************************************************
@app.route('/api/courier_home', methods=['GET'])
def courier_home_data():
    try:
        db = get_db_connection()
        cursor = db.cursor(dictionary=True)

        cursor.execute("SELECT COUNT(*) AS total_orders FROM orders")
        total_orders = cursor.fetchone().get('total_orders', 0)

        cursor.execute("SELECT COUNT(*) AS to_pickup FROM orders WHERE status = 'Pick Up'")
        to_pickup = cursor.fetchone().get('to_pickup', 0)

        cursor.execute("SELECT COUNT(*) AS pending_orders FROM orders WHERE status = 'Pending'")
        pending_orders = cursor.fetchone().get('pending_orders', 0)

        cursor.execute("SELECT COUNT(*) AS completed_orders FROM orders WHERE status = 'Completed'")
        completed_orders = cursor.fetchone().get('completed_orders', 0)

        return jsonify({
            'total_orders': total_orders,
            'to_pickup': to_pickup,
            'pending_orders': pending_orders,
            'completed_orders': completed_orders
        })

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': 'Server error'}), 500

    finally:
        cursor.close()
        db.close()

# topickup
@app.route('/api/courier_topickup', methods=['GET'])
def api_courier_topickup():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
    SELECT 
        o.id AS parcel_id,
        p.user_id AS seller_id,
        CONCAT(u.firstname, ' ', u.surname) AS seller_name,
        u.address AS seller_address,
        GROUP_CONCAT(oi.product_name SEPARATOR ', ') AS products,
        GROUP_CONCAT(oi.quantity SEPARATOR ', ') AS quantities,
        SUM(oi.total_price) + 50 AS total_price,
        o.payment_method,
        o.status
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN products p ON oi.product_name = p.product_name
    JOIN users u ON p.user_id = u.id
    WHERE o.status = 'Pick Up'
    GROUP BY o.id, u.firstname, u.surname, u.address, o.payment_method, o.status
    ORDER BY o.id
    """

    cursor.execute(query)
    topickup = cursor.fetchall()
    conn.close()

    return jsonify(topickup)
@app.route('/api/update_status', methods=['POST'])
def api_update_status():
    data = request.get_json()
    parcel_id = data.get('parcel_id')
    new_status = data.get('new_status')

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        "UPDATE orders SET status = %s WHERE id = %s",
        (new_status, parcel_id)
    )
    conn.commit()
    conn.close()

    return jsonify({'message': 'Status updated successfully'})


# toship
@app.route('/api/toship', methods=['GET'])
def api_toship():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
        SELECT 
            orders.id AS parcel_id,
            orders.recipient_name,
            orders.shipping_address,
            orders.payment_method,
            DATE_FORMAT(orders.order_date, '%%Y-%%m-%%d') AS order_date,
            DATE_FORMAT(orders.estimated_delivery_date, '%%Y-%%m-%%d') AS estimated_delivery_date,
            GROUP_CONCAT(order_items.product_name SEPARATOR ', ') AS product_names,
            GROUP_CONCAT(order_items.quantity SEPARATOR ', ') AS quantities,
            orders.total_price
        FROM orders
        JOIN order_items ON orders.id = order_items.order_id
        WHERE orders.status = 'toship'
        GROUP BY orders.id
        ORDER BY orders.order_date DESC
    """
    
    cursor.execute(query)
    orders = cursor.fetchall()
    conn.close()

    return jsonify(orders)



@app.route('/api/mark_out_for_delivery/<int:parcel_id>', methods=['POST'])
def mark_out_for_delivery(parcel_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            "UPDATE orders SET status = 'outfordelivery' WHERE id = %s", (parcel_id,)
        )
        conn.commit()
        return jsonify({'message': 'Order marked as out for delivery'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()


# OUT FOR DELIVERY
@app.route('/api/ofd', methods=['GET'])
def api_ofd():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
    SELECT 
        orders.id AS parcel_id,
        orders.recipient_name,
        orders.shipping_address,
        orders.total_price,
        GROUP_CONCAT(order_items.product_name SEPARATOR ', ') AS product_names,
        GROUP_CONCAT(order_items.quantity SEPARATOR ', ') AS quantities
    FROM orders
    JOIN order_items ON orders.id = order_items.order_id
    WHERE orders.status = 'outfordelivery'
    GROUP BY orders.id
    """

    cursor.execute(query)
    ofd_orders = cursor.fetchall()

    conn.close()

    return jsonify({'status': 'success', 'orders': ofd_orders})

@app.route('/api/mark_completed/<int:parcel_id>', methods=['POST'])
def api_mark_completed(parcel_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            "UPDATE orders SET status = 'Completed' WHERE id = %s", (parcel_id,)
        )
        conn.commit()
        return jsonify({'message': 'Order marked as out for completed'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

# delivered
@app.route('/api/completed', methods=['GET'])
def api_completed():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
    SELECT 
        orders.id AS order_id,
        order_items.product_name,
        order_items.quantity,
        orders.total_price,
        orders.recipient_name,
        orders.shipping_address,
        orders.payment_method,
        orders.order_date,
        orders.date_delivered,
        orders.status
    FROM orders
    JOIN order_items ON orders.id = order_items.order_id
    WHERE orders.status = 'Completed'
    """

    cursor.execute(query)
    completed_orders = cursor.fetchall()

    conn.close()

    return jsonify({'status': 'success', 'orders': completed_orders})


@app.route('/api/user/<int:user_id>', methods=['GET'])
def get_user(user_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    if user:
        return jsonify(user)
    else:
        return jsonify({'error': 'User not found'}), 404

@app.route('/api/change_password', methods=['POST'])
def change_password():
    data = request.get_json()

    user_id = data.get('user_id')
    old_password = data.get('old_password')
    new_password = data.get('new_password')

    if not user_id or not old_password or not new_password:
        return jsonify({'error': 'Missing required fields'}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Fetch current password
    cursor.execute("SELECT password FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()

    if not user:
        cursor.close()
        conn.close()
        return jsonify({'error': 'User not found'}), 404

    # Check if old password is correct
    if user['password'] != old_password:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Incorrect old password'}), 403

    # Update with new password
    cursor.execute("UPDATE users SET password = %s WHERE id = %s", (new_password, user_id))
    conn.commit()

    cursor.close()
    conn.close()

    return jsonify({'message': 'Password changed successfully'}), 200

@app.route('/api/courier_notification', methods=['GET'])
def api_courier_notification():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, message, activity_type, is_read, created_at
        FROM notifications
        WHERE user_type = 'courier'
        ORDER BY created_at DESC
    """)

    notifications = cursor.fetchall()
    conn.close()

    return jsonify(notifications)



if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")

