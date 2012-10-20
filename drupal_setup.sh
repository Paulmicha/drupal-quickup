#!/bin/bash
# -*- coding: UTF8 -*-

##
#   Drupal simple Shell install script for rapid dev start
#   Requires drush
#
#   @see http://drush.ws
#   @see http://drushmake.me
#
#   @version 1.1
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
#mkdir sites/all/modules/features
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

#       Minimal install : missing needed Drupal core modules
drush en taxonomy field_ui -y

#       Drupal modules : minimum + dev + admin
drush dl admin_menu devel backup_migrate libraries transliteration
drush en admin_menu admin_menu_toolbar devel backup_migrate libraries transliteration -y

#       DB dump 1 : "standard" install restore point
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
#       @see also http://drupal.org/project/entity_tree
#drush dl relation
#drush en relation relation_ui -y

#       Media
drush dl media-7.x-2.x-dev file_entity
drush en file_entity media -y
#drush dl bulk_media_upload
#drush en bulk_media_upload -y
#drush dl plupload
#       @todo : get lib from https://github.com/downloads/moxiecode/plupload/plupload_1_5_4.zip
#drush en plupload -y

#       File storage
#drush dl storage_api
#drush en storage_api -y

#       SEO
drush dl page_title metatag
drush en page_title metatag -y
drush dl pathauto redirect globalredirect
drush en pathauto redirect globalredirect -y
#drush dl subpathauto
#drush en subpathauto -y
#drush dl xmlsitemap
#drush en xmlsitemap -y

#       Linked Data
drush dl microdata
drush en microdata -y


#-----------------------------------------
#       HTML Emailing : swiftmailer

cd sites/all/libraries

#       check link for latest version
#       @see http://swiftmailer.org/
wget http://swiftmailer.org/download_file/Swift-4.2.1.tar.gz --quiet
tar -zxf Swift-4.2.1.tar.gz
mv Swift-4.2.1 swiftmailer
rm Swift-4.2.1.tar.gz
chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
chmod $DEFAULT_UNIX_MOD . -R

cd ../../../

drush dl swiftmailer
drush en swiftmailer -y


#       DB dump 2 : "usual" install restore point
drush bb


#-----------------------------------------
#       UX / Redaction helpers

#drush dl token_filter
#drush en token_filter -y


#-----------------------------------------
#       Workflow & content moderation

#drush dl revisioning
#drush en revisioning -y

#drush dl wokflow
#drush en wokflow workflow_admin_ui workflow_access -y


#-----------------------------------------
#       Site building / Dev utils

#drush dl features
#drush en features -y

#       DB-related utils
#drush dl schema
#drush en schema -y

#       Drush extensions
#drush dl drush_iq
#drush en drush_iq -y


#-----------------------------------------
#       "Opinionated" part (front-end)

#       Base theme
#drush dl mothership
#drush en mothership -y
#drush dl omega
#drush en omega -y

#       Layout management
#drush dl ds
#drush en ds -y
#drush dl themekey
#drush en themekey -y
#drush dl context
#drush en context -y
#drush dl delta
#drush en delta -y

#       Front-end app architecture
#drush dl backbone
#drush en backbone -y

#       Breadcrumbs
#drush dl crumbs
#drush en crumbs -y
#drush dl path_breadcrumbs
#drush en path_breadcrumbs -y

#       CSS / Styling
drush dl styleguide
drush en styleguide -y


#-----------------------------------------
#       Performance

#drush dl js
#drush en js -y

#drush dl js_callback
#drush en js_callback -y

drush dl fast_404
drush en fast_404 -y

#drush dl entitycache
#drush en entitycache -y

#drush dl filecache
#drush en filecache -y
#       OR
#drush dl boost
#drush en boost -y

#drush dl cdn
#drush en cdn -y

#drush dl apc
#drush en apc -y

#drush dl memcache
#drush en memcache -y

#drush dl varnish
#drush en varnish -y

#drush dl esi
#drush en esi -y

#       Cron
#drush dl elysia_cron
#drush en elysia_cron -y



#       DB dump 3 : "start" restore point
drush bb


