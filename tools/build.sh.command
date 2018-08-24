#!/bin/sh
#############################################################
# Paradise ~ centerkey.com/paradise                         #
# GPLv3 ~ Copyright (c) individual contributors to Paradise #
#############################################################

# Build:
#     Creates the release file (zip) with the version number in the file
#     name (extracted from paradise/src/gallery/console/php/library.php)

banner="Paradise ~ Build"
projectHome=$(cd $(dirname $0)/..; pwd)

setupTools() {
   # Check for Node.js installation and download project dependencies
   cd $projectHome
   echo
   echo $banner
   echo $(echo $banner | sed -e "s/./=/g")
   pwd
   echo
   echo "Node.js:"
   which node || { echo "Need to install Node.js: https://nodejs.org"; exit; }
   node --version
   npm install
   npm update
   npm outdated
   echo
   }

runStaticAnalyzer() {
   echo "*** Analyzing"
   cd $projectHome
   npm test
   cd $projectHome/src
   pwd
   find . -name "*.php" -exec php --syntax-check {} \;
   echo
   }

setupPhpServer() {
   cd $projectHome
   echo "*** Apache HTTP Server"
   publishWebRoot=$(grep ^DocumentRoot /private/etc/apache2/httpd.conf | awk -F\" '{ print $2 }')
   grep php /private/etc/apache2/httpd.conf
   apachectl configtest  #to start web server: sudo apachectl restart
   deployFolder=$publishWebRoot/paradise-deploy
   test -w $publishWebRoot && mkdir -p $deployFolder
   echo $publishWebRoot
   echo
   }

unzipRelease() {
   echo "*** Unzip Release"
   cd $deployFolder
   pwd
   unzip -o $projectHome/releases/paradise-install-files
   chmod o+rwx gallery
   echo
   }

openConsole() {
   echo "*** Administrator Console"
   consoleUrl=http://localhost/paradise-deploy/gallery/console/
   echo $consoleUrl
   sleep 2
   open $consoleUrl
   echo
   }

deployRelease() {
   unzipRelease
   openConsole
   }

setupTools
runStaticAnalyzer
setupPhpServer
test -w $deployFolder && deployRelease
