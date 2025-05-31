-- Group untuk tim data
CREATE ROLE data_team;

-- Group untuk finance
CREATE ROLE finance_team;

-- Tambahkan user Adam ke data_team
CREATE USER adam WITH PASSWORD 'adam_password';
GRANT data_team TO adam;

-- Tambahkan user Ranti ke finance_team
CREATE USER ranti WITH PASSWORD 'ranti_password';
GRANT finance_team TO ranti;

-- jika ada user tambahan bisa di assign ke group yang dibutuhkan dan tidak perlu lagi untuk grant access

-- Beri akses penuh ke semua schema untuk tim data
GRANT USAGE ON SCHEMA raw_data TO data_team;
GRANT USAGE ON SCHEMA analytics TO data_team;
GRANT USAGE ON SCHEMA production TO data_team;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA raw_data TO data_team;

-- Beri akses hanya ke mart_finance untuk finance team
GRANT USAGE ON SCHEMA mart_finance TO finance_team;
GRANT SELECT ON ALL TABLES IN SCHEMA mart_finance TO finance_team;

-- Untuk table baru di kemudian hari
ALTER DEFAULT PRIVILEGES IN SCHEMA raw_data GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO data_team;
ALTER DEFAULT PRIVILEGES IN SCHEMA mart_finance GRANT SELECT ON TABLES TO finance_team;
