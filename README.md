APN on Rails (Apple Push Notifications on Rails)
================================================

[![Build Status](https://secure.travis-ci.org/jfjade18/apn_on_rails.png)](http://travis-ci.org/jfjade18/apn_on_rails)

APN on Rails is a Ruby on Rails gem that allows you to easily add Apple Push Notification (iPhone) support to your Rails 3.2 and above application.

It supports:

-   Multiple iPhone apps managed from the same Rails application as well as a legacy default "app" with certs stored in config
-   Individual notifications and group notifications
-   Alerts, badges, sounds, and custom properties in notifications
-   Pull notifications

Feature Descriptions
--------------------

Multiple iPhone Apps: In previous versions of this gem a single Rails application was set up to manage push notifications for a single iPhone app. In many cases it is useful to have a single Rails app manage push notifications for multiple iPhone apps. With the addition of an APN::App model, this is now possible. The certificates are now stored on instances of APN::App and all devices are intended to be associated with a particular app. For compatibility with existing implementations it is still possible to create devices that are not associated with an APN::App and to send individual notifications to them using the certs stored in the config directory.

Individual and Group Notifications: Previous versions of this gem treated each notification individually and did not provide a built-in way to send a broadcast notification to a group of devices. Group notifications are now built into the gem. A group notification is associated with a group of devices and shares its contents across the entire group of devices. (Group notifications are only available for groups of devices associated with an APN::App)

Notification Content Areas: Notifications may contain alerts, badges, sounds, and custom properties.

Pull Notifications: This version of the gem supports an alternative notification method that relies on pulls from client devices and does not interact with the Apple Push Notification servers. This feature may be used entirely independently of the push notification features. Pull notifications may be created for an app. A client app can query for the most recent pull notification available since a given date to retrieve any notifications waiting for it.

Version 0.4.1 Notes
-------------------

-   Backwards compatibility. 0.4.0 required a manual upgrade to associate existing and new devices with an APN::App model. This version allows continued use of devices that are associated with a default "app" that stores its certificates in the config directory. This ought to allow upgrade to this version without code changes.
-   Batched finds. Finds on the APN::Device model that can return large numbers of records have been batched to limit memory impact.
-   Custom properties migration. At a pre-0.4.0 version the custom\_properties attribute was added to the migration template that created the notifications table. This introduced a potential problem for gem users who had previously run this migration. The custom\_properties alteration to the apn\_notifications table has been moved to its own migration and should work regardless of whether your apn\_notifications table already has a custom_properties attribute.
-   last\_registered\_at changed to work intuitively. The last\_registered\_at attribute of devices was being updated only on creation potentially causing a bug in which a device that opts out of APNs and then opts back in before apn\_on\_rails received feedback about it might miss a period of APNs that it should receive.

Acknowledgements:
-----------------

From Mark Bates:

This gem is a re-write of a plugin that was written by Fabien Penso and Sam Soffes. Their plugin was a great start, but it just didn't quite reach the level I hoped it would. I've re-written, as a gem, added a ton of tests, and I would like to think that I made it a little nicer and easier to use.

From Rebecca Nesson (PRX.org):

This gem extends the original version that Mark Bates adapted. His gem did the hard work of setting up and handling all communication with the Apple push notification servers.

From Jed Seculles:

This gem extends the version that PRX adapted. I would like to acknowledge the changes and fixes made by Rami Grossman (ramigg) and natescherer. I upgraded the gem to run on Rails 3.2 and above. Please feel free to use this gem and fix the bugs if I miss any of them.

Converting Your Certificate:
----------------------------

Once you have the certificate from Apple for your application, export your key and the apple certificate as p12 files. Here is a quick walkthrough on how to do this:

1. Click the disclosure arrow next to your certificate in Keychain Access and select the certificate and the key.
2. Right click and choose `Export 2 items…`.
3. Choose the p12 format from the drop down and name it `cert.p12`.

Now covert the p12 file to a pem file:

<pre><code> $ openssl pkcs12 -in cert.p12 -out apple_push_notification_production.pem -nodes -clcerts
</code></pre>

If you are using a development certificate, then change the name to
apple_push_notification_development.pem instead.

Store the contents of the certificate files on the app model for the app
you want to send notifications to.

Installing:
-----------

### Rails Gem Management:

If you like to use the built in Rails gem management, on your Gemfile:

<pre><code> gem 'apn_on_rails', :git => 'git@github.com:jfjade18/apn_on_rails.git'
</code></pre>

Setup and Configuration:
------------------------

Once you have the gem installed via your favorite gem installation, you
need to require it so you can
start to use it:

Add the following require on your initializers:

<pre><code> # config/initializers/apn_on_rails.rb
 require 'apn_on_rails'
 # you can add the configatron changes here, such as passphrase and cert
</code></pre>

You also need to add the following to your Rakefile so you can use the Rake tasks that ship with APN on Rails:

<pre><code>begin
  require 'apn_on_rails_tasks'
rescue MissingSourceFile => e
  puts e.message
end
</code></pre>

Now, to create the tables you need for APN on Rails, run the following task:

<pre><code> $ rails generate apn_migrations
</code></pre>

APN on Rails uses the Configatron gem, [http://github.com/markbates/configatron/tree/master](http://github.com/markbates/configatron/tree/master), to configure itself. (With the change to multi-app support, the certifications are stored in the database rather than in the config directory, however, it is still possible to use the default "app" and the certificates stored in the config directory. For this setup, the following configurations apply.) APN on Rails has the following default configurations that you change as you see fit:

<pre><code># development (delivery):
 configatron.apn.passphrase # => ''
 configatron.apn.port # => 2195
 configatron.apn.host # => 'gateway.sandbox.push.apple.com'
 configatron.apn.cert #=> File.join(::Rails.root, 'config', 'apple_push_notification_development.pem')

# production (delivery):
 configatron.apn.host # => 'gateway.push.apple.com'
 configatron.apn.cert #=> File.join(::Rails.root, 'config', 'apple_push_notification_production.pem')

# development (feedback):
 configatron.apn.feedback.passphrase # => ''
 configatron.apn.feedback.port # => 2196
 configatron.apn.feedback.host # => 'feedback.sandbox.push.apple.com'
 configatron.apn.feedback.cert #=> File.join(::Rails.root, 'config', 'apple_push_notification_development.pem')

# production (feedback):
 configatron.apn.feedback.host # => 'feedback.push.apple.com'
 configatron.apn.feedback.cert #=> File.join(::Rails.root, 'config', 'apple_push_notification_production.pem')
</code></pre>

That's it, now you're ready to start creating notifications.

### Upgrade Notes:

If you are upgrading to a new version of APN on Rails you should always run:

<pre><code> $ rails generate apn_migrations
</code></pre>

That way you ensure you have the latest version of the database tables needed. (There is an unaddressed problem in which migration 002 was modified in the repo to add the column custom_properties. If you installed the gem prior to that change and try to upgrade following this path you will have to add the custom_properties column to the apn_notifications table by hand.)

Example (assuming you have created an app and stored your keys on it):
----------------------------------------------------------------------

<pre><code> $ rails console
 >> app = APN::App.create(:name => "My App", :apn_dev_cert => "PASTE YOUR DEV CERT HERE", :apn_prod_cert => "PASTE YOUR PROD CERT HERE")
 >> device = APN::Device.create(:token => "XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX", :app_id => app.id)
 >> notification = APN::Notification.new
 >> notification.device = device
 >> notification.badge = 5
 >> notification.sound = true
 >> notification.alert = "foobar"
 >> notification.custom_properties = {:link => "http://www.prx.org"}
 >> notification.save
</code></pre>

You can use the following Rake task to deliver your individual
notifications:

<pre><code> $ rake apn:notifications:deliver
</code></pre>

And the following task to deliver your group notifications:

<pre><code> $ rake apn:group_notifications:deliver
</code></pre>

The Rake task will find any unsent notifications in the database. If
there aren't any notifications
it will simply do nothing. If there are notifications waiting to be
delivered it will open a single connection
to Apple and push all the notifications through that one connection.
Apple does not like people opening/closing
connections constantly, so it's pretty important that you are careful
about batching up your notifications so
Apple doesn't shut you down.

Released under the MIT license.
