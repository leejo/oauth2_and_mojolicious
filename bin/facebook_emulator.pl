#!perl

use Mojolicious::Lite;
use Mojo::JSON;

plugin 'OAuth2::Server' => {
  #jwt_secret => "blah de blah",
  clients => {
    some_app_key => {
      client_secret => 'boo',
      scopes => {
        "public_profile" => 1,
      },
    },
  },
};

any '/me' => sub {
  my ( $c ) = @_;

  return $c->render( status => 401, json => {} )
   if ! $c->oauth;

  $c->render( json => {
    "first_name" => "Lee",
    "link" => "https://www.facebook.com/app_scoped_user_id/1953463837085314/",
    "updated_time" => "2015-02-19T19:13:34+0000",
    "verified" => Mojo::JSON::true,
    "locale" => "en_GB",
    "gender" => "male",
    "name" => "Lee Johnson",
    "id" => "1953463837085314",
    "timezone" => 1,
    "last_name" => "Johnson"
  });
};

any '/user' => sub {
  my ( $c ) = @_;

  return $c->render( status => 401, json => {} )
    if ! $c->oauth( 'public_profile' );

  $c->render( json => {
    "error" => {
      "message" => "(#803) Cannot query users by their username (user)",
      "type" => "OAuthException",
      "code" => 803,
    }
  });
};

get '/' => sub {
  my ( $c ) = @_;
  $c->render( text => "Welcome to Facebook" );
};

app->start;

# vim: ts=2:sw=2:et
