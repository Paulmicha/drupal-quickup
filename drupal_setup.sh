#!/bin/bash
# -*- coding: UTF8 -*-

##
#   Simple Bash Drupal install with Drush for local dev
#
#   @see http://drush.ws
#   @see http://drushmake.me
#   @author Paulmicha
#

SITE_NAME="This is your site name"
DRUPAL_PROFILE="minimal"

DB_HOST="localhost"
DB_NAME="my_database_name"
DB_USERNAME="my_database_user"
DB_PASSWORD="my_database_password"
DB_ADMIN_USERNAME="my_database_admin_user"
DB_ADMIN_PASSWORD="my_database_admin_password"

DRUPAL_ADMIN_USERNAME="drupal_admin_user"
DRUPAL_ADMIN_PASSWORD="drupal_admin_password"
DRUPAL_ADMIN_EMAIL="drupal.admin-user@email.com"
DRUPAL_SITE_EMAIL="drupal.site@email.com"

DRUPAL_FILES_FOLDER="sites/default/files"
DRUPAL_TMP_FOLDER="sites/default/tmp"
DRUPAL_PRIVATE_FILES_FOLDER="sites/default/private"

DEFAULT_UNIX_OWNER="www-data"
DEFAULT_UNIX_GROUP="www-data"
DEFAULT_UNIX_MOD="775"
WRITEABLE_UNIX_OWNER="www-data"
WRITEABLE_UNIX_GROUP="www-data"
WRITEABLE_UNIX_MOD="775"


#--------------------------------------
#       DB installation

echo "CREATE DATABASE IF NOT EXISTS $DB_NAME;
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWORD';" | mysql -u $DB_ADMIN_USERNAME -p$DB_ADMIN_PASSWORD


#--------------------------------------
#       Drupal installation

chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
chmod $DEFAULT_UNIX_MOD . -R

#       Drupal download + initialisation
echo -n "api = 2
core = 7.x
projects[] = drupal" > tmp.make
drush make tmp.make -y
rm tmp.make
drush si $DRUPAL_PROFILE --db-url=mysql://$DB_USERNAME:$DB_PASSWORD@$DB_HOST/$DB_NAME --site-name="$SITE_NAME" --account-name="$DRUPAL_ADMIN_USERNAME" --account-pass="$DRUPAL_ADMIN_PASSWORD" --account-mail="$DRUPAL_ADMIN_EMAIL" --site-mail="$DRUPAL_SITE_EMAIL" -y

#       Drupal modules folder structure setup
mkdir sites/all/libraries
mkdir sites/all/modules/custom
mkdir sites/all/modules/contrib
chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
chmod $DEFAULT_UNIX_MOD . -R

#       Drupal File System folders setup
mkdir $DRUPAL_TMP_FOLDER
mkdir $DRUPAL_PRIVATE_FILES_FOLDER
chown $WRITEABLE_UNIX_OWNER:$WRITEABLE_UNIX_GROUP $DRUPAL_FILES_FOLDER -R
chmod $WRITEABLE_UNIX_MOD $DRUPAL_FILES_FOLDER -R
chown $WRITEABLE_UNIX_OWNER:$WRITEABLE_UNIX_GROUP $DRUPAL_TMP_FOLDER -R
chmod $WRITEABLE_UNIX_MOD $DRUPAL_TMP_FOLDER -R
chown $WRITEABLE_UNIX_OWNER:$WRITEABLE_UNIX_GROUP $DRUPAL_PRIVATE_FILES_FOLDER -R
chmod $WRITEABLE_UNIX_MOD $DRUPAL_PRIVATE_FILES_FOLDER -R
drush vset --yes file_public_path $DRUPAL_FILES_FOLDER
drush vset --yes file_private_path $DRUPAL_PRIVATE_FILES_FOLDER
drush vset --yes file_temporary_path $DRUPAL_TMP_FOLDER


#-----------------------------------------
#       From minimal install
#       to my "standard" dev setup

#       Minimal install : missing useful Drupal core modules
drush en taxonomy field_ui -y

#       Drupal modules : minimum + dev + admin
drush dl admin_menu devel backup_migrate libraries transliteration
drush en admin_menu admin_menu_toolbar devel backup_migrate libraries transliteration -y

#       DB dump 1 : "standard" install restore point
drush cc all
drush bb


#-----------------------------------------
#       Usual modules

#       Basic functions
drush dl token
drush en token -y
drush dl ctools views
drush en ctools views views_ui -y
#drush dl date
#drush en date -y
#drush en date_all_day date_popup date_repeat date_repeat_field date_views -y

#       Content architecture
drush dl entity
drush en entity -y
drush dl entityreference
drush en entityreference -y
drush dl relation
drush en relation relation_ui -y

#       Media
drush dl media-7.x-2.x-dev file_entity
drush en file_entity media -y

#       SEO
drush dl pathauto redirect globalredirect
drush en pathauto redirect globalredirect -y
drush dl subpathauto
drush en subpathauto -y
drush dl page_title metatag
drush en page_title metatag -y
drush dl xmlsitemap
drush en xmlsitemap -y

#       Linked Data
drush dl microdata
drush en microdata -y

#       DB dump 2 : "usual" install restore point
drush cc all
drush bb


#-----------------------------------------
#       "Opinionated" part

#       A Drupal base theme that rocks
drush dl mothership
drush en mothership -y

#       Layout management
#drush dl context
#drush en context -y
#drush dl delta
#drush en delta -y
#drush dl ds
#drush en ds -y

#       DB dump 3 : "start" restore point
drush cc all
drush bb


#-----------------------------------------
#       Performance

#drush dl entitycache
#drush en entitycache -y

#drush dl filecache
#drush en filecache -y

#drush dl varnish
#drush en varnish -y

#drush dl memcache
#drush en memcache -y

#drush dl apc
#drush en apc -y

#drush dl boost
#drush en boost -y



