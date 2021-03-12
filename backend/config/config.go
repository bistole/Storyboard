package config

import (
	"database/sql"
	"fmt"
	"io/ioutil"
	"log"
	"path"

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

func (p Properties) toString() string {
	return fmt.Sprintf("IP: %s, PORT: %d", p.IP, p.PORT)
}

// Config is implemented interface ConfigService
type Config struct {
	conn    *sql.DB
	homedir string
	props   Properties
}

// NewConfigService create a config service instance
func NewConfigService(homedir string) *Config {
	if homedir == "" {
		panic("Home dir is required for launch storyboard backend")
	}
	c := Config{homedir: homedir}
	c.LoadFromConfigFile()
	return &c
}

// GetHomeDir get home dir
func (c Config) GetHomeDir() string {
	return c.homedir
}

// GetDatabaseName get database name
func (c Config) GetDatabaseName() string {
	return databaseName
}

// LoadFromConfigFile load config from configName yaml file
func (c *Config) LoadFromConfigFile() {
	filename := path.Join(c.homedir, configName)
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
	filename := path.Join(c.homedir, configName)
	log.Println("config file: " + filename)
	data, err := yaml.Marshal(c.props)
	if err != nil {
		log.Fatalln("Failed to save config file")
		panic(err)
	}
	ioutil.WriteFile(filename, data, 0777)
}

// GetIP get ip address
func (c Config) GetIP() string {
	return c.props.IP
}

// SetIP set ip address
func (c *Config) SetIP(ip string) {
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
func (c *Config) SetPort(port int) {
	if port != c.props.PORT {
		c.props.PORT = port
		c.SaveToConfigFile()
	}
}
