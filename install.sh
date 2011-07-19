#!/bin/bash

# Install dependencies
sudo apt-get install openjdk-6-jre openjdk-6-jdk

#Create jetty user TODO

# Download and Install Jetty Server
cd /usr/local/
sudo mkdir jetty
cd jetty
JETTY_VERSION=7.4.2.v20110526
sudo wget http://download.eclipse.org/jetty/$JETTY_VERSION/dist/jetty-distribution-$JETTY_VERSION.tar.gz
sudo tar xfz jetty-distribution-$JETTY_VERSION.tar.gz
cd jetty-distribution-$JETTY_VERSION

#Download and Install Apache Solr
cd /tmp/
wget http://apache.mirrors.timporter.net/lucene/solr/3.3.0/apache-solr-3.3.0.tgz
tar -xzf apache-solr-3.3.0.tgz

# Move Apache Solr Configuration File to Jetty directory
cp -R /tmp/apache-solr-3.3.0/example/solr /usr/local/jetty/

# Copy Apache Solr Application (war file) to Jetty webapp directory
cp /tmp/apache-sorl-3.3.0/dist/apache-solr-3.3.0.war /usr/local/jetty/webapp/

# Copy Solr context from git repository
cp /tmp/solr-install/solr.xml /usr/local/jetty/contexts/
