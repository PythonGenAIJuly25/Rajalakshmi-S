-- Database schema for Log Analyzer CLI
-- Creates tables for storing log entries and user agents with all required fields

-- Create user_agents table first (referenced by log_entries)
CREATE TABLE IF NOT EXISTS user_agents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_agent_string TEXT NOT NULL,
    os VARCHAR(100),
    browser VARCHAR(100),
    device_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (user_agent_string(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create log_entries table with all fields from your parser
CREATE TABLE IF NOT EXISTS log_entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL,
    timestamp DATETIME NOT NULL,
    method VARCHAR(10) NOT NULL,
    path VARCHAR(2048) NOT NULL,
    protocol VARCHAR(20),
    status_code SMALLINT NOT NULL,
    bytes_sent INT NOT NULL DEFAULT 0,
    referrer TEXT,
    user_agent_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_agent_id) REFERENCES user_agents(id),
    UNIQUE KEY unique_log_entry (ip_address, timestamp, path(255)),
    INDEX idx_timestamp (timestamp),
    INDEX idx_ip (ip_address),
    INDEX idx_status (status_code),
    INDEX idx_path (path(255)),
    INDEX idx_method (method)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create views for your report types
CREATE OR REPLACE VIEW top_ips AS
SELECT ip_address, COUNT(*) as request_count
FROM log_entries
GROUP BY ip_address
ORDER BY request_count DESC;

CREATE OR REPLACE VIEW top_pages AS
SELECT path, COUNT(*) as request_count
FROM log_entries
GROUP BY path
ORDER BY request_count DESC;

CREATE OR REPLACE VIEW status_code_stats AS
SELECT 
    status_code, 
    COUNT(*) as count,
    ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM log_entries), 1) as percentage
FROM log_entries
GROUP BY status_code;

CREATE OR REPLACE VIEW hourly_traffic AS
SELECT 
    HOUR(timestamp) as hour,
    COUNT(*) as request_count
FROM log_entries
GROUP BY HOUR(timestamp)
ORDER BY hour;

CREATE OR REPLACE VIEW error_logs AS
SELECT 
    ip_address, 
    timestamp, 
    method, 
    path, 
    status_code
FROM log_entries
WHERE status_code >= 400;
