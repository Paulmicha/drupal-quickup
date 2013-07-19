#!/bin/bash
# -*- coding: UTF8 -*-

##
#   Drupal simple Shell install script for rapid dev start
#   Requires drush
#
#   @see http://drush.ws
#   @see http://drushmake.me
#
#   @version 1.8
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

#       Used if you choose the "configuration" module
DRUPAL_CONFIGURATION_FILES_FOLDER="sites/all/configuration"

DEFAULT_UNIX_OWNER="www-data"
DEFAULT_UNIX_GROUP="www-data"
DEFAULT_UNIX_MOD="775"
WRITEABLE_UNIX_OWNER="www-data"
WRITEABLE_UNIX_GROUP="www-data"
WRITEABLE_UNIX_MOD="775"
PROTECTED_CFG_UNIX_MOD="555"


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

#       Used if you choose the "configuration" module
mkdir $DRUPAL_CONFIGURATION_FILES_FOLDER
chown $WRITEABLE_UNIX_OWNER:$WRITEABLE_UNIX_GROUP $DRUPAL_CONFIGURATION_FILES_FOLDER -R
chmod $WRITEABLE_UNIX_MOD $DRUPAL_CONFIGURATION_FILES_FOLDER -R

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
drush en date_all_day date_popup date_repeat date_repeat_field date_views -y
drush dl dates
drush en dates -y
#drush dl menu_block
#drush en menu_block -y

#       Content architecture
drush dl entity
drush en entity -y
drush dl entityreference
drush en entityreference -y

#       The CCK of Entities (UI for Entities customizations)
#drush dl eck
#drush en eck -y

#       Entity reference helpers :
#       Tested 10:28 16/02/2013 - Notes :
#           default config disallows selection of existing nodes, can be configured
#           This module still requires patch http://drupal.org/node/1780646
#drush dl inline_entity_form
#drush en inline_entity_form -y
#drush dl inline_entity_form-7.x-1.x-dev
#drush en inline_entity_form -y
#drush iq-apply-patch http://drupal.org/node/1780646
#       @see also http://drupal.org/project/entity_tree

#       Relations
drush dl relation relation_add
drush en relation relation_ui relation_add -y

#       CKEditor
#drush dl wysiwyg ckeditor
#drush en wysiwyg ckeditor -y
#       (Expermiental alternative)
#drush dl wysiwyg wysiwyg_ckeditor

#       Wysiwyg common extensions
#drush dl linkit
#drush en linkit -y
#       Images : what about responsive & retina image insertion inside wysiwyg ?
#       @todo use "picture" module with custom token (because it needs to be rendered through a special field formatter)
#drush dl insert
#drush en insert -y

#       User profiles
#drush dl profile2
#drush en profile2 -y
#       Note 2013/02/21 18:50:57 - when using Profile2, the "label" column always gets the value of bundle title
#       -> using this auto_entitylabel is required when using an entity_reference field to target the profile entites directly using autocomplete
#drush dl auto_entitylabel
#drush en auto_entitylabel -y


#       JQuery update
#       Note: jquery_update-7.x-2.3 released with JQuery-1.8 as of 2013-Feb-09
drush dl jquery_update
drush en jquery_update -y

#       Media
drush dl media-7.x-2.x-dev file_entity
drush en media file_entity -y

#       Pre-generate image styles (needs more testing)
drush dl ispreg
drush en ispreg -y

#       Image cropping helpers
#       @see http://drupal.org/node/1179172
#drush dl manualcrop
#drush en manualcrop -y
drush dl imagefield_focus
drush en imagefield_focus -y
drush dl smartcrop
drush en smartcrop -y
#drush dl imagecrop-7.x-1.x-dev
#drush en imagecrop -y

#       Multiple / Bulk upload
#       @todo 01:29 28/02/2013 - check URL for latest version
#cd sites/all/libraries
#wget https://github.com/downloads/moxiecode/plupload/plupload_1_5_4.zip --quiet --no-check-certificate
#unzip plupload_1_5_4.zip
#rm plupload_1_5_4.zip
#rm plupload/docs -r
#rm plupload/examples -r
#chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
#chmod $DEFAULT_UNIX_MOD . -R
#cd ../../../
#drush dl plupload
#drush en plupload -y

#       Note : these don't work with "media" selector widget, not the file field widget : it's one OR the other.
#       Still looking for an implementation within media module's selector widget which would include plupload.
#drush dl filefield_sources
#drush en filefield_sources -y
#drush dl filefield_sources_plupload
#drush en filefield_sources_plupload -y
#       Meanwhile :
#drush dl bulk_media_upload
#drush en bulk_media_upload -y

#       Alternative : JQuery File Upload
#       (looks good but requires more work)
#cd sites/all/libraries
#wget https://github.com/blueimp/jQuery-File-Upload/archive/master.zip --quiet --no-check-certificate
#unzip master.zip
#rm master.zip
#mv jQuery-File-Upload-master jquery-file-upload
#chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
#chmod $DEFAULT_UNIX_MOD . -R
#cd ../../../
#drush dl jquery_file_upload
#drush en jquery_file_upload -y

#       Colorbox : download, cleanup & enable
#       updated url 2013/06/17 10:20:00
cd sites/all/libraries
wget https://github.com/jackmoore/colorbox/archive/master.zip --quiet
unzip master.zip
rm master.zip
mkdir colorbox
mv colorbox-master/jquery.colorbox.js colorbox/jquery.colorbox.js
mv colorbox-master/jquery.colorbox-min.js colorbox/jquery.colorbox-min.js
mv colorbox-master/i18n colorbox/i18n
rm colorbox-master -r
chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
chmod $DEFAULT_UNIX_MOD . -R
cd ../../../
drush dl colorbox
drush en colorbox -y

#       Simplest Video Embeds (input filter transforming a YouTube / Vimeo link into an embed)
#drush dl googtube
#drush en googtube -y

#       Video Embeds Alternative
#drush dl emfield
#drush en emfield -y
#drush dl video_embed_field
#drush en video_embed_field -y

#       Embed Youtube / Dailymotion videos
#       directly from Media selection widget
drush dl media_youtube
drush en media_youtube -y
drush dl media_dailymotion
drush en media_dailymotion -y

#       Embed DailyMotion video from Media selection widget
#drush dl media_dailymotion
#drush en media_dailymotion -y

#       HTML 5 Video and Audio player : MediaElement.js (untested)
#       @see http://mediaelementjs.com/
cd sites/all/libraries
wget http://github.com/johndyer/mediaelement/zipball/master --quiet
mv master master.zip
unzip master.zip
#       @todo 2013/04/03 11:52:40 - syntax to match dirname without "-3ee7a7d" ?
mv johndyer-mediaelement-3ee7a7d/ mediaelement
rm master.zip
chown $DEFAULT_UNIX_OWNER:$DEFAULT_UNIX_GROUP . -R
chmod $DEFAULT_UNIX_MOD . -R
cd ../../../
drush dl mediaelement
drush en mediaelement -y


#       Video players / controllers (stored locally)
#drush dl videojs
#drush en videojs -y
#drush dl popcornjs
#drush en popcornjs -y

#       File storage
#drush dl storage_api
#drush en storage_api -y

#       Linked Data
#drush dl microdata
#drush en microdata -y
#       OR
drush dl schemaorg
drush en schemaorg -y

#       SEO
drush dl metatag
drush en metatag -y
drush dl pathauto redirect
drush en pathauto redirect -y

#       Note: "Global redirect" may apparently cause troubles for i18n (ref. missing)
#drush dl pathauto redirect globalredirect
#drush en pathauto redirect globalredirect -y

#drush dl opengraph_meta
#drush en opengraph_meta -y
#drush dl xmlsitemap
#drush en xmlsitemap -y
#drush dl subpathauto
#drush en subpathauto -y
#drush dl rich_snippets
#drush en rich_snippets -y
#drush dl seo_checklist checklistapi
#drush en seo_checklist checklistapi -y
#drush dl menu_attributes
#drush en menu_attributes -y

#       Other
#drush dl webform
#drush en webform -y

#       Nice to-do list worthy to look at before going live
#drush dl prod_check
#drush en prod_check -y


#-----------------------------------------
#       Email

drush dl mailsystem
drush en mailsystem -y

cd sites/all/libraries
#       Check link for latest version (current latest: 4.3.0 - 2013 January 8)
#       @see http://swiftmailer.org/
wget http://swiftmailer.org/download_file/Swift-5.0.1.tar.gz --quiet
tar -zxf Swift-5.0.1.tar.gz
mv Swift-5.0.1 swiftmailer
rm Swift-5.0.1.tar.gz
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

drush dl phone
drush en phone -y
drush dl email
drush en email -y
drush dl invisimail
drush en invisimail -y

#       Note 2013/02/21 19:05:21 - BUG encountered when checking option "allow users to choose if it's an external link"
#       Symptoms : no inputs show up in form, only the checkbox
drush dl link
drush en link -y


#-----------------------------------------
#       UX / Redaction helpers

#       Input filters
#       @todo : custom module for custom token
drush dl token_filter
drush en token_filter -y

#       Prevent Simultaneous Edits
#drush dl content_lock
#drush en content_lock -y

#       Prevent double submit click (Note: when using Bootstrap, cf. Buttons > Loading State)
#       @see http://twitter.github.com/bootstrap/javascript.html#buttons
#drush dl hide_submit
#drush en hide_submit -y

#       UI helpers
drush dl content_menu
drush en content_menu -y
drush dl options_element
drush en options_element -y
#drush dl select_or_other
#drush en select_or_other -y
drush dl term_reference_tree
drush en term_reference_tree -y
#drush dl module_filter
#drush en module_filter -y
drush dl fpa
drush en fpa -y

#       Node publishing options visibility
drush dl override_node_options
drush en override_node_options -y

#       Adds a publish and unpublish button for a simpler editorial workflow
#       @see http://www.lullabot.com/articles/module-monday-publish-button
#drush dl publish_button
#drush en publish_button -y

#       Alternative
drush dl publishcontent
drush en publishcontent -y

#       Adding custom node publishing options
#drush dl custom_pub
#drush en custom_pub -y

#       Chosen (better select fields UX)
cd sites/all/libraries
wget https://github.com/harvesthq/chosen/archive/master.zip --quiet --no-check-certificate
unzip master.zip
mv chosen-master chosen
rm master.zip
cd ../../../
drush dl chosen
drush en chosen -y
drush vset --yes chosen_minimum "0"
drush vset --yes chosen_jquery_selector "select:not('.widget-type-select')"
#       NB : better settings for chosen
#       1) default behaviour : search contains, @see http://drupal.org/node/1539444
#       2) don't show search box on single selects unless they have at least 8+ items
#       -> hack "chosen.js" in module folder, and set the following options :
#var options = {};
#options.search_contains = 1;
#options.disable_search_threshold = 7;
#$(this).chosen( options );

#       Breadcrumbs
drush dl crumbs
drush en crumbs -y
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


#-----------------------------------------
#       Multilingual (in progress)

#       Install another language
drush en locale -y
drush dl l10n_update
drush en l10n_update -y

#       Handle content translation
drush en translation -y
drush dl i18n
drush en i18n -y


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

#       Untested
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
#drush dl nodeaccess_nodereference
#drush en nodeaccess_nodereference -y
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
drush dl eva
drush en eva -y
#drush dl nodequeue
#drush en nodequeue -y
#drush dl draggableviews
#drush en draggableviews -y
#drush dl skyfield
#drush en skyfield -y
drush dl field_group
drush en field_group -y
#drush dl field_collection
#drush en field_collection -y
drush dl content_type_groups
drush en content_type_groups -y
#drush dl restrict_node_page_view
#drush en restrict_node_page_view -y

#       Layout "presets" for use inside body / wysiwyg
#drush dl article_templater
#drush en article_templater -y

#       Display term and its parents
#drush dl hierarchical_term_formatter
#drush en hierarchical_term_formatter -y

#       Import / Export
#drush dl feeds
#drush en feeds -y
#drush dl phpexcel
#drush en phpexcel -y

#       Migrate
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

#       Sign-in with external accounts (use OAUTH providers)
#drush dl oauth
#drush en oauth_common_providerui oauth_common -y

#       OAuth Connector makes it possible to connect and sign in a Drupal user with accounts on most third party sites
#       The Drupal 7 version is in beta and comes with Oauth2 support and presets for :
#           Twitter
#           LinkedIn
#           Facebook
#           Google (Google+ and more)
#           Flickr
#drush dl http_client oauthconnector
#drush en http_client oauthconnector -y

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

#       Social Agregation (twitter + rss feeds)
#drush dl activitystream
#drush en activitystream -y


#-----------------------------------------
#       Geolocalization

#       Minimalistic solution (most basic)
#       this module only uses a plain text field for entering an address
#drush dl simple_gmap
#drush en simple_gmap -y

#       Addressfield (implements xNAL standard)
drush dl addressfield
drush en addressfield -y

#       Geofield (stores complex coordinates)
#       Note : also contains a simple display formatter using GMap (module "geofield_map")
drush dl geofield
drush en geofield geofield_map -y

#       Geocoding (make "geofield" points from "addressfield", "geolocation", or "location")
drush dl geocoder
drush en geocoder -y

#       Leaflet (light map display)
#drush dl leaflet
#drush en leaflet -y

#       OpenLayers (heavier, more sophisticated map display)
#drush dl openlayers
#drush en openlayers -y

#       Location field (7.x not ready yet, medium sophistication, wait for branch 7.x-5.x - will be using proper entities)
#drush dl location
#drush en location -y
#drush dl locationmap
#drush en locationmap -y

#       Others (untested)
#drush dl geolocation
#drush en geolocation -y

#       Geo-search
#drush dl search_api_location
#drush en search_api_location -y
#drush dl openlayers_solr
#drush en openlayers_solr -y


#-----------------------------------------
#       Dev utils

#       Drush extensions (run once)
#drush dl drush_iq
drush dl drush_cleanup -n
drush cleanup

#       Modules introspection / overview
drush dl moduleinfo
drush en moduleinfo -y

#       Monitoring
#drush dl performance
#drush en performance -y

#       Configuration Management à la Drupal 8
#drush dl configuration
#drush dl configuration-7.x-2.x-dev
#drush en configuration -y
#drush dl diff
#drush en diff -y

#       Popular alternative
drush dl features strongarm
drush en features strongarm -y

#       Emails (sandbox-like behaviour : sends all emails from Drupal to a single address)
#drush dl reroute_email
#drush en reroute_email -y

#       Batch
#drush dl better_batch
#drush en better_batch -y

#       Cron enhancement (untested)
drush dl ultimate_cron
drush en ultimate_cron -y
#       alternative :
#drush dl elysia_cron
#drush en elysia_cron -y

#       Maintenance
#drush dl watchdog_digest
#drush en watchdog_digest -y

#       DB-related utils
#drush dl schema
#drush en schema -y

#       Session-related utils
drush dl session_cache
drush en session_cache -y


#-----------------------------------------
#       Theming & Front-end

#       Conditional stylesheets for IE
drush dl conditional_styles
drush en conditional_styles -y

#       Front-end Utils
#drush dl magic
#drush en magic -y

#       Compass Theme (untested)
#drush dl aurora
#drusn en aurora -y

#       Compass theme alternative
#drush dl sasson
#drusn en sasson -y

#       Base theme
#drush dl mothership
#drush en mothership -y

#       Image base64 CSS embedding (performance optimization)
#drush dl css_emimage
#drush en css_emimage -y

#       HTML 5 helpers
drush dl elements html5_tools
drush en elements html5_tools -y

#       Responsive helpers (@todo : test & compare these)
#drush dl breakpoints
#drush en breakpoints -y
#drush dl ais
#drush en ais -y
#drush dl picture
#drush en picture -y

#       Responsive tables (untested)
#drush dl footable
#drush en footable -y

#       Mobile server-side detection (untested)
#drush dl mobile_tools
#drush en mobile_tools -y
#drush dl wurfl
#drush en wurfl -y

#       Carousel - flexslider - NB : when using Bootstrap or Zurb Foundation, there's already a carousel / orbit thingy, so no need for those
#drush dl flexslider
#drush en flexslider -y
#drush en flexslider_views flexslider_fields -y

#       with Views Slideshow :
#drush en flexslider_views_slideshow -y

#       Carousel - alternatives
#drush dl views_slideshow
#drush en views_slideshow -y
#drush dl field_slideshow
#drush en field_slideshow -y

#       Theming JQuery UI
#       NB : fails when using jquery_update as of 2013/01/31 15:39:36
#drush dl jqueryui_theme
#drush en jqueryui_theme -y

#       CSS Preprocessor : Less
#       Note after using this for a while: not recommended... build your CSS locally instead.
#cd sites/all/libraries
#wget http://leafo.net/lessphp/src/lessphp-0.3.8.tar.gz --quiet
#tar -xzf lessphp-0.3.8.tar.gz
#rm lessphp-0.3.8.tar.gz
#cd ../../../
#drush dl less-7.x-3.0-beta1
#       CSS Preprocessor : Sass / Scss
#drush dl sass
#drush en sass -y
#drush en less -y

#       Layout management - Display Suite
#drush dl ds
#drush en ds ds_ui ds_forms -y
#drush en ds ds_devel ds_extras ds_forms ds_format ds_ui ds_search -y

#       Layout management - Display Suite alternative with combination of the following smaller modules (untested as of 2013/05/29 11:38:52)
#       Note : would work well with "context" module, and a base theme with flexible regions like "omega"
drush dl entity_view_mode
drush en entity_view_mode -y
#drush dl fieldblock
#drush en fieldblock -y

#       Testing panels integration with entity_view_mode 2013/07/19 17:59:25
drush dl panelizer
drush en panelizer -y

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
drush dl styleguide
drush en styleguide -y
#drush dl design
#drush en design_test -y


#-----------------------------------------
#       Performance

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

#       Faster 404
#       Note : see core's "settings.php" about that. Errors when installing. Not maintained anymore ?
#       @see http://drupal.org/node/1500092
#drush dl fast_404
#drush en fast_404 -y

#       Drupal core JS optimization
drush dl speedy
drush en speedy -y

#       Drupal core JS / CSS aggregation optimization
#drush dl agrcache
#drush en agrcache -y
#drush dl core_library
#drush en core_library -y
#drush dl advagg
#drush en advagg -y

#       Faster callbacks
#drush dl js
#drush en js -y
#       (Legacy module)
#drush dl js_callback
#drush en js_callback -y

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
drush bb

