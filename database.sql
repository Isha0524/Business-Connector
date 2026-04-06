-- ============================================================
-- AgriConnect - FIXED & COMPLETE MySQL Database Script
-- Fix: payments.status ENUM मध्ये PARTIAL add केला
-- ============================================================

DROP DATABASE IF EXISTS agri_connect;
CREATE DATABASE agri_connect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE agri_connect;

-- ============================================================
-- 1. TABLE: users
-- ============================================================
CREATE TABLE users (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(100) NOT NULL UNIQUE,
    password        VARCHAR(255) NOT NULL,
    name            VARCHAR(150) NOT NULL,
    phone           VARCHAR(20)  NOT NULL UNIQUE,
    email           VARCHAR(150),
    city            VARCHAR(100),
    state           VARCHAR(100),
    farm_size       VARCHAR(50),
    experience      VARCHAR(50),
    address         TEXT,
    role            ENUM('farmer','dealer','customer','admin') NOT NULL,
    verified        TINYINT(1) NOT NULL DEFAULT 0,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- 2. TABLE: otp_store
-- ============================================================
CREATE TABLE otp_store (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone       VARCHAR(20),
    username    VARCHAR(100),
    name        VARCHAR(150),
    otp         VARCHAR(10),
    role        VARCHAR(20),
    city        VARCHAR(100),
    expires_at  DATETIME,
    attempts    INT DEFAULT 0
) ENGINE=InnoDB;

-- ============================================================
-- 3. TABLE: crops
-- ============================================================
CREATE TABLE crops (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    farmer_id       BIGINT NOT NULL,
    name            VARCHAR(150) NOT NULL,
    category        VARCHAR(100),
    quantity        DOUBLE NOT NULL,
    unit            VARCHAR(20),
    price_per_unit  DOUBLE NOT NULL,
    city            VARCHAR(100),
    state           VARCHAR(100),
    description     TEXT,
    image_url       VARCHAR(500),
    available       TINYINT(1) NOT NULL DEFAULT 1,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_crops_farmer FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 4. TABLE: crop_requests
-- ============================================================
CREATE TABLE crop_requests (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    farmer_id       BIGINT,
    dealer_id       BIGINT,
    crop_id         BIGINT,
    quantity        DOUBLE,
    unit            VARCHAR(20),
    offered_price   DOUBLE,
    message         TEXT,
    urgency         VARCHAR(20),
    delivery_date   VARCHAR(50),
    status          ENUM('PENDING','ACCEPTED','REJECTED','NEGOTIATING') DEFAULT 'PENDING',
    counter_price   DOUBLE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_cr_farmer FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_cr_dealer FOREIGN KEY (dealer_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_cr_crop   FOREIGN KEY (crop_id)   REFERENCES crops(id)  ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- 5. TABLE: deals
-- ============================================================
CREATE TABLE deals (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    farmer_id           BIGINT,
    dealer_id           BIGINT,
    crop_id             BIGINT,
    quantity            DOUBLE,
    unit                VARCHAR(20),
    price               DOUBLE,
    total_amount        DOUBLE,
    status              ENUM('PENDING','ACTIVE','COMPLETED','CANCELLED') DEFAULT 'PENDING',
    payment_status      ENUM('PENDING','PARTIAL','PAID','REFUNDED')      DEFAULT 'PENDING',
    delivery_status     ENUM('PROCESSING','PACKED','IN_TRANSIT','DELIVERED','CANCELLED') DEFAULT 'PROCESSING',
    deal_date           DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_deal_farmer FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_deal_dealer FOREIGN KEY (dealer_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_deal_crop   FOREIGN KEY (crop_id)   REFERENCES crops(id)  ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- 6. TABLE: payments  ← FIX: PARTIAL add केला ENUM मध्ये
-- ============================================================
CREATE TABLE payments (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    payu_txn_id         VARCHAR(100),
    payu_payment_id     VARCHAR(100),
    from_username       VARCHAR(100),
    to_username         VARCHAR(100),
    amount              DOUBLE,
    currency            VARCHAR(10) DEFAULT 'INR',
    crop_name           VARCHAR(150),
    quantity            DOUBLE,
    unit                VARCHAR(20),
    payment_method      ENUM('UPI','BANK_TRANSFER','CASH','WALLET','CARD','NET_BANKING'),
    status              ENUM('PENDING','COMPLETED','FAILED','REFUNDED','PARTIAL'),
    description         TEXT,
    invoice_number      VARCHAR(100),
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at        DATETIME
) ENGINE=InnoDB;

-- ============================================================
-- 7. TABLE: market_prices
-- ============================================================
CREATE TABLE market_prices (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    crop            VARCHAR(150),
    category        VARCHAR(100),
    current_price   DOUBLE,
    price_change    DOUBLE,
    trend           VARCHAR(20),
    unit            VARCHAR(20),
    market          VARCHAR(150),
    region          VARCHAR(150),
    demand          VARCHAR(20),
    prediction      VARCHAR(255),
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- 8. TABLE: government_schemes
-- ============================================================
CREATE TABLE government_schemes (
    id                      BIGINT AUTO_INCREMENT PRIMARY KEY,
    title                   VARCHAR(255),
    description             TEXT,
    category                VARCHAR(100),
    eligibility             TEXT,
    subsidy                 VARCHAR(255),
    deadline                VARCHAR(100),
    status                  VARCHAR(20),
    official_link           VARCHAR(500),
    full_description        TEXT,
    required_documents      TEXT,
    eligibility_criteria    TEXT,
    benefits                TEXT,
    application_process     TEXT,
    created_at              DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- 9. TABLE: notifications
-- ============================================================
CREATE TABLE notifications (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(100) NOT NULL,
    type        ENUM('ORDER','PRICE','PAYMENT','MARKET','SCHEME','SYSTEM') NOT NULL,
    title       VARCHAR(255) NOT NULL,
    message     TEXT NOT NULL,
    priority    ENUM('HIGH','MEDIUM','LOW') NOT NULL DEFAULT 'MEDIUM',
    is_read     TINYINT(1) NOT NULL DEFAULT 0,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- 10. TABLE: contacts
-- ============================================================
CREATE TABLE contacts (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(150) NOT NULL,
    email       VARCHAR(150) NOT NULL,
    phone       VARCHAR(20),
    message     TEXT NOT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_crops_farmer       ON crops(farmer_id);
CREATE INDEX idx_crops_available    ON crops(available);
CREATE INDEX idx_cr_farmer          ON crop_requests(farmer_id);
CREATE INDEX idx_cr_dealer          ON crop_requests(dealer_id);
CREATE INDEX idx_cr_status          ON crop_requests(status);
CREATE INDEX idx_deals_farmer       ON deals(farmer_id);
CREATE INDEX idx_deals_dealer       ON deals(dealer_id);
CREATE INDEX idx_deals_status       ON deals(status);
CREATE INDEX idx_payments_from      ON payments(from_username);
CREATE INDEX idx_payments_to        ON payments(to_username);
CREATE INDEX idx_payments_status    ON payments(status);
CREATE INDEX idx_notif_username     ON notifications(username);
CREATE INDEX idx_notif_read         ON notifications(is_read);
CREATE INDEX idx_market_crop        ON market_prices(crop);

-- ============================================================
-- SAMPLE DATA
-- Password for ALL users: admin123
-- ============================================================

-- ADMIN
INSERT INTO users (username, password, name, phone, email, city, state, role, verified) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Admin User', '9999999999', 'admin@agriconnect.com', 'Pune', 'Maharashtra', 'admin', 1);

-- FARMERS (id: 2,3,4,5,6)
INSERT INTO users (username, password, name, phone, email, city, state, role, verified, farm_size, experience, address) VALUES
('farmer1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Ramesh Patil',  '9876543210', 'ramesh@gmail.com',  'Nasik',   'Maharashtra', 'farmer', 1, '5 acres',  '10 years', 'Village Pimpri, Nasik'),
('farmer2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Suresh Yadav',  '9876543211', 'suresh@gmail.com',  'Nagpur',  'Maharashtra', 'farmer', 1, '8 acres',  '15 years', 'Village Kalmna, Nagpur'),
('farmer3', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Priya Desai',   '9876543212', 'priya@gmail.com',   'Solapur', 'Maharashtra', 'farmer', 1, '3 acres',  '5 years',  'Solapur rural area'),
('farmer4', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Anand Sharma',  '9876543213', 'anand@gmail.com',   'Pune',    'Maharashtra', 'farmer', 1, '12 acres', '20 years', 'Hadapsar, Pune'),
('farmer5', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Kavita Jadhav', '9876543214', 'kavita@gmail.com',  'Latur',   'Maharashtra', 'farmer', 1, '6 acres',  '8 years',  'Latur district');

-- DEALERS (id: 7,8,9)
INSERT INTO users (username, password, name, phone, email, city, state, role, verified) VALUES
('dealer1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Vijay Traders',    '9812345670', 'vijay@trader.com',    'Pune',   'Maharashtra', 'dealer', 1),
('dealer2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Manoj Agro Mart',  '9812345671', 'manoj@agromart.com',  'Mumbai', 'Maharashtra', 'dealer', 1),
('dealer3', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Rajesh Wholesale', '9812345672', 'rajesh@wholesale.com','Nashik', 'Maharashtra', 'dealer', 1);

-- CUSTOMERS (id: 10,11,12)
INSERT INTO users (username, password, name, phone, email, city, state, role, verified) VALUES
('customer1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Aisha Khan',  '9800000001', 'aisha@gmail.com', 'Pune',   'Maharashtra', 'customer', 1),
('customer2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Ravi Mehta',  '9800000002', 'ravi@gmail.com',  'Mumbai', 'Maharashtra', 'customer', 1),
('customer3', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u', 'Sneha Joshi', '9800000003', 'sneha@gmail.com', 'Nagpur', 'Maharashtra', 'customer', 1);

-- CROPS (farmer1=id:2, farmer2=id:3, farmer3=id:4, farmer4=id:5, farmer5=id:6)
INSERT INTO crops (farmer_id, name, category, quantity, unit, price_per_unit, city, state, description, available) VALUES
(2, 'Wheat',     'Grain',     500,  'quintal', 2200, 'Nasik',   'Maharashtra', 'Premium quality wheat, freshly harvested', 1),
(2, 'Onion',     'Vegetable', 1000, 'kg',        25, 'Nasik',   'Maharashtra', 'Fresh red onions, good quality',           1),
(3, 'Rice',      'Grain',     300,  'quintal', 3500, 'Nagpur',  'Maharashtra', 'Basmati rice, aromatic variety',           1),
(3, 'Soybean',   'Oilseed',   200,  'quintal', 4200, 'Nagpur',  'Maharashtra', 'Soybean crop, high protein content',       1),
(4, 'Tomato',    'Vegetable', 800,  'kg',        30, 'Solapur', 'Maharashtra', 'Ripe red tomatoes',                        1),
(4, 'Sugarcane', 'Cash Crop', 5000, 'kg',       3.5, 'Solapur', 'Maharashtra', 'Good quality sugarcane',                   1),
(5, 'Cotton',    'Cash Crop', 150,  'quintal', 6500, 'Pune',    'Maharashtra', 'White cotton, high yield variety',         1),
(5, 'Maize',     'Grain',     400,  'quintal', 1800, 'Pune',    'Maharashtra', 'Yellow maize, animal feed grade',          1),
(6, 'Turmeric',  'Spice',     100,  'kg',       120, 'Latur',   'Maharashtra', 'Organic turmeric, deep yellow colour',    1),
(6, 'Chickpea',  'Pulse',     250,  'quintal', 5200, 'Latur',   'Maharashtra', 'Desi chickpea, good quality',              1);

-- MARKET PRICES
INSERT INTO market_prices (crop, category, current_price, price_change, trend, unit, market, region, demand, prediction) VALUES
('Wheat',     'Grain',     2250,   50, 'up',   'per quintal', 'Pune APMC',     'Maharashtra', 'high',   'Expected to rise by 3% next week'),
('Rice',      'Grain',     3600, -100, 'down', 'per quintal', 'Nagpur APMC',   'Maharashtra', 'medium', 'Slight decrease expected'),
('Onion',     'Vegetable',   28,    3, 'up',   'per kg',      'Nasik APMC',    'Maharashtra', 'high',   'Festive season demand rising'),
('Tomato',    'Vegetable',   25,   -5, 'down', 'per kg',      'Mumbai Market', 'Maharashtra', 'medium', 'Oversupply from local farms'),
('Soybean',   'Oilseed',   4300,  100, 'up',   'per quintal', 'Latur APMC',    'Maharashtra', 'high',   'Export demand increasing'),
('Cotton',    'Cash Crop', 6600,  200, 'up',   'per quintal', 'Aurangabad',    'Maharashtra', 'high',   'Strong mill demand'),
('Maize',     'Grain',     1850,   50, 'up',   'per quintal', 'Pune APMC',     'Maharashtra', 'medium', 'Stable demand expected'),
('Turmeric',  'Spice',      125,    5, 'up',   'per kg',      'Sangli APMC',   'Maharashtra', 'high',   'Export market strong'),
('Chickpea',  'Pulse',     5300,  100, 'up',   'per quintal', 'Latur APMC',    'Maharashtra', 'high',   'Pulse prices firming up'),
('Sugarcane', 'Cash Crop',  3.8,  0.3, 'up',   'per kg',      'Solapur',       'Maharashtra', 'medium', 'Mill purchase season starting');

-- GOVERNMENT SCHEMES
INSERT INTO government_schemes (title, description, category, eligibility, subsidy, deadline, status, official_link, full_description, required_documents, eligibility_criteria, benefits, application_process) VALUES
(
  'PM-KISAN Samman Nidhi',
  'Direct income support of Rs.6000 per year to farmer families',
  'income',
  'Small and marginal farmers with cultivable land',
  'Rs.6000/year in 3 installments',
  'Ongoing', 'active', 'https://pmkisan.gov.in',
  'PM-KISAN provides financial benefit of Rs.6000/year in three equal installments of Rs.2000 each every four months.',
  '["Aadhaar Card","Land Records (7/12 extract)","Bank Passbook","Passport Size Photo"]',
  '["Must be a farmer","Should have cultivable land","Should not be income taxpayer","Government employees not eligible"]',
  '["Rs.2000 every 4 months","Direct bank transfer","No middleman"]',
  '["Register on pmkisan.gov.in","Submit land records","Verify Aadhaar","Wait for approval"]'
),
(
  'Pradhan Mantri Fasal Bima Yojana',
  'Crop insurance scheme providing financial support to farmers suffering crop loss',
  'crop',
  'All farmers growing notified crops',
  'Premium subsidy up to 95% for Rabi crops',
  '31 December (Rabi season)', 'active', 'https://pmfby.gov.in',
  'PMFBY provides comprehensive insurance coverage against crop failure due to natural calamities, pests and diseases.',
  '["Aadhaar Card","Land Records","Bank Account Details","Sowing Certificate"]',
  '["Must be a farmer","Should have sowed notified crop","Land should be in declared area"]',
  '["Financial support after crop failure","Low premium rates","Covers post-harvest losses"]',
  '["Apply through bank or CSC","Submit sowing certificate","Pay nominal premium","Claim within 72 hours of damage"]'
),
(
  'Pradhan Mantri Krishi Sinchayee Yojana',
  'Improving irrigation coverage and ensuring water efficiency',
  'irrigation',
  'Farmers willing to adopt micro-irrigation',
  'Up to 55% subsidy on drip/sprinkler system',
  '31 March (annually)', 'active', 'https://pmksy.gov.in',
  'PMKSY aims to achieve convergence of investments in irrigation at field level, expand cultivable area under assured irrigation.',
  '["Land Records","Aadhaar Card","Bank Details","Water Source Certificate"]',
  '["Should have own cultivable land","Water source should be available","Not received similar benefit before"]',
  '["Drip irrigation system at subsidized rates","Improved crop yield","Water conservation"]',
  '["Apply at district agriculture office","Submit documents","Get inspection done","Receive subsidy"]'
),
(
  'Kisan Credit Card',
  'Easy credit for farmers for agricultural needs at low interest rates',
  'income',
  'All farmers, sharecroppers and tenant farmers',
  'Interest subvention of 2% (additional 3% on timely repayment)',
  'Ongoing', 'active', 'https://www.nabard.org',
  'KCC provides farmers with affordable credit for their agricultural operations including crop production, allied activities and non-farm activities.',
  '["Aadhaar Card","Land Records","Income Certificate","Bank Account"]',
  '["Must be a farmer","Age 18-75 years","Valid land records required"]',
  '["Credit limit up to Rs.3 lakh","Interest @ 7% per annum","Flexible repayment","Insurance coverage"]',
  '["Visit nearest bank","Fill KCC application","Submit land documents","Receive KCC within 2 weeks"]'
),
(
  'Soil Health Card Scheme',
  'Provide soil health cards to farmers with crop-wise nutrient recommendations',
  'testing',
  'All farmers',
  'Free soil testing and card',
  'Ongoing', 'active', 'https://soilhealth.dac.gov.in',
  'Soil Health Card is issued to farmers carrying crop-wise recommendations of nutrients and fertilizers required for farms.',
  '["Aadhaar Card","Land Records"]',
  '["Any farmer with cultivable land","No income limit"]',
  '["Free soil testing","Nutrient recommendations","Fertilizer usage guidance","Improved soil health"]',
  '["Contact block agriculture officer","Register for soil testing","Receive SHC within 2 months","Follow recommendations"]'
);

-- CROP REQUESTS
-- dealer1=id:7, dealer2=id:8, dealer3=id:9
-- farmer1=id:2, farmer2=id:3, farmer3=id:4, farmer4=id:5, farmer5=id:6
-- crop:  wheat=1, onion=2, rice=3, soybean=4, tomato=5, sugarcane=6, cotton=7, maize=8, turmeric=9, chickpea=10
INSERT INTO crop_requests (farmer_id, dealer_id, crop_id, quantity, unit, offered_price, message, urgency, delivery_date, status) VALUES
(2, 7, 1,  100, 'quintal', 2100, 'We need wheat for our flour mill. Can you deliver to Pune?', 'high',   '2024-12-15', 'PENDING'),
(2, 7, 2,  500, 'kg',        23, 'Need onions for restaurant chain supply.',                   'medium', '2024-12-20', 'ACCEPTED'),
(3, 8, 3,   50, 'quintal', 3400, 'Basmati rice for export order.',                             'high',   '2024-12-10', 'NEGOTIATING'),
(4, 8, 5,  200, 'kg',        28, 'Tomatoes for processing unit.',                              'low',    '2024-12-25', 'PENDING'),
(5, 9, 7,   80, 'quintal', 6300, 'Cotton purchase for textile unit.',                          'medium', '2025-01-05', 'ACCEPTED');

-- DEALS
INSERT INTO deals (farmer_id, dealer_id, crop_id, quantity, unit, price, total_amount, status, payment_status, delivery_status) VALUES
(2, 7, 2,  500, 'kg',      23,   11500,  'ACTIVE',    'PENDING', 'PROCESSING'),
(3, 8, 3,   50, 'quintal', 3400, 170000, 'ACTIVE',    'PARTIAL', 'PACKED'),
(5, 9, 7,   80, 'quintal', 6300, 504000, 'COMPLETED', 'PAID',    'DELIVERED'),
(4, 8, 5,  300, 'kg',      27,    8100,  'ACTIVE',    'PENDING', 'IN_TRANSIT'),
(6, 7, 9,   50, 'kg',      115,   5750,  'COMPLETED', 'PAID',    'DELIVERED');

-- PAYMENTS  ← FIXED: PARTIAL आता valid आहे
INSERT INTO payments (payu_txn_id, from_username, to_username, amount, crop_name, quantity, unit, payment_method, status, description, invoice_number, completed_at) VALUES
('TXN-1001', 'dealer2', 'farmer3',  170000, 'Rice',     50,  'quintal', 'BANK_TRANSFER', 'PARTIAL',   'Partial payment for rice deal',  'INV-2024-001', NULL),
('TXN-1002', 'dealer3', 'farmer5',  504000, 'Cotton',   80,  'quintal', 'UPI',           'COMPLETED', 'Full payment for cotton deal',   'INV-2024-002', NOW()),
('TXN-1003', 'dealer3', 'farmer6',    5750, 'Turmeric', 50,  'kg',      'UPI',           'COMPLETED', 'Payment for turmeric delivery',  'INV-2024-003', NOW()),
('TXN-1004', 'dealer1', 'farmer2',   11500, 'Onion',    500, 'kg',      'CASH',          'PENDING',   'Payment pending for onion deal', 'INV-2024-004', NULL);

-- NOTIFICATIONS
INSERT INTO notifications (username, type, title, message, priority, is_read) VALUES
('farmer1', 'ORDER',   'New Order Request',          'dealer1 has sent a new request for 100 quintals of Wheat.', 'HIGH',   0),
('farmer2', 'ORDER',   'Request Accepted',           'Your onion listing has been accepted by dealer1.',          'HIGH',   0),
('farmer3', 'PAYMENT', 'Partial Payment Received',   'You received Rs.85,000 partial payment for rice deal.',     'HIGH',   0),
('farmer5', 'PAYMENT', 'Payment Completed',          'Full payment of Rs.5,04,000 received for cotton deal.',     'HIGH',   1),
('dealer1', 'MARKET',  'Price Alert',                'Onion prices have risen by 12% this week in Nasik APMC.',  'MEDIUM', 0),
('dealer2', 'ORDER',   'Order Status Update',        'Your rice order is now packed and ready for dispatch.',     'MEDIUM', 0),
('farmer1', 'SCHEME',  'New Government Scheme',      'PM-KISAN new installment released. Check your bank.',      'LOW',    1),
('admin',   'SYSTEM',  'System Alert',               '5 new user registrations pending verification.',            'HIGH',   0);

-- CONTACTS
INSERT INTO contacts (name, email, phone, message) VALUES
('John Doe',    'john@example.com',  '9000000001', 'I am a farmer looking to connect with dealers in Pune area.'),
('Priya Singh', 'priya@example.com', '9000000002', 'How do I list my crops on AgriConnect platform?'),
('Retail Corp', 'info@retail.com',   '9000000003', 'We are interested in bulk purchase partnership.');

-- ============================================================
-- VIEWS
-- ============================================================
CREATE OR REPLACE VIEW v_available_crops AS
SELECT
    c.id, c.name AS crop_name, c.category, c.quantity, c.unit,
    c.price_per_unit, c.city, c.state, c.description,
    u.name AS farmer_name, u.phone AS farmer_phone,
    c.created_at
FROM crops c
JOIN users u ON c.farmer_id = u.id
WHERE c.available = 1;

CREATE OR REPLACE VIEW v_payment_summary AS
SELECT
    p.id, p.payu_txn_id, p.from_username, p.to_username,
    p.amount, p.currency, p.crop_name, p.quantity, p.unit,
    p.payment_method, p.status, p.invoice_number,
    p.created_at, p.completed_at
FROM payments p
ORDER BY p.created_at DESC;

-- ============================================================
-- STORED PROCEDURES
-- ============================================================
DELIMITER //

CREATE PROCEDURE sp_farmer_stats(IN p_username VARCHAR(100))
BEGIN
    DECLARE v_farmer_id BIGINT;
    SELECT id INTO v_farmer_id FROM users WHERE username = p_username;
    SELECT
        (SELECT COUNT(*) FROM crops        WHERE farmer_id = v_farmer_id AND available = 1)        AS active_crops,
        (SELECT COUNT(*) FROM crop_requests WHERE farmer_id = v_farmer_id AND status = 'PENDING')  AS pending_requests,
        (SELECT COUNT(*) FROM deals         WHERE farmer_id = v_farmer_id AND status = 'ACTIVE')   AS active_deals,
        (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE to_username = p_username AND status = 'COMPLETED') AS total_earnings;
END //

CREATE PROCEDURE sp_dealer_stats(IN p_username VARCHAR(100))
BEGIN
    DECLARE v_dealer_id BIGINT;
    SELECT id INTO v_dealer_id FROM users WHERE username = p_username;
    SELECT
        (SELECT COUNT(*) FROM crop_requests WHERE dealer_id = v_dealer_id AND status = 'PENDING')   AS pending_requests,
        (SELECT COUNT(*) FROM deals          WHERE dealer_id = v_dealer_id AND status = 'ACTIVE')   AS active_deals,
        (SELECT COUNT(*) FROM deals          WHERE dealer_id = v_dealer_id AND status = 'COMPLETED') AS completed_deals,
        (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE from_username = p_username AND status = 'COMPLETED') AS total_spent;
END //

DELIMITER ;

-- ============================================================
-- VERIFICATION
-- ============================================================
SELECT 'users'         AS table_name, COUNT(*) AS total_rows FROM users
UNION ALL
SELECT 'crops',         COUNT(*) FROM crops
UNION ALL
SELECT 'crop_requests', COUNT(*) FROM crop_requests
UNION ALL
SELECT 'deals',         COUNT(*) FROM deals
UNION ALL
SELECT 'payments',      COUNT(*) FROM payments
UNION ALL
SELECT 'market_prices', COUNT(*) FROM market_prices
UNION ALL
SELECT 'govt_schemes',  COUNT(*) FROM government_schemes
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL
SELECT 'contacts',      COUNT(*) FROM contacts;

-- ============================================================
-- LOGIN CREDENTIALS (सर्वांचा password: admin123)
-- ============================================================
-- admin     → admin123  → role: admin
-- farmer1   → admin123  → role: farmer
-- farmer2   → admin123  → role: farmer
-- dealer1   → admin123  → role: dealer
-- dealer2   → admin123  → role: dealer
-- customer1 → admin123  → role: customer
-- ============================================================
-- AgriConnect Database v2.0 - FIXED
-- ============================================================


USE agri_connect;

-- सर्व users चा password 'admin123' ला reset करा
UPDATE users SET password = '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8RxkBoKpxgm3h6iI7u' 
WHERE username = 'admin';

-- Verify करा
SELECT username, role, 
LEFT(password, 20) AS pass_preview 
FROM users WHERE username = 'admin';

USE agri_connect;

UPDATE users 
SET password = '$2a$10$JSjzuisJwyFxJ1IySByxjOffAmrYMPYwzu0MFIsvQ2RLvc0xQAsfu'
WHERE username IN (
    'admin', 
    'farmer1', 'farmer2', 'farmer3', 'farmer4', 'farmer5',
    'dealer1', 'dealer2', 'dealer3',
    'customer1', 'customer2', 'customer3'
);

-- Verify
SELECT username, role, LEFT(password, 30) AS hash_preview FROM users;

-- PARTIAL records बघा
SELECT id, status, amount FROM payments WHERE status = 'PARTIAL';

-- PARTIAL ला PENDING करा (किंवा COMPLETED — तुम्हाला योग्य वाटेल ते)
UPDATE payments SET status = 'PENDING' WHERE status = 'PARTIAL';

-- Total users count
SELECT COUNT(*) as total_users FROM users;

-- Role नुसार count
SELECT role, COUNT(*) as count FROM users GROUP BY role;

-- Active vs Blocked
SELECT 
  verified,
  COUNT(*) as count 
FROM users 
GROUP BY verified;

-- सगळं एकत्र
SELECT 
  role,
  COUNT(*) as total,
  SUM(CASE WHEN verified = 1 THEN 1 ELSE 0 END) as active,
  SUM(CASE WHEN verified = 0 THEN 1 ELSE 0 END) as blocked
FROM users 
GROUP BY role;

SELECT 
  id,name,username,role,phone,email,city,state,verified,created_at
FROM users
ORDER BY id;

SELECT * FROM contacts ORDER BY created_at DESC;