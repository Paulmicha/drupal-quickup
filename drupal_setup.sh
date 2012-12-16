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

#       Manual updates
drush dis update -y

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
#drush dl dates
#drush en dates -y
#       @todo check download ckeditor lib
#drush dl ckeditor
#drush en ckeditor -y
#drush dl linkit
#drush en linkit -y
#drush dl insert
#drush en insert -y

#       Content architecture
drush dl entity
drush en entity -y
drush dl entityreference
drush en entityreference -y
#       @see also http://drupal.org/project/entity_tree
#drush dl relation
#drush en relation relation_ui -y

#       User profiles
#drush dl profile2
#drush en profile2 -y

#       Media
drush dl media-7.x-2.x-dev file_entity
drush en media file_entity -y
#drush dl bulk_media_upload
#drush en bulk_media_upload -y
#drush dl plupload
#       @todo : get lib from https://github.com/downloads/moxiecode/plupload/plupload_1_5_4.zip
#drush en plupload -y
#drush dl colorbox
#drush en colorbox -y
#drush dl emfield
#drush en emfield -y
#drush dl videojs
#drush en videojs -y
#drush dl popcornjs
#drush en popcornjs -y

#       File storage
#drush dl storage_api
#drush en storage_api -y

#       Linked Data
drush dl microdata
drush en microdata -y
#       OR
#drush dl schemaorg
#drush en schemaorg -y

#       SEO
drush dl metatag
drush en metatag -y
drush dl pathauto redirect globalredirect
drush en pathauto redirect globalredirect -y
#drush dl subpathauto
#drush en subpathauto -y
#drush dl xmlsitemap
#drush en xmlsitemap -y
#drush dl rich_snippets
#drush en rich_snippets -y
#drush dl seo_checklist
#drush en seo_checklist -y
#drush dl menu_attributes
#drush en menu_attributes -y

#       Other
#drush dl webform
#drush en webform -y


#-----------------------------------------
#       Email

#drush dl mailsystem
#drush en mailsystem -y

#cd sites/all/libraries
#       check link for latest version
#       @see http://swiftmailer.org/
#wget http://swiftmailer.org/download_file/Swift-4.2.2.tar.gz --quiet
#tar -zxf Swift-4.2.2.tar.gz
#mv Swift-4.2.2 swiftmailer
#rm Swift-4.2.2.tar.gz
#chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
#chmod $DEFAULT_UNIX_MOD . -R
#cd ../../../
#drush dl swiftmailer
#drush en swiftmailer -y

#       DB dump 2 : "usual" install restore point
drush bb


#-----------------------------------------
#       UX / Redaction helpers

#       Input filters
#drush dl token_filter
#drush en token_filter -y

#       UI helpers
#drush dl content_menu
#drush en content_menu -y
#drush dl draggableviews
#drush en draggableviews -y
drush dl module_filter
drush en module_filter -y
#drush dl permission_filter
#drush en permission_filter -y
#drush dl views_slideshow
#drush en views_slideshow -y

#       Chosen (better select fields UX)
cd sites/all/libraries
wget https://github.com/harvesthq/chosen/archive/master.zip --quiet --no-check-certificate
unzip master.zip
mv chosen-master/chosen chosen
rm master.zip
rm chosen-master -r
cd ../../../
drush dl chosen
drush en chosen -y
drush vset --yes chosen_minimum "0"
drush vset --yes chosen_jquery_selector "select:visible:not('.widget-type-select')"

#       Breadcrumbs
drush dl crumbs
drush en crumbs -y
#drush dl path_breadcrumbs
#drush en path_breadcrumbs -y

#       Other
#drush dl article_templater
#drush en article_templater -y


#-----------------------------------------
#       Multilingual (todo)

#drush dl i18n
#drush en i18n -y


#-----------------------------------------
#       Workflow & content moderation

#drush dl revisioning
#drush en revisioning -y
#drush dl wokflow
#drush en wokflow workflow_admin_ui workflow_access -y

#       Untested
#drush dl workbench
#drush en workbench -y


#-----------------------------------------
#       Access management

#drush dl content_access
#drush en content_access -y
#drush dl field_permissions
#drush en field_permissions -y
#drush dl nodeaccess_nodereference
#drush en nodeaccess_nodereference -y
#drush dl node_access_rebuild_bonus
#drush en node_access_rebuild_bonus -y


#-----------------------------------------
#       Site building / Content Architecture

#       Structure
#drush dl eva
#drush en eva -y
#drush dl nodequeue
#drush en nodequeue -y
#drush dl skyfield
#drush en skyfield -y
#drush dl field_group
#drush en field_group -y
#drush dl field_collection
#drush en field_collection -y
#drush dl content_type_groups
#drush en content_type_groups -y
#drush dl restrict_node_page_view
#drush en restrict_node_page_view -y
#drush dl hierarchical_term_formatter
#drush en hierarchical_term_formatter -y

#       Import / Export / Migration
#drush dl feeds
#drush en feeds -y
#drush dl phpexcel
#drush en phpexcel -y
#drush dl migrate
#drush en migrate migrate_ui -y

#       Other
#drush dl flag
#drush en flag -y
#drush dl flag_weights
#drush en flag_weights -y
#drush dl splashify
#drush en splashify -y

#       Google Drive
#drush dl Droogle
#drush en Droogle -y


#-----------------------------------------
#       Social stuff

#       Login/import profile from third-party providers
#       @see http://janrain.com/products/engage/engage-pricing/ (free plan until 2500 users/year)
#drush dl rpx
#drush en rpx -y
#       Login with Facebook + patch on the way for importing profile data
#       @see http://drupal.org/node/1507336#comment-6774122
#drush dl fboauth
#drush en fboauth -y
#       (untested) Login with Gmail / Hotmail / Yahoomail
#drush dl gconnect
#drush en gconnect -y

#       Twitter module : supports 3rd-party login (with oauth), tweets agregation (import), tweets publication (push)
#drush dl oauth twitter
#drush en oauth twitter -y
#       Simpler, read-only Twitter module
#drush dl twitter_pull
#drush en twitter_pull -y
#       Twitter profile infos
#drush dl twitter_profile
#drush en twitter_profile -y

#       Social Agregation (twitter + rss feeds)
#drush dl activitystream
#drush en activitystream -y


#-----------------------------------------
#       Dev utils

#       Drush extensions
#drush dl drush_iq
#drush en drush_iq -y
drush dl drush_cleanup
drush en drush_cleanup -y

#       Config / deployment
#drush dl features strongarm
#drush en features strongarm -y
#       Alternative : "true" configuration management
#drush dl configuration
#drush en configuration -y

#       Emails
drush dl reroute_email
drush en reroute_email -y

#       Batch
#drush dl better_batch
#drush en better_batch -y

#       Cron
#drush dl elysia_cron
#drush en elysia_cron -y

#       Maintenance
#drush dl watchdog_digest
#drush en watchdog_digest -y

#       DB-related utils
#drush dl schema
#drush en schema -y


#-----------------------------------------
#       Theming & Front-end

#       Base theme (mortendk rocks)
drush dl mothership
drush en mothership -y
#       Generate custom sub-theme (mothership comes with a neat drush command to generate a sub-theme)
drush mothership "$SITE_NAME"

#       Preprocessors
#drush dl sass
#drush en sass -y
#drush dl less
#drush en less -y

#       Layout management
#drush dl ds
#drush en ds -y
#drush dl themekey
#drush en themekey -y
#drush dl context
#drush en context -y
#drush dl delta
#drush en delta -y

#       Utils / Formatters
#drush dl css_injector
#drush en css_injector -y
#drush dl js_injector
#drush en js_injector -y
#drush dl token_formatters
#drush en token_formatters -y

#       Front-end app architecture
#drush dl backbone
#drush en backbone -y

#       CSS / Styling (theme building)
drush dl design
drush en design -y
drush dl styleguide
drush en styleguide -y


#-----------------------------------------
#       Performance

#       Faster 404
drush dl fast_404
drush en fast_404 -y

#       Front-end optimization
#drush dl advagg
#drush en advagg -y

#       Faster callbacks
#drush dl js_callback
#drush en js_callback -y
#drush dl js
#drush en js -y

#       Pjax navigation
#drush dl pjax
#drush en pjax -y

#       Memory usage
#drush dl role_memory_limit
#drush en role_memory_limit -y

#       Cache
#drush dl filecache
#drush en filecache -y
#       OR
#drush dl boost
#drush en boost -y

#drush dl entitycache
#drush en entitycache -y
#drush dl expire
#drush en expire -y
#drush dl cache_graceful
#drush en cache_graceful -y
#drush dl cache_lifetime_options
#drush en cache_lifetime_options -y
#drush dl cdn
#drush en cdn -y
#drush dl apc
#drush en apc -y
#drush dl memcache
#drush en memcache -y
#drush dl varnish
#drush en varnish -y
#drush dl purge
#drush en purge -y
#drush dl esi
#drush en esi -y

#       Other
#drush dl httprl
#drush en httprl -y


#       DB dump 3 : "start" restore point
drush bb


