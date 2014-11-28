#!/bin/bash
#set -e

if [ -e /.installed ]; then
  echo 'Already installed.'
  echo 'Checking for composer updates'
  echo 'Composer self updating'
  php composer.phar self-update
  echo 'updating packages in composer'
  php composer.phar update
else

  DEFAULT_DIR=$( cd `dirname "$0"` ; pwd -P)'/../';
  DEFAULT_YOURNAME="KatsuoRyuu";
  DEFAULT_PROJECTNAME="cloudschool";
  DEFAULT_ALIAS="cloudschool"
  DEFAULT_COMPOSER_JSON_FILE="composer.json";
  DEFAULT_BEHAT_YML="behat.yml"
  DEFAULT_SELENIUM_RELEASE="http://selenium-release.storage.googleapis.com/2.42/selenium-server-standalone-2.42.1.jar"
  FEATURE_CONTEXT="./features/bootstrap/FeatureContext.php";
  
  FEATURE_DIR="./features/en/";
  
  FEATURE_EXAMPLE_DIR="./features/en/example/";
  FEATURE_EXAMPLE_A="./features/en/example/example-a.feature";
  FEATURE_EXAMPLE_B="./features/en/example/example-c.feature";
  FEATURE_EXAMPLE_C="./features/en/example/example-b.feature";
  
  echo '';
  echo 'POST INSTALL INFORMATION';
  echo '------------------------';
  
  echo "Composer need some information!"
  read -p "Please enter your name[${DEFAULT_YOURNAME}]: " YOURNAME
  read -p "Please enter Project name[${DEFAULT_PROJECTNAME}]: " PROJECTNAME
  read -p "Please enter VHOST Alias[${DEFAULT_ALIAS}]: " ALIAS
  echo "Default dir is: "${DEFAULT_DIR};
  read -p "Please root path of the webdir[Enter for default]: " ROOT_DIR
  echo "Default Selenium 2 URL "${DEFAULT_SELENIUM_RELEASE};
  read -p "Please Selenium 2 URL[Enter for default]: " SELENIUM_RELEASE

  
  if [ "${YOURNAME}" = "" ]; then
	echo "YOURNAME IS : "${DEFAULT_YOURNAME};
	YOURNAME=${DEFAULT_YOURNAME};
  fi;
  
  if [ "${PROJECTNAME}" = "" ]; then
	echo "PROJECT NAME IS : "${DEFAULT_PROJECTNAME};
	PROJECTNAME=${DEFAULT_PROJECTNAME};
  fi;
  
  if [ "${ALIAS}" = "" ]; then
	echo "SERVER ALIAS IS : "${DEFAULT_ALIAS};
	ALIAS=${DEFAULT_ALIAS};
  fi;
  
  if [ "${ROOT_DIR}" = "" ]; then
	echo "HTTP ROOT DIR IS : "${DEFAULT_DIR};
	ROOT_DIR=${DEFAULT_DIR};
  fi;
  
  if [ "${SELENIUM_RELEASE}" = "" ]; then
	echo "SELENIUM 2 URL IS : "${DEFAULT_SELENIUM_RELEASE};
	SELENIUM_RELEASE=${DEFAULT_SELENIUM_RELEASE};
  fi;

  echo ''
  echo 'INSTALLING'
  echo '------------------------';

  # Install Java, Firefox, Xvfb, and unzip
  #apt-get -y install openjdk-7-jre-headless firefox xvfb unzip

  wget ${SELENIUM_RELEASE}
  #mv selenium-server-standalone-2.42.1.jar /usr/local/bin

  echo "Installing composer"
  curl -sS https://getcomposer.org/installer | php

  
  echo "Inputting composer.json";
  echo -e '{'"\n"\
          '"name": "KatsuoRyuu/cloudschool",'"\n"\
          '  "description": "cloudschool",'"\n"\
          '  "require": {'"\n"\
          '    "behat/mink": "dev-master",'"\n"\
          '    "behat/mink-extension": "dev-master",'"\n"\
          '    "behat/mink-goutte-driver": "*",'"\n"\
          '    "behat/mink-selenium2-driver": "*",'"\n"\
          '    "drupal/drupal-extension": "*",'"\n"\
          '    "phpunit/phpunit": "*",'"\n"\
          '    "phpunit/phpunit-mock-objects": "dev-master"'"\n"\
          '  }'"\n"\
          '}' > ${DEFAULT_COMPOSER_JSON_FILE}

  
  php composer.phar self-update
  php composer.phar update
  
  ./vendor/bin/behat --init
  
  echo -e 'default:'"\n"\
          '  context:'"\n"\
          '    class: "FeatureContext"'"\n"\
          '  paths:'"\n"\
          '    features: "features"'"\n"\
          '    bootstrap: features/bootstrap'"\n"\
          '  extensions:'"\n"\
          '    Behat\MinkExtension:'"\n"\
          '      goutte: ~'"\n"\
          '      javascript_session: selenium2'"\n"\
          '      default_session: selenium2'"\n"\
          '      browser_name: 'firefox''"\n"\
          '      selenium2:'"\n"\
          '        wd_host: http://cloudschool:4444/wd/hub'"\n"\
          '        base_url: http://cloudschool/'"\n"\
          '        capabilities: {"browser": "firefox", "version": "21"}'"\n"\
          '    Drupal\DrupalExtension\Extension:'"\n"\
          '      blackbox: ~'"\n"\
          '      api_driver: "drupal"'"\n"\
          '      drupal:'"\n"\
          '        drupal_root: "'${ROOT_DIR}'"' > ${DEFAULT_BEHAT_YML}
  

  ./vendor/bin/behat -dl
  ./vendor/bin/behat
  
  mkdir -p ${FEATURE_EXAMPLE_DIR}
  
  echo "Writing Example A";
  
  echo -e 'Feature: Content Management'"\n"\
          '  When I log into the website'"\n"\
          '  As an administrator'"\n"\
          '  I should be able to create, edit, and delete page content'"\n"\
          ''"\n"\
          '  Scenario: An administrative user should be able create page content'"\n"\
          '    Given I am logged in as a user with the "administrator" role'"\n"\
          '    When I go to "node/add/page"'"\n"\
          '    Then I should not see "Access denied"' > ${FEATURE_EXAMPLE_A}
  
  echo "Writing Example B";
  
  echo -e 'Feature: Content Management'"\n"\
          '  When I log into the website'"\n"\
          '  As an administrator'"\n"\
          '  I should be able to create, edit, and delete page content'"\n"\
          ''"\n"\
          '  Scenario: An administrative user should be able create page content'"\n"\
          '    Given I am logged in as a user with the "administrator" role'"\n"\
          '    When I go to "node/add/page"'"\n"\
          '    Then I should not see "Access denied"'"\n"\
          ''"\n"\
          '  Scenario: An administrator should be able to edit page content'"\n"\
          '    Given "page" nodes:'"\n"\
          '      | title      | body          | status  |'"\n"\
          '      | Test page  | test content  | 1       |'"\n"\
          '    When I go to "admin/content"'"\n"\
          '    And I click "edit" in the "Test page" row'"\n"\
          '    Then I should not see "Access denied"' > ${FEATURE_EXAMPLE_B}
      
  echo "Writing Example C";
      
  echo -e 'Feature: Visit Google and search'"\n"\
          ''"\n"\
          'Scenario: Run a search for Behat'"\n"\
          '    Given I am on "http://google.com/?complete=0"'"\n"\
          '    When I fill in "lst-ib" with "Behat"'"\n"\
          '    And I press "Google Search"' > ${FEATURE_EXAMPLE_C}

  echo -e '<?php'"\n"\
          ''"\n"\
          'require_once(GuiContext.php);'"\n"\
          ''"\n"\
          '/**'"\n"\
          ' * Defines application features from the specific context.'"\n"\		
          ' */'"\n"\
          'class FeatureContext implements Context, SnippetAcceptingContext'"\n"\
          '{'"\n"\
          '    /**'"\n"\
          '     * Initializes context.'"\n"\
          '     *'"\n"\
          '     * Every scenario gets its own context instance.'"\n"\
          '     * You can also pass arbitrary arguments to the'"\n"\
          '     * context constructor through behat.yml.'"\n"\
          '     */'"\n"\
          '    public function __construct()'"\n"\
          '    {'"\n"\
          '    }'"\n"\
          ''"\n"\
          ''"\n"\
          '}' > ${FEATURE_CONTEXT};

  ./vendor/bin/behat --append-snippets
  
  touch ./.installed
fi


echo "Starting Selenium Server. Default screen resolution: 1280x1024."
java -jar ./selenium-server-standalone-2.42.1.jar &

echo "Give Selenium Server a few minutes to fireup, then run your BDD tests."
