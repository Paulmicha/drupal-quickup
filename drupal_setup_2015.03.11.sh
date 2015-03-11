#!/bin/bash
# -*- coding: UTF8 -*-

##
#   Drupal simple Shell install script for rapid dev start
#   Requires drush
#
#   @version 2015/03/11 02:07:01
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
DEFAULT_UNIX_MOD="770"
WRITEABLE_UNIX_OWNER="www-data"
WRITEABLE_UNIX_GROUP="www-data"
WRITEABLE_UNIX_MOD="770"
PROTECTED_CFG_UNIX_MOD="550"


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

#       Make config write-protected
chmod $PROTECTED_CFG_UNIX_MOD sites/default
chmod $PROTECTED_CFG_UNIX_MOD sites/default/settings.php


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

#       Theme for admin menu
drush dl adminimal_admin_menu
drush en adminimal_admin_menu -y

#       DB dump 1 : "standard" install restore point
drush bb


#-----------------------------------------
#       Usual modules

#       Basic functions
drush dl token
drush en token -y
drush dl ctools views
drush en ctools views views_ui -y
drush dl date
drush en date -y
#drush en date_all_day date_popup date_repeat date_repeat_field date_views -y
drush en date_views -y
#drush dl dates
#drush en dates -y

#       Content architecture
drush dl entity
drush en entity -y
drush dl entityreference
drush en entityreference -y

#       Admin views
drush dl admin_views
drush en admin_views -y

#       The CCK of Entities (UI for creating custom Entities)
#drush dl eck
#drush en eck -y

#       Relations
#drush dl relation relation_add
#drush en relation relation_ui relation_add -y

#       User profiles
#drush dl profile2
#drush en profile2 -y
#       Note 2013/02/21 18:50:57 - when using Profile2, the "label" column always gets the value of bundle title
#       -> using this auto_entitylabel is required when using an entity_reference field to target the profile entites directly using autocomplete
#drush dl auto_entitylabel
#drush en auto_entitylabel -y


#       File storage
#drush dl storage_api
#drush en storage_api -y

#       Linked Data
#drush dl schemaorg
#drush en schemaorg -y

#       SEO
#drush dl metatag
#drush en metatag -y
drush dl pathauto
drush en pathauto -y
#drush dl pathologic
#drush en pathologic -y
drush dl redirect
drush en redirect -y
#drush dl xmlsitemap
#drush en xmlsitemap -y
#drush dl subpathauto
#drush en subpathauto -y

#drush dl menu_attributes
#drush en menu_attributes -y

#       Other
#drush dl webform
#drush en webform -y

#       Nice to-do list worthy to look at before going live
#drush dl prod_check
#drush en prod_check -y

#       Image utils :
#       • Flush all image styles or each image style individually
drush dl imagestyleflush
drush en imagestyleflush -y
#       • Generate image styles right after an image is uploaded and also on entity save
drush dl imageinfo_cache
drush en imageinfo_cache -y
#       • Generate and stores MD5, SHA-1 and/or SHA-256 hashes for each file uploaded to the site
drush dl filehash
drush en filehash -y
#       • Implement a 'hash://' schema to store up to ~ ten million files - ex: a0/49/a0493e27f48b50e18312b9f4508fc29d.txt
#drush dl hash_wrapper-7.x-1.x-dev
#drush en hash_wrapper -y
#       • [unstable] Aliases for uploaded files (i.e., no more '/sites/default/files/')
#drush dl file_aliases
#drush en file_aliases -y


#-----------------------------------------
#       Email

drush dl mailsystem
drush en mailsystem -y

cd sites/all/libraries
#       Check link for latest version (current latest: 5.3.1 - as of 2015/03/11 02:15:43)
#       @see http://swiftmailer.org/
wget https://github.com/swiftmailer/swiftmailer/archive/v5.3.1.tar.gz --quiet --no-check-certificate
tar -zxf v5.3.1.tar.gz
mv swiftmailer-5.3.1 swiftmailer
rm v5.3.1.tar.gz
chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
chmod $DEFAULT_UNIX_MOD . -R
cd ../../../
drush dl swiftmailer
drush en swiftmailer -y

#       Emails "throttling"
#drush dl queue_mail
#drush en queue_mail -y

#       DB dump 2 : "usual" install restore point
drush bb


#-----------------------------------------
#       Useful field types

#       (Core)
drush en number -y

#drush dl telephone
#drush en telephone -y
#drush dl email
#drush en email -y
#drush dl invisimail
#drush en invisimail -y

#drush dl url
#drush en url -y

#       untested 2014/06/05 02:55:21 - module monday entry
#drush dl tablefield
#drush en tablefield -y


#-----------------------------------------
#       UX / Redaction helpers

#       Better Login / Register UX
drush dl super_login
drush en super_login -y

#       Input filters
#       @todo : custom module for custom token
#drush dl token_filter
#drush en token_filter -y

#       Prevent Simultaneous Edits
#drush dl content_lock
#drush en content_lock -y

#       Marquer / Linker of word occurrences
#drush dl word_link
#drush en word_link -y

#       Collapse input format description
drush dl hide_formats
drush en hide_formats -y

#       Prevent double submit click
#drush dl hide_submit
#drush en hide_submit -y

#       UI helpers
#drush dl content_menu
#drush en content_menu -y
#drush dl options_element
#drush en options_element -y
#drush dl select_or_other
#drush en select_or_other -y
#drush dl term_reference_tree
#drush en term_reference_tree -y

#       Entity reference helpers
#drush dl inline_entity_form
#drush en inline_entity_form -y

#       Node publishing options visibility
#drush dl override_node_options
#drush en override_node_options -y

#       Adds a publish and unpublish button for a simpler editorial workflow
#       @see http://www.lullabot.com/articles/module-monday-publish-button
#drush dl publish_button
#drush en publish_button -y

#       Alternative
#drush dl publishcontent
#drush en publishcontent -y

#       Adding custom node publishing options
#drush dl custom_pub
#drush en custom_pub -y

#       Breadcrumbs
#drush dl crumbs
#drush en crumbs -y
#       Alternative :
#drush dl path_breadcrumbs
#drush en path_breadcrumbs -y

#       Complement to Crumbs & alternative to menu_block
#       (apparently, no admin UI though)
#drush dl menupoly
#drush en menupoly -y

#       Replace anything that's passed through t()
#drush dl stringoverrides
#drush en stringoverrides -y

#       Modal Forms (using CTools)
#drush dl modal_forms
#drush en modal_forms -y

#       jQuery update
drush dl jquery_update
drush en jquery_update -y

#       Colorbox
#cd sites/all/libraries
#wget https://github.com/jackmoore/colorbox/archive/master.zip --quiet --no-check-certificate
#unzip master.zip
#mv colorbox-master colorbox
#rm master.zip
#chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
#chmod $DEFAULT_UNIX_MOD . -R
#cd ../../../
#drush dl colorbox
#drush en colorbox -y


#-----------------------------------------
#       Multilingual

#       Install another language
drush en locale -y
drush dl l10n_update
drush en l10n_update -y

#       Handle content translation
#drush en translation -y
#drush dl i18n
#drush en i18n i18n_node i18n_select i18n_redirect i18n_user -y
#drush en i18n_variable -y
#drush en i18n_field -y
#drush en i18n_sync -y
#drush en i18n_path -y
#drush en i18n_menu -y
#drush en i18n_block -y
#drush en i18n_taxonomy -y

#       Translation overview
#drush dl translation_overview
#drush en translation_overview -y

#       Language detection : cookie
#       @see https://www.drupal.org/node/2398959
#drush dl language_cookie
#drush en language_cookie -y


#-----------------------------------------
#       Security

#drush dl seckit
#drush en seckit -y


#-----------------------------------------
#       Workflow & content moderation

#drush dl revisioning
#drush en revisioning -y
#drush dl wokflow
#drush en wokflow workflow_admin_ui workflow_access -y

#drush dl workbench
#drush en workbench -y


#-----------------------------------------
#       Access management

#drush dl acl
#drush en acl -y
drush dl content_access
drush en content_access -y
#drush dl field_permissions
#drush en field_permissions -y
drush dl restrict_node_page_view
drush en restrict_node_page_view -y
drush dl nodeaccess_nodereference
drush en nodeaccess_nodereference -y
#drush dl node_access_relation
#drush en node_access_relation -y
#drush dl node_access_rebuild_bonus
#drush en node_access_rebuild_bonus -y

#       Scheduled field access
#drush dl fieldscheduler
#drush en fieldscheduler -y


#-----------------------------------------
#       Site building / Content Architecture

#       Helper modules
#       Export/import support for : Node types, Taxonomy, User, Fields, Field Groups
#drush dl bundle_copy
#drush en bundle_copy -y

#       Collection of useful UI tools for working with fields (untested) :
#           Apply a vocabulary to multiple entities and bundles at once
#           Clone any field instance to multiple entities and bundles
#           Clone all field instance of a bundle to multiple entities and bundles
#           Delete multiple instances of a field
#drush dl field_tools
#drush en field_tools -y

#       Structure
#drush dl eva
#drush en eva -y
#drush dl nodequeue
#drush en nodequeue -y
#drush dl field_group
#drush en field_group -y
#drush dl field_collection
#drush en field_collection -y

#drush dl draggableviews
#drush en draggableviews -y
#drush dl skyfield
#drush en skyfield -y
#drush dl content_type_groups
#drush en content_type_groups -y

#       Layout "presets" for use inside body / wysiwyg
#drush dl article_templater
#drush en article_templater -y

#       Display term and its parents
#drush dl hierarchical_term_formatter
#drush en hierarchical_term_formatter -y

#       Flag
drush dl flag
drush en flag -y
#drush dl flag_weights
#drush en flag_weights -y

#       Rules
#drush dl rules
#drush en rules rules_admin -y

#       Migrate
#drush dl migrate
#drush en migrate migrate_ui -y

#       Import / Export
#drush dl feeds
#drush en feeds -y
#drush dl phpexcel
#drush en phpexcel -y

#       Other
#drush dl Droogle
#drush en Droogle -y
#drush dl splashify
#drush en splashify -y


#-----------------------------------------
#       Social stuff

#       Realname
#       choose fields from the user profile that will be used to add a "real name" element (method) to a user object.
#       It will also optionally set all nodes and comments to show this name.
#drush dl realname
#drush en realname -y

#       OAuth alternative (Doesn't depend on any external service)
drush dl hybridauth
cd sites/all/libraries
wget https://github.com/hybridauth/hybridauth/archive/master.zip --quiet --no-check-certificate
unzip master.zip
mv hybridauth-master hybridauth
rm master.zip
chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
chmod $DEFAULT_UNIX_MOD . -R
cd ../../../
drush en hybridauth -y

#       Twitter module : supports 3rd-party login (with oauth), tweets agregation (import), tweets publication (push)
#drush dl oauth twitter
#drush en oauth_common twitter -y
#       Simpler, read-only Twitter module
#drush dl twitter_pull
#drush en twitter_pull -y
#       Twitter profile infos
#drush dl twitter_profile
#drush en twitter_profile -y

#       Force users to complete their profile
#drush dl pfff
#drush en pfff -y

#       Social Aggregation (twitter + rss feeds)
#drush dl activitystream
#drush en activitystream -y

#       Notifications / Subscription / Journaling - Framework (Gizra inside)
#drush dl message
#drush en message -y
#drush dl message_subscribe
#drush en message_subscribe message_subscribe_ui -y
#drush dl message_notify
#drush en message_notify -y


#-----------------------------------------
#       Geolocalization

#       Addressfield (implements xNAL standard)
#drush dl addressfield
#drush en addressfield -y

#       Geocoding (make "geofield" points from "addressfield", "geolocation", or "location")
drush dl geocoder
drush en geocoder -y
#drush dl geocoder_autocomplete
#drush en geocoder_autocomplete -y

#       Other Field-based implementation
#       ("light-weight, easy-to-use and robust alternative")
drush dl geolocation
drush en geolocation -y

#       Geofield (stores complex coordinates)
#       Note : also contains a simple display formatter using GMap (module "geofield_map")
#drush dl geofield
#drush en geofield geofield_map -y

#       Leaflet (light map display)
#drush dl leaflet
#drush en leaflet -y

#       OpenLayers (heavier, more sophisticated map display)
#drush dl openlayers
#drush en openlayers -y

#       Location (untested)
#drush dl location
#drush en location -y
#drush dl locationmap
#drush en locationmap -y

#       Geo-search
#drush dl search_api_location
#drush en search_api_location -y
#drush dl openlayers_solr
#drush en openlayers_solr -y


#-----------------------------------------
#       Dev utils

#       Dummy content
#drush dl realistic_dummy_content
#drush en realistic_dummy_content -y

#       Configuration in code
#drush dl features strongarm
#drush en features strongarm -y
#drush dl ftools
#drush en ftools -y
#drush dl features_override
#drush en features_override -y

#       Configuration in code - experimental alternative (Drupal 8 inspired)
#drush dl configuration
#drush en configuration -y

#       Emails (sandbox-like behaviour : sends all emails from Drupal to a single address)
#drush dl reroute_email
#drush en reroute_email -y

#       Drush extensions
#       Remove unnecessary files
drush dl drush_cleanup -n
drush cleanup

#       Cron enhancement
drush dl elysia_cron
drush en elysia_cron -y

#       alternative :
#       Cron enhancement (untested)
#drush dl ultimate_cron
#drush en ultimate_cron -y

#       Session-related utils
#drush dl session_cache
#drush en session_cache -y

#       Modules introspection / overview
#drush dl moduleinfo
#drush en moduleinfo -y

#       Monitoring
#drush dl performance
#drush en performance -y

#       Batch
#drush dl better_batch
#drush en better_batch -y

#       Maintenance
#drush dl watchdog_digest
#drush en watchdog_digest -y

#       DB-related utils
#drush dl schema
#drush en schema -y


#-----------------------------------------
#       Theming & Front-end

#       Conditional stylesheets for IE
#drush dl conditional_styles
#drush en conditional_styles -y

#       Front-end Utils
drush dl magic
drush en magic -y

#       Base theme
#drush dl mothership
#drush en mothership -y

#       Admin theme :
#       Responsive Bartik Sans-serif [wip]
cd sites/all/themes
wget https://github.com/Paulmicha/drupal-7.rbc/archive/master.zip --quiet --no-check-certificate
unzip master.zip
mv drupal-7.rbc-master rbc
rm master.zip
chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
chmod $DEFAULT_UNIX_MOD . -R
cd ../../
drush en rbc -y
drush vset --yes theme_default rbc
drush vset --yes admin_theme rbc

#       HTML 5 helpers
drush dl elements html5_tools
drush en elements html5_tools -y
drush dl fences
drush en fences -y

#       Layout management - Panels
#drush dl panels
#drush en page_manager -y
#       Per-node Panels layout selection
#drush dl panelizer
#drush en panelizer -y

#       Layout management - Display Suite
#drush dl ds
#drush en ds ds_ui ds_forms -y
#drush en ds ds_devel ds_extras ds_forms ds_format ds_ui ds_search -y

#       Layout management - Custom Entity view modes
#drush dl entity_view_mode
#drush en entity_view_mode -y

#       "Poorman's Panels" - Good to know for anything simple enough
#drush dl fieldblock
#drush en fieldblock -y

#       Layout management - Context
#drush dl context
#drush en context context_ui -y
#drush en context context_layouts context_ui -y

#       Layout management - Theme Key (untested)
#drush dl themekey
#drush en themekey -y

#       Layout management - Delta (untested)
#drush dl delta
#drush en delta delta_ui delta_blocks -y
#drush en delta delta_ui delta_color delta_blocks -y

#       Utils / Formatters
#drush dl css_injector
#drush en css_injector -y
#drush dl js_injector
#drush en js_injector -y
#drush dl token_formatters
#drush en token_formatters -y

#       Front-end app architecture (untested)
#drush dl backbone
#drush en backbone -y

#       Typography helpers
#drush dl typogrify
#drush en typogrify -y

#       CSS / Styling (theme building)
#drush dl styleguide
#drush en styleguide -y
#drush dl design
#drush en design_test -y


#-----------------------------------------
#       Commerce

#drush dl commerce
#drush en commerce commerce_ui -y
#drush en commerce_customer commerce_customer_ui -y
#drush en commerce_price -y
#drush en commerce_line_item commerce_line_item_ui -y
#drush en commerce_order commerce_order_ui -y
#drush en commerce_checkout commerce_payment commerce_product -y
#drush en commerce_cart commerce_product_pricing -y
#drush en commerce_tax -y
#drush en commerce_product_ui -y
#drush en commerce_tax_ui -y

#       Stock
#drush dl commerce_stock
#drush en commerce_stock -y

#       Payment
#drush dl commerce_cheque
#drush en commerce_cheque -y
#drush dl commerce_pay_in_person
#drush en commerce_pay_in_person -y
#drush dl commerce_bank_transfer
#drush en commerce_bank_transfer -y

#       Invoice (untested)
#drush dl commerce_billy
#drush en commerce_billy -y


#-----------------------------------------
#       Performance

#       Faster 404
#       @see http://drupal.org/node/1500092
#       -> to re-test as of 7.x-1.4
#drush dl fast_404
#drush en fast_404 -y

#       Faster callbacks (ajax)
#drush dl js
#drush en js -y
#       (Legacy module)
#drush dl js_callback
#drush en js_callback -y

#       Replacement for Drupal Core's default cache implementation
#       @see http://www.metaltoad.com/blog/how-drupals-cron-killing-you-your-sleep-simple-cache-warmer
#       In your settings.php file, you'll need to add the following lines to force Drupal to use the ADBC backend :
#       <?php
#       $conf['cache_backends'][] = 'sites/all/modules/adbc/adbc.cache.inc';
#       $conf['cache_default_class'] = 'AlternativeDrupalDatabaseCache';
#       ?>
#drush dl adbc
#drush en adbc -y

#       File Caches
#drush dl boost
#drush en boost -y
#       OR
#drush dl filecache
#drush en filecache -y

#       Drupal core JS optimization
#drush dl speedy
#drush en speedy -y

#       Drupal core JS / CSS aggregation optimization
#drush dl agrcache
#drush en agrcache -y
#drush dl core_library
#drush en core_library -y
#drush dl advagg
#drush en advagg -y

#       Pjax navigation
#drush dl pjax
#drush en pjax -y

#       Memory usage
#drush dl role_memory_limit
#drush en role_memory_limit -y

#       More cache backends / utilities
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
#drush bb

