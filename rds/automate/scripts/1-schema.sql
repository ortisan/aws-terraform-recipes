CREATE TABLE IF NOT EXISTS user (id VARCHAR(36), fullname VARCHAR(100), email VARCHAR(100), address VARCHAR(30), PRIMARY KEY (id));
CREATE TABLE IF NOT EXISTS role_user (id VARCHAR(36), user_id VARCHAR(36), title VARCHAR(500), PRIMARY KEY (id), INDEX user_id (user_id), FOREIGN KEY (user_id) REFERENCES user(id));
CREATE INDEX idx_email ON user (email);
ALTER TABLE role_user ADD FOREIGN KEY (user_id) REFERENCES user(id);