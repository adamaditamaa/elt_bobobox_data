
-- PROMOTION SYSTEM

-- Create enum for discount type
CREATE TYPE promotion.discount_type AS ENUM ('Percentage', 'Fixed Amount');

-- Create Campaigns table
CREATE TABLE promotion.campaigns (
   id SERIAL PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   description TEXT,
   cover_pic_url TEXT
);

-- Create Vouchers table
CREATE TABLE promotion.vouchers (
   id SERIAL PRIMARY KEY,
   campaign_id INTEGER NOT NULL REFERENCES promotion.campaigns(id) ON DELETE CASCADE,
   code VARCHAR(50) NOT NULL UNIQUE,
   discount_type promotion.discount_type NOT NULL,
   discount_value NUMERIC(10,2) NOT NULL,
   visible_from TIMESTAMP NOT NULL,
   visible_to TIMESTAMP NOT NULL,
   valid_from TIMESTAMP NOT NULL,
   valid_to TIMESTAMP NOT NULL,
   hotel_types INTEGER[] NOT NULL,
   hotel_ids INTEGER[] NOT NULL,
   room_types VARCHAR(50)[] NOT NULL,
   CONSTRAINT valid_dates CHECK (
       visible_from <= visible_to
       AND valid_from <= valid_to
       AND visible_from <= valid_from
       AND visible_to >= valid_to
   ),
   CONSTRAINT valid_discount CHECK (
       (discount_type = 'Percentage' AND discount_value > 0 AND discount_value <= 100)
       OR (discount_type = 'Fixed Amount' AND discount_value > 0)
   )
);


-- PAYMENT SYSTEM

-- Create PaymentThirdParties table
CREATE TABLE payment.payment_third_parties (
   id SERIAL PRIMARY KEY,
   name VARCHAR(100) NOT NULL
);

-- Create PaymentMethods table
CREATE TABLE payment.payment_methods (
   id SERIAL PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   third_party_id INTEGER NOT NULL,
   FOREIGN KEY (third_party_id) REFERENCES payment.payment_third_parties(id) ON DELETE NO ACTION
);

-- Create Payments table
CREATE TABLE payment.payments (
   id SERIAL PRIMARY KEY,
   reservation_id INTEGER NOT NULL,
   payment_method_id INTEGER NOT NULL,
   amount DECIMAL(10,2) NOT NULL,
   status VARCHAR(20) NOT NULL CHECK (status IN ('Pending', 'Cancelled', 'Expired', 'Paid')),
   created_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   payment_datetime TIMESTAMP,
   FOREIGN KEY (payment_method_id) REFERENCES payment.payment_methods(id) ON DELETE NO ACTION
);


-- RESERVATION SYSTEM

-- Create Users table
CREATE TABLE reservation.users (
   id SERIAL PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   birth_date TIMESTAMP,
   gender VARCHAR(10)
);

-- Create Hotels table
CREATE TABLE reservation.hotels (
   id SERIAL PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   type VARCHAR(10) NOT NULL CHECK (type IN ('Pod', 'Cabin'))
);

-- Create Reservations table
CREATE TABLE reservation.reservations (
   id SERIAL PRIMARY KEY,
   reservation_datetime TIMESTAMP NOT NULL,
   check_in_date DATE NOT NULL,
   check_out_date DATE NOT NULL,
   status VARCHAR(10) NOT NULL CHECK (status IN ('Pending', 'Cancelled', 'Expired', 'Paid')),
   hotel_id INTEGER NOT NULL REFERENCES reservation.hotels(id),
   booker_id INTEGER NOT NULL REFERENCES reservation.users(id),
   total_room_price INTEGER NOT NULL,
   voucher_code VARCHAR(50),
   total_discount INTEGER NOT NULL DEFAULT 0,
   CONSTRAINT check_dates CHECK (check_out_date > check_in_date)
);

-- Create ReservationItems table
CREATE TABLE reservation.reservation_items (
   id SERIAL PRIMARY KEY,
   reservation_id INTEGER NOT NULL REFERENCES reservation.reservations(id),
   reservation_datetime TIMESTAMP NOT NULL,
   check_in_date DATE NOT NULL,
   check_out_date DATE NOT NULL,
   room_type VARCHAR(10) NOT NULL,
   total_room_price INTEGER NOT NULL,
   total_discount INTEGER NOT NULL DEFAULT 0,
   CONSTRAINT check_dates CHECK (check_out_date > check_in_date)
);

-- STAY SYSTEM

-- Create Users table
CREATE TABLE stay.users (
   id SERIAL PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   birth_date TIMESTAMP,
   gender VARCHAR(10),
   email VARCHAR(255),
   phone_number VARCHAR(20)
);

-- Create Hotels table
CREATE TABLE stay.hotels (
   id SERIAL PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   type VARCHAR(10) NOT NULL CHECK (type IN ('Pod', 'Cabin'))
);

-- Create Rooms table
CREATE TABLE stay.rooms (
   id SERIAL PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   room_type VARCHAR(50) NOT NULL,
   floor INTEGER NOT NULL,
   hotel_id INTEGER NOT NULL,
   FOREIGN KEY (hotel_id) REFERENCES stay.hotels(id) ON DELETE NO ACTION
);

-- Create Stays table
CREATE TABLE stay.stays (
   id SERIAL PRIMARY KEY,
   date DATE NOT NULL,
   reference_reservation_id INTEGER NOT NULL,
   room_id INTEGER NOT NULL,
   guest_id INTEGER NOT NULL,
   FOREIGN KEY (room_id) REFERENCES stay.rooms(id) ON DELETE NO ACTION,
   FOREIGN KEY (guest_id) REFERENCES stay.users(id) ON DELETE NO ACTION
);
