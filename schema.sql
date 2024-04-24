-- psql DATABASE_NAME -f schema.sql

CREATE TABLE expenses (
  id serial PRIMARY KEY,
  amount numeric(6,2) NOT NULL,
  memo text NOT NULL,
  created_on date NOT NULL
);

alter table expenses
  add check (amount >= 0.01);
  
INSERT INTO expenses (amount, memo, created_on) VALUES (14.56, 'Pencils', NOW());
INSERT INTO expenses (amount, memo, created_on) VALUES (3.29, 'Coffee', NOW());
INSERT INTO expenses (amount, memo, created_on) VALUES (49.99, 'Text Editor', NOW());