#!/bin/bash
#set -e

RUN_PROFILES=("default" "firefox" "chrome")


if [ -e /.installed ]; then
  echo 'Already installed.'
  echo 'Checking for composer updates'
  echo 'Composer self updating'
  php composer.phar self-update
  echo 'updating packages in composer'
  php composer.phar update
else

  DEFAULT_DIR=$( cd `dirname "$0"` ; cd ../ ; pwd -P);
  THIS_DIR=$( cd `dirname "$0"` ; pwd -P);
  DEFAULT_YOURNAME="KatsuoRyuu";
  DEFAULT_PROJECTNAME="cloudschool";
  DEFAULT_ALIAS="localhost"
  DEFAULT_COMPOSER_JSON_FILE="composer.json";
  DEFAULT_BEHAT_YML="behat.yml"
  DEFAULT_SELENIUM_RELEASE="http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar"
  DEFAULT_SELENIUM_SAFARI_WEBDRIVER="http://central.maven.org/maven2/org/seleniumhq/selenium/selenium-safari-driver/2.44.0/selenium-safari-driver-2.44.0.jar"
  DEFAULT_SELENIUM_CHROME_WEBDRIVER="http://chromedriver.storage.googleapis.com/2.9/chromedriver_mac32.zip";
  FEATURE_CONTEXT="./features/bootstrap/FeatureContext.php";  
  FEATURE_DIR="./features/en/";
  FEATURE_EXAMPLE_DIR="./features/en/example/";
  FEATURE_EXAMPLE_A="./features/en/example/example-a.feature";
  FEATURE_EXAMPLE_B="./features/en/example/example-c.feature";
  FEATURE_EXAMPLE_C="./features/en/example/example-b.feature";

  DEFAULT_PROFILE[0]="default"; 
  DEFAULT_PROFILE[1]="firefox"; 
  DEFAULT_PROFILE[2]="firefox";
  YML_PROFILES[0]=${DEFAULT_PROFILE};
 
  
  FIREFOX_PROFILE[0]="firefox"; 
  FIREFOX_PROFILE[1]="firefox"; 
  FIREFOX_PROFILE[2]="firefox";
  YML_PROFILES[1]=${FIREFOX_PROFILE};
  
  CHROME_PROFILE[0]="chrome"; 
  CHROME_PROFILE[1]="googlechrome"; 
  CHROME_PROFILE[2]="chrome";
  YML_PROFILES[2]=${CHROME_PROFILE};
  
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
  read -p "Do you want to run with safari webdriver for mac osx[N/y]: " SAFARI_WEBDRIVER
  read -p "Do you want to install the chrome driver[N/y]: " INSTALL_CHROME_DRIVER
  

  if [ "${SAFARI_WEBDRIVER}" = "y" ]; then 
    echo "Webdriver URL:";
    echo ${DEFAULT_SELENIUM_SAFARI_WEBDRIVER}
    read -p "Please enter URL[Enter for default]: " SELENIUM_SAFARI_WEBDRIVER;
    if [ "${SELENIUM_SAFARI_WEBDRIVER}" = "" ]; then
      SELENIUM_SAFARI_WEBDRIVER=${DEFAULT_SELENIUM_SAFARI_WEBDRIVER}
    fi;
    echo "Downloading...";
    wget ${SELENIUM_SAFARI_WEBDRIVER};
    echo '';
    echo 'NOTE:';
    echo '--------------';
    echo 'Goto the behat directory and unzip the safari webdriver';
    echo 'then go to {safari_webdriver_folder}/org/openqa/selenium/safari/';
    echo 'double click on the SafariDriver.safariextz file to install';
    echo 'the safari extension';
    read -p "Press ENTER to continue."
  fi;  
  
  if [ "${INSTALL_CHROME_DRIVER}" = "y" ]; then
        echo "Chrome Driver ${DEFAULT_SELENIUM_CHROME_WEBDRIVER}";
        read -p "Please enter chrome driver URL[Enter for default]: " CHROME_DRIVER
        if [ "${CHROME_DRIVER}" = "" ]; then
            echo "Selenium chrome driver URL: "${DEFAULT_SELENIUM_CHROME_WEBDRIVER};
            CHROME_DRIVER=${DEFAULT_SELENIUM_CHROME_WEBDRIVER};
        fi;
        CHROME_WEBDRIVER_PARAMETERS="-Dwebdriver.chrome.driver=./chromedriver";
        wget ${CHROME_DRIVER} -O chromedriver.zip;
        unzip -o chromedriver.zip
  fi;
  
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

  clear
  echo ''
  echo 'INSTALLING'
  echo '------------------------';

  # Install Java, Firefox, Xvfb, and unzip
  #apt-get -y install openjdk-7-jre-headless firefox xvfb unzip

  wget ${SELENIUM_RELEASE} -O selenium-server-standalone.jar
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
  
  rm ${DEFAULT_BEHAT_YML}

  for PROFILE in "${YML_PROFILES[@]}"
  do

    echo -e ''${PROFILE[${PROFILE}][0]}':'"\n"\
            '  suites:'"\n"\
            '    default:'"\n"\
            '      contexts:'"\n"\
            '        - FeatureContext'"\n"\
            '        - Drupal\DrupalExtension\Context\DrupalContext'"\n"\
            '        - Drupal\DrupalExtension\Context\MinkContext'"\n"\
            '        - Drupal\DrupalExtension\Context\MessageContext'"\n"\
            '        - Drupal\DrupalExtension\Context\DrushContext'"\n"\
            '        - Drupal\DrupalExtension\Context\MarkupContext'"\n"\
            '        - Drupal\DrupalExtension\Context\RawDrupalContext'"\n"\
            '      paths:'"\n"\
            '        features: "features"'"\n"\
            '        bootstrap: "features/bootstrap"'"\n"\
            '  extensions:'"\n"\
            '    Behat\MinkExtension:'"\n"\
            '      goutte: ~'"\n"\
            '      javascript_session: selenium2'"\n"\
            '      selenium2: '"\n"\
            '        wd_host: http://'${ALIAS}':4444/wd/hub'"\n"\
            '        capabilities: { "browser": "'"${PROFILE[${PROFILE}][1]}"'", "browserName": "'${PROFILE[${PROFILE}][2]}'" }'"\n"\
            '      base_url: http://localhost'"\n"\
            '      browser_name: '${PROFILE[${PROFILE}][1]}"\n"\
            '      base_url: http://'${ALIAS}"\n"\
            '    Drupal\DrupalExtension:'"\n"\
            '      blackbox: ~'"\n"\
            '      api_driver: "drupal"'"\n"\
            '      drupal:'"\n"\
            '        drupal_root: "'${ROOT_DIR}'"'"\n"\
            '' >> ${DEFAULT_BEHAT_YML}
  done

  
  mkdir -p ${FEATURE_EXAMPLE_DIR}
  
  echo "Writing Example A";
  
  echo -e 'Feature: Drupal.org search'"\n"\
          '  In order to find modules on Drupal.org'"\n"\
          '  As a Drupal user'"\n"\
          '  I need to be able to use Drupal.org search'"\n"\
          ''"\n"\
          '  @javascript'"\n"\
          '  Scenario: Searching for "behat"'"\n"\
          '    Given I go to "https://drupal.org"'"\n"\
          '    Given I fill in "Behat Drupal Extension" for "search_block_form"'"\n"\
          '    Given I press "op"'"\n"\
          '    Then I should see "Behat Drupal Extension"'"\n"\
          ''"\n"\
          '  @javascript'"\n"\
          '  Scenario: Searching for "behat"'"\n"\
          '    Given I go to "http://docs.behat.org/en/v2.5/"'"\n"\
          '    Then I should see "behat documentation"' > ${FEATURE_EXAMPLE_A}
  
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
          'use Drupal\DrupalExtension\Context\RawDrupalContext;'"\n"\
          'use Behat\Behat\Context\SnippetAcceptingContext;'"\n"\
          'use Behat\Gherkin\Node\PyStringNode;'"\n"\
          'use Behat\Gherkin\Node\TableNode;'"\n"\
          ''"\n"\
          '/**'"\n"\
          ' * Defines application features from the specific context.'"\n"\
          ' */'"\n"\
          'class FeatureContext extends RawDrupalContext implements SnippetAcceptingContext {'"\n"\
          ''"\n"\
          '  /**'"\n"\
          '   * Initializes context.'"\n"\
          '   *'"\n"\
          '   * Every scenario gets its own context instance.'"\n"\
          '   * You can also pass arbitrary arguments to the'"\n"\
          '   * context constructor through behat.yml.'"\n"\
          '   */'"\n"\
          '  public function __construct() {'"\n"\
          '  }'"\n"\
          ''"\n"\
          '}' > ${FEATURE_CONTEXT};

  ./vendor/bin/behat --init
  ./vendor/bin/behat -dl
  ./vendor/bin/behat --append-snippets
  
  touch ./.installed
fi;

RUNNING_SELENIUM=`ps a | grep selenium-server-standalone | grep java`
if [ "${RUNNING_SELENIUM}" = "" ]; then  
  echo "Starting selenium server as a daemon by using SCREEN";
  screen -d -m -L java -jar ./selenium-server-standalone.jar ${CHROME_WEBDRIVER_PARAMETERS};
else
  echo "Selenium2 is running"
fi;

echo 'Running tests';

for PROFILE in "${RUN_PROFILES[@]}"
do
  ./vendor/bin/behat --profile ${PROFILE}
done

clear
echo '';
echo 'Creating test scripts';
echo '---------------------';
echo ''

TEST_SCRIPT_PROFILES='';
for PROFILE in "${RUN_PROFILES[@]}"
do
  TEST_SCRIPT_PROFILES=`echo ${TEST_SCRIPT_PROFILES} '"'${PROFILE}'"'`;
done

rm -Rf behat.sh

echo -e '#!/bin/bash'"\n"\
        ''"\n"\
        'PROFILES=('${TEST_SCRIPT_PROFILES}');'"\n"\
        'CHROME_WEBDRIVER_PARAMETERS="'${CHROME_WEBDRIVER_PARAMETERS}'"'"\n"\
        'RUNNING_SELENIUM=`ps a | grep selenium-server-standalone | grep java`'"\n"\
        'if [ "${RUNNING_SELENIUM}" = "" ]; then  '"\n"\
        '  echo "Starting selenium server as a daemon by using SCREEN";'"\n"\
        '  screen -d -m -L java -jar ./selenium-server-standalone.jar '${CHROME_WEBDRIVER_PARAMETERS}';'"\n"\
        'else'"\n"\
        '  echo "Selenium2 is running"'"\n"\
        'fi;'"\n"\
        'cd '${THIS_DIR}"\n"\
        ''"\n"\
        'for PROFILE in "${PROFILES[@]}"'"\n"\
        'do'"\n"\
        '  ./vendor/bin/behat --profile ${PROFILE}'"\n"\
        'done' > behat.sh
echo 'Making the behat.sh executable';
chmod ug+x behat.sh
echo 'To do the tests run ./behat.sh in this archive'