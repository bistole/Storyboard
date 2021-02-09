package config

import (
	"database/sql"
	"io/ioutil"
	"log"
	"path"

	"github.com/adrg/xdg"
	"gopkg.in/yaml.v2"
)

const defaultAppName = "Storyboard"
const databaseName = "backend.db"
const configName = "backend.yaml"

// Properties save config file properties
type Properties struct {
	IP   string `yaml:"IP"`
	PORT int    `yaml:"PORT"`
}

// Config is implemented interface ConfigService
type Config struct {
	conn    *sql.DB
	appName string
	props   Properties
}

// NewConfigService create a config service instance
func NewConfigService(app string) Config {
	if app == "" {
		app = defaultAppName
	}
	c := Config{appName: app}
	c.LoadFromConfigFile()
	return c
}

// GetAppName get app name
func (c Config) GetAppName() string {
	return c.appName
}

// GetDatabaseName get database name
func (c Config) GetDatabaseName() string {
	return databaseName
}

// LoadFromConfigFile load config from configName yaml file
func (c Config) LoadFromConfigFile() {
	filename := path.Join(xdg.DataHome, c.appName, configName)
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		c.props.IP = ""
		c.props.PORT = 3000
		return
	}

	c.props = Properties{IP: "", PORT: 3000}
	yaml.Unmarshal(data, &c.props)
}

// SaveToConfigFile save config to configName yaml file
func (c Config) SaveToConfigFile() {
	filename := path.Join(xdg.DataHome, c.appName, configName)
	log.Println("config file: " + filename)
	data, err := yaml.Marshal(c.props)
	if err != nil {
		log.Println(err)
		return
	}
	ioutil.WriteFile(filename, data, 0777)
}

// GetIP get ip address
func (c Config) GetIP() string {
	return c.props.IP
}

// SetIP set ip address
func (c Config) SetIP(ip string) {
	if ip != c.props.IP {
		c.props.IP = ip
		c.SaveToConfigFile()
	}
}

// GetPort get port
func (c Config) GetPort() int {
	return c.props.PORT
}

// SetPort set port
func (c Config) SetPort(port int) {
	if port != c.props.PORT {
		c.props.PORT = port
		c.SaveToConfigFile()
	}
}
