### Tvtch on Rails

This repository implements a really basic twitch client on Ruby on Rails by using the [Twitch developers API](https://dev.twitch.tv/docs/api).
The app provides basic Oauth Authentication, channel search and embeded stream and chat.
For the moment this project does not contain code for UI or Styling.

### Dependencies
- ruby 2.6.6
- postgres 13.1
- bundler 1.17.2

### Installation

start by installing the dependencies and bundling the app.

```
  bundle
  bundle exec rails webpacker:install
  bundle exec rake db:create db:migrate
```

To configure the twitch Oauth2.0 crendentials on your local you will first need to create a new application and generate it secret from the [Twitch Dev console](https://dev.twitch.tv/console/apps)

After having your credential you can just populate them for your test and dev enviroment using rails credentials

```EDITOR=vim bin/rails credentials:edit --environment development```

```
  twitch:
     client_id: <your app client id>
     client_secret: <your app client secret>
     redirect_uri: <your app redirect uri>
```
