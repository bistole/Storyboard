package config

import "database/sql"

const vendorName = "Laterhorse"
const appName = "Storyboard"
const databaseName = "foo.db"

// Config is implemented interface ConfigService
type Config struct {
	conn *sql.DB
}

// NewConfigService create a config service instance
func NewConfigService() Config {
	return Config{}
}

// GetAppName get app name
func (c Config) GetAppName() string {
	return appName
}

// GetVendorName get vendor name
func (c Config) GetVendorName() string {
	return vendorName
}

// GetDatabaseName get database name
func (c Config) GetDatabaseName() string {
	return databaseName
}
