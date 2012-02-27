# OpenShift template for JRuby applications

Template for running JRuby application on OpenShift without an application server.

## Status

Work in progress, please report issues.

## Installation

* Create OpenShift application with 'raw-0.1' type
* Clone OpenShift repository 
* Add this repository to your repository
* Pull from this repository


* Copy .openshift/config.example to .openshift/config
* Adjust settings in .openshift/config


* Develop your application
* Deploy your application

## What it does?

* Installs JRuby if needed
* Bundles gems if needed
* Starts application process
	* config.ru for rackup web applications
	* config.rb for non-rackup web applications

## Configuration

Configuration parameters are stored in .openshift/config

	VERSION="1.6.7" # JRuby version to use
	RACK_ENV="production" # Environment used for application

## Tools

* Bundler
* Trinidad