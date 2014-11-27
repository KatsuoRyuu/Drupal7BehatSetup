#!/bin/sh
#set -e

if [ -e /.installed ]; then
  echo 'Already installed.'
  echo 'Checking for composer updates'
  echo 'Composer self updating'
  php composer.phar self-update
  echo 'updating packages in composer'
  php composer.phar update
else
  echo ''
  echo 'INSTALLING'
  echo '----------'

  # Install Java, Firefox, Xvfb, and unzip
  #apt-get -y install openjdk-7-jre-headless firefox xvfb unzip

  wget "http://selenium-release.storage.googleapis.com/2.42/selenium-server-standalone-2.42.1.jar"
  #mv selenium-server-standalone-2.42.1.jar /usr/local/bin

  echo "Installing composer"
  curl -sS https://getcomposer.org/installer | php
  
  echo "Composer need some information!"
  read -p "Please enter your name: " YOURNAME
  read -p "Please enter Project name: " PROJECTNAME
  read -p "Please enter VHOST Alias: " alias
  default_dir=$( cd `dirname "$0"` ; pwd -P)'/../';
  echo ${default_dir};
  read -p "Please root path of the webdir: " root_dir
  
  echo "Inputting composer.json"
  echo '{' > composer.json
  echo '  "name": "'${YOURNAME}'/'${PROJECTNAME}'",' >> composer.json
  echo '  "description": "'${PROJECTNAME}'",' >> composer.json
  echo '  "require": {' >> composer.json
  echo '    "behat/mink": "1.5.*@stable",' >> composer.json
  echo '    "behat/mink-goutte-driver": "*",' >> composer.json
  echo '    "behat/mink-selenium2-driver": "*",' >> composer.json
  echo '    "drupal/drupal-extension": "*"' >> composer.json
  echo '  }' >> composer.json
  echo '}' >> composer.json
  
  php composer.phar self-update
  php composer.phar update
  
  echo 'default:' > behat.yml
  echo 'context:' >> behat.yml
  echo '  class: "FeatureContext"' >> behat.yml
  echo 'paths:' >> behat.yml
  echo '  features: "features"' >> behat.yml
  echo '  bootstrap: 'features/bootstrap'' >> behat.yml
  echo 'extensions:' >> behat.yml
  echo '  Behat\MinkExtension\Extension:' >> behat.yml
  echo '    goutte: ~' >> behat.yml
  echo '    javascript_session: selenium2' >> behat.yml
  echo '    selenium2:' >> behat.yml
  echo '      wd_host: http://'${alias}':4444/wd/hub' >> behat.yml
  echo '    base_url: http://'${alias}'' >> behat.yml
  echo '  Drupal\DrupalExtension\Extension:' >> behat.yml
  echo '    blackbox: ~' >> behat.yml
  echo '    api_driver: "drupal"' >> behat.yml
  echo '    drupal:' >> behat.yml
  
  if [ "${root_dir}" = "" ]; then
	echo "Defaulting to "${default_dir};
	root_dir=${default_dir};
  fi;
  echo '      drupal_root: "'${root_dir}'"' >> behat.yml
  # So that running `vagrant provision` doesn't redownload everything
  
  ./vendor/bin/behat --init
  ./vendor/bin/behat -dl
  ./vendor/bin/behat
  
  mkdir -p ./features/default/
  
  echo 'Feature: Content Management' 										 > ./features/default/default-a.feature
  echo '  When I log into the website' 										>> ./features/default/default-a.feature
  echo '  As an administrator' 												>> ./features/default/default-a.feature
  echo '  I should be able to create, edit, and delete page content' 		>> ./features/default/default-a.feature
  echo ''																	>> ./features/default/default-a.feature
  echo '  Scenario: An administrative user should be able create page content' >> ./features/default/default-a.feature
  echo '    Given I am logged in as a user with the "administrator" role' 	>> ./features/default/default-a.feature
  echo '    When I go to "node/add/page"' 									>> ./features/default/default-a.feature
  echo '    Then I should not see "Access denied"' 							>> ./features/default/default-a.feature
  
  echo 'Feature: Content Management' 										 > ./features/default/default-b.feature
  echo '  When I log into the website' 										>> ./features/default/default-b.feature
  echo '  As an administrator' 												>> ./features/default/default-b.feature
  echo '  I should be able to create, edit, and delete page content' 		>> ./features/default/default-b.feature
  echo '' 																	>> ./features/default/default-b.feature
  echo '  Scenario: An administrative user should be able create page content' >> ./features/default/default-b.feature
  echo '    Given I am logged in as a user with the "administrator" role' 	>> ./features/default/default-b.feature
  echo '    When I go to "node/add/page"' 									>> ./features/default/default-b.feature
  echo '    Then I should not see "Access denied"' 							>> ./features/default/default-b.feature
  echo '' 																	>> ./features/default/default-b.feature
  echo '  Scenario: An administrator should be able to edit page content' 	>> ./features/default/default-b.feature
  echo '    Given "page" nodes:' 											>> ./features/default/default-b.feature
  echo '      | title      | body          | status  |' 					>> ./features/default/default-b.feature
  echo '      | Test page  | test content  | 1       |' 					>> ./features/default/default-b.feature
  echo '    When I go to "admin/content"' 									>> ./features/default/default-b.feature
  echo '    And I click "edit" in the "Test page" row' 						>> ./features/default/default-b.feature
  echo '    Then I should not see "Access denied"' 							>> ./features/default/default-b.feature
  echo '' 																	>> ./features/default/default-b.feature
  echo '  Scenario: An administrator should be able to delete page content' >> ./features/default/default-b.feature
  echo '    Given "page" nodes:' 											>> ./features/default/default-b.feature
  echo '      | title      | body          | status  |' 					>> ./features/default/default-b.feature
  echo '      | Test page  | test content  | 1       |' 					>> ./features/default/default-b.feature
  echo '    When I go to "admin/content"' 									>> ./features/default/default-b.feature
  echo '    And I click "delete" in the "Test page" row' 					>> ./features/default/default-b.feature
  echo '    Then I should not see "Access denied"' 							>> ./features/default/default-b.feature
  
  ./vendor/bin/behat
  
  FEATURE_CONTEXT="./features/bootstrap/FeatureContext.php";
  
  echo '<?php' 																 > ${FEATURE_CONTEXT};
  echo '' 																	>> ${FEATURE_CONTEXT};
  echo 'use Behat\Behat\Context\Context;' 									>> ${FEATURE_CONTEXT};
  echo 'use Behat\Behat\Context\SnippetAcceptingContext;' 					>> ${FEATURE_CONTEXT};
  echo 'use Behat\Behat\Tester\Exception\PendingException;' 				>> ${FEATURE_CONTEXT};
  echo 'use Behat\Gherkin\Node\PyStringNode;' 								>> ${FEATURE_CONTEXT};
  echo 'use Behat\Gherkin\Node\TableNode;' 									>> ${FEATURE_CONTEXT};
  echo '' 																	>> ${FEATURE_CONTEXT};
  echo '/**' 																>> ${FEATURE_CONTEXT};
  echo ' * Defines application features from the specific context.' 		>> ${FEATURE_CONTEXT};
  echo ' */' 																>> ${FEATURE_CONTEXT};
  echo 'class FeatureContext implements Context, SnippetAcceptingContext' 	>> ${FEATURE_CONTEXT};
  echo '{' 																	>> ${FEATURE_CONTEXT};
  echo '    /**' 															>> ${FEATURE_CONTEXT};
  echo '     * Initializes context.' 										>> ${FEATURE_CONTEXT};
  echo '     *' 															>> ${FEATURE_CONTEXT};
  echo '     * Every scenario gets its own context instance.' 				>> ${FEATURE_CONTEXT};
  echo '     * You can also pass arbitrary arguments to the' 				>> ${FEATURE_CONTEXT};
  echo '     * context constructor through behat.yml.' 						>> ${FEATURE_CONTEXT};
  echo '     */' 															>> ${FEATURE_CONTEXT};
  echo '    public function __construct()' 									>> ${FEATURE_CONTEXT};
  echo '    {' 																>> ${FEATURE_CONTEXT};
  echo '    }' 																>> ${FEATURE_CONTEXT};
  echo '' 																	>> ${FEATURE_CONTEXT};
  echo '}' 																	>> ${FEATURE_CONTEXT};

  
  touch /.installed
fi


echo "Starting Selenium Server. Default screen resolution: 1280x1024."
java -jar ./selenium-server-standalone-2.42.1.jar &

echo "Give Selenium Server a few minutes to fireup, then run your BDD tests."
