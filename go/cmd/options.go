package main

import (
	"Storyboard/backend/config"

	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/plugins/path_provider"
)

var cfg = config.NewConfigService()

var options = []flutter.Option{
	flutter.WindowInitialDimensions(800, 1280),
	flutter.AddPlugin(&path_provider.PathProviderPlugin{
		VendorName:      cfg.GetVendorName(),
		ApplicationName: cfg.GetAppName(),
	}),
}
