-- psql DATABASE_NAME -f schema.sql

CREATE TABLE expenses (
  id serial PRIMARY KEY,
  amount numeric(6,2) NOT NULL CHECK (amount >= 0.01),
  memo text NOT NULL,
  created_on date NOT NULL
);
  
INSERT INTO expenses (amount, memo, created_on) VALUES (14.56, 'Pencils', NOW());
INSERT INTO expenses (amount, memo, created_on) VALUES (3.29, 'Coffee', NOW());
INSERT INTO expenses (amount, memo, created_on) VALUES (49.99, 'Text Editor', NOW());
INSERT INTO expenses (amount, memo, created_on) VALUES (6.66, 'Donuts', NOW());
INSERT INTO expenses (amount, memo, created_on) VALUES (7.77, 'More donuts', NOW());
INSERT INTO expenses (amount, memo, created_on) VALUES (8.88, 'omg yum donuts', NOW());
INSERT INTO expenses (amount, memo, created_on) VALUES (5.29, 'coffee-latte', NOW());