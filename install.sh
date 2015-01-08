#!/bin/bash -e
# -e: Exit immediately if a command exits with a non-zero status.

# get the Magento directory 
echo "Please enter your Magento installation absolute path (/var/www/path/to/magento):"
read MAGENTO_PATH
# Install dependencies depending of the distribution family

echo "Download dependencies"

if which yum &> /dev/null; then
   echo "You are in the RedHat family"   
   sudo yum install java-1.6.0-openjdk
else
   echo "You are in the Debian family"
   sudo apt-get install openjdk-6-jre openjdk-6-jdk
fi

#DIRS
SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`
TMP=/tmp
HOME_INSTALL=/usr/local

# Create jetty user
USER_EXIST=$(id -u jetty)
if [ $USER_EXIST == 0 ]; then
   sudo groupadd -r jetty
   sudo useradd -M -r -g jetty jetty
fi

# Download and Install Jetty Server
echo "Download and Install Jetty Server"
cd $HOME_INSTALL
JETTY_VERSION=7.4.2.v20110526
sudo wget http://archive.eclipse.org/jetty/$JETTY_VERSION/dist/jetty-distribution-$JETTY_VERSION.tar.gz
sudo tar xfz jetty-distribution-$JETTY_VERSION.tar.gz
sudo rm jetty-distribution-$JETTY_VERSION.tar.gz
sudo mv jetty-distribution-$JETTY_VERSION jetty
JETTY_HOME=$HOME_INSTALL/jetty

# Put a new jetty.xml file in JETTY_HOME/etc/
# Now Jetty will listen on port 8983
echo "Replaced old jetty.xml by a new one. Jetty will listen on 8983 port"
sudo cp $BASEDIR/conf/jetty.xml $JETTY_HOME/etc/jetty.xml

#Download and Install Apache Solr
echo "Download and Install Apache Solr"
cd $TMP
wget http://archive.apache.org/dist/lucene/solr/3.6.2/apache-solr-3.6.2.tgz
tar -xzf apache-solr-3.6.2.tgz
rm apache-solr-3.6.2.tgz

# Move Apache Solr Configuration File to Jetty directory
echo "Move Apache Solr Configuration File to Jetty directory"
sudo cp -R $TMP/apache-solr-3.6.2/example/solr/ $JETTY_HOME/

# Copy Apache Solr Application (war file) to Jetty webapp directory
echo "Copy Apache Solr Application (war file) to Jetty webapp directory"
sudo cp $TMP/apache-solr-3.6.2/dist/apache-solr-3.6.2.war $JETTY_HOME/webapps/apache-solr-3.6.2.war

# Copy Solr context from git repository
echo "Copy Solr context from git repository"
sudo cp $BASEDIR/conf/solr.xml $JETTY_HOME/contexts/solr.xml

# Copy Solr Schema
echo "Copy Solr Schema"
sudo cp $BASEDIR/conf/schema.xml $JETTY_HOME/solr/conf/schema.xml

# Copy the jetty startup script 
echo "Copy the jetty startup script in /etc/init.d/"
sudo cp $BASEDIR/conf/jetty.sh /etc/init.d/jetty

# Permissions assignments
sudo chown -R jetty:jetty $JETTY_HOME
#Clean up
echo "Clean up"
sudo rm -R $TMP/apache-solr-3.6.2/

echo "Checking if Magento directory exists --> $MAGENTO_PATH"
if [ -d "$MAGENTO_PATH" ]; then
	echo "Copying SOLR conf files from Magento"
	sudo cp -R $MAGENTO_PATH/lib/Apache/Solr/conf/* $JETTY_HOME/solr/conf/
fi

if [ ! -d "$MAGENTO_PATH" ]; then
	echo "Your Magento path is not correct, please copy the files from MAGENTO_PATH/lib/Apache/Solr/conf/ to $JETTY_HOME/solr/conf/"
fi


echo "Finish"
echo ""
echo ""
echo "For launch Jetty and Solr, run the command java -jar start.jar in the directory $JETTY_HOME"
echo "Jetty will listen on 8983 port, solr will be under your local machine at: http://localhost:8983/solr/"
echo "Magento indexer has to run once SOLR is enabled in your Magento admin panel configuration"
echo "You can run it from your Magento installation: php shell/indexer.php --reindex catalogsearch_fulltext"

