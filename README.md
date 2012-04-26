# OpenShift template for JRuby applications

Template for running JRuby application on OpenShift without an application server.

## Status

Work in progress, please report issues.

## Installation

Create OpenShift application

	rhc app create -a $name -t diy-0.1

and enter the directory

	cd $name

Add this repository as new remote

	git remote add template -m master git://github.com/marekjelen/openshift-jruby.git

and pull locally

	git pull -s recursive -X theirs template master

configure your application

	cp .openshift/config.example .openshift/config
	$EDITOR .openshift/config

and deploy to OpenShift

	git push origin master

Now, your application is available at

	http://$name-$namespace.rhcloud.com

## What it does?

* Installs JRuby if needed
* Bundles gems if needed
* Starts application process
	* config.ru for rackup web applications
	* config.rb for non-rackup applications

## Configuration

Configuration parameters are stored in .openshift/config

	VERSION="1.6.7" # JRuby version to use
	RACK_ENV="production" # Environment used for application

## Tools

* Bundler
* Mizuno
