### OAuth2 and Mojolicious

Lee Johnson

Swiss Perl Workshop / YAPC::EU 2015

---
![me](/img/card.jpg)

[leejo.github.io/code](https://leejo.github.io/code)

---
## [OAuth 2.0](https://tools.ietf.org/html/rfc6749)

---
Not really going to talk about OAuth 2.0 fundamentals here

Such as [how](https://tools.ietf.org/html/rfc6749#section-4.1) it works, [why](http://oauth2.thephpleague.com/authorization-server/which-grant/) you would use it, [or](https://tools.ietf.org/html/rfc6819) [its](https://vimeo.com/52882780) [potential](http://hueniverse.com/2012/07/26/oauth-2-0-and-the-road-to-hell/) [problems](http://hueniverse.com/2010/09/29/oauth-bearer-tokens-are-a-terrible-idea/) [.](https://news.ycombinator.com/item?id=4294959)

However, a recap...

---
"Authorization Code Grant"

                     +----------+          Client Identifier      +----------+
    +----------+     |         -+----(A)-- & Redirection URI ---->|          |
    | Resource |     |  User-   |                                 |   Auth   |
    |   Owner  <-(B)--  Agent  -+----(B)-- User authenticates --->|  Server  |
    |          |     |          |                                 |          |
    +----------+     |         -+----(C)-- Authorization Code ---<|          |
                     +-|----|---+                                 +----------+
                       |    |                                        ^    v
                      (A)  (C)                                       |    |
                       |    |                                        |    |
                       ^    v                                        |    |
                     +---------+                                     |    |
                     |         |>---(D)-- Authorization Code --------'    |
                     |  Client |          & Redirection URI               |
                     |         |                                          |
                     |         |<---(E)----- Access Token ----------------'
                     +---------+       (w/ Optional Refresh Token)

---
[Simple!](https://www.youtube.com/watch?v=xeGxGnSkSdQ)

---
## An example!

---
## Client Implementation

[Mojolicious::Plugin::OAuth2](https://metacpan.org/release/Mojolicious-Plugin-OAuth2)

---
### Client Implementation

```perl
#!perl

use Mojolicious::Lite;

plugin 'OAuth2', {
  fix_get_token => 1,
  facebook => {
     key    => $ENV{FACEBOOK_APP_KEY},
     secret => $ENV{FACEBOOK_APP_SECRET},
  },
};

get '/' => sub { shift->render( 'index' ) };

get '/auth' => sub {
  my $self = shift;
  if ( my $error = $self->param( 'error' ) ) {
    return $self->render(
      text => "Call to facebook returned: $error"
    );
  } else {
    $self->delay(
      sub {
        my $delay = shift;
        $self->oauth2->get_token( facebook => $delay->begin )
      },
      sub {
        my( $delay,$error,$data ) = @_;
        return $self->render( error => $error ) if ! $data->{access_token};
        return $self->render( json => $data );
      },
    );
  }
};

app->start;

# vim: ts=2:sw=2:et

__DATA__
@@ layouts/default.html.ep
<!doctype html><html>
  <head><title>TrendyNewService</title></head>
  <body><h3>Welcome to TrendyNewService</h3><%== content %></body>
</html>

@@ index.html.ep
% layout 'default';
<a href="/auth">Connect to Facebook</a>
```
---
### Client Implementation
```
FACEBOOK_APP_KEY=foo \
FACEBOOK_APP_SECRET=bar \
perl ~/bin/morbo -l "https://*:3001" bin/oauth2_example.pl
```

[Let's try it](https://localhost:3001)

---
### Do something with the access token:

```
curl -XGET 'https://graph.facebook.com/me?access_token=$token' | json_pp
```

The token should be encrypted when storing, and never revealed outside of your app (that __includes__ to the associated user).

---
It's that simple. If you're connecting to a provider that the plugin doesn't know about<sup>*</sup> then provide a little more config:

```perl
plugin "OAuth2" => {
  custom_provider => {
    key           => "APP_ID",
    secret        => "SECRET_KEY",
    authorize_url => "https://provider.example.com/auth",
    token_url     => "https://provider.example.com/token",
  },
};
```

<sup>*</sup> dailymotion / eventbrite / facebook / github / google

---
## Server Implementation

[Mojolicious::Plugin::OAuth2::Server](https://metacpan.org/release/Mojolicious-Plugin-OAuth2-Server)

---
### Server Implementation

```perl
#!perl

use Mojolicious::Lite;
use Mojo::JSON;

plugin 'OAuth2::Server' => {
  clients => {
    some_app_key => {
      client_secret => 'boo',
      scopes => {
        "public_profile" => 1,
      },
    },
  },
};

app->start;
```

---
### It can't be that simple [can it?](https://localhost:3002)

---
### Of course, you need some routes:

```perl
any '/me' => sub {
  my ( $c ) = @_;

  return $c->render( status => 401, json => {} )
   if ! $c->oauth;

  return $c->render( json => ... );
};

any '/user' => sub {
  my ( $c ) = @_;

  return $c->render( status => 401, json => {} )
    if ! $c->oauth( 'public_profile' );

  return $c->render( json => ... );
};

```

---
### Calling /me with access token:

```
curl -k -v -XGET -H'Authorization: Bearer $token' 'https://127.0.0.1:3000/me' | json_pp
```

---
### But of course it's not *that* simple

* No persistence
* No multi-proc
* But great for prototyping / emulation

---
### But of course it's not *that* simple

* No persistence
* No multi-proc
* But great for prototyping / emulation
* JWTs to get persistence / multi-proc

---
### In reality you must add some methods

* login_resource_owner
* confirm_by_resource_owner
* verify_client
* store_auth_code
* verify_auth_code*
* store_access_token
* verify_access_token*

<br />
About 200 lines of code total (with error handling, logging, etc). A few examples are included in the dist's [examples/](https://metacpan.org/source/LEEJO/Mojolicious-Plugin-OAuth2-Server-0.22/examples) dir

---
### There are a few more config options

* jwt_secret - to return JWTs for tokens
* authorize_route - defaults to GET /oauth/authorize
* access_token_route - defaults to POST /oauth/access_token
* auth_code_ttl - defaults to 600s
* access_token_ttl - defaults to 3600s

---
### There are other modules on CPAN:

* [OAuth::Lite2](https://metacpan.org/release/OAuth-Lite2) - Client / Server
* [Net::OAuth2](https://metacpan.org/release/Net-OAuth2) - Client / Server
* [Net::OAuth2::Scheme](https://metacpan.org/release/CatalystX-OAuth2) - Server
* [CatalystX::OAuth2](https://metacpan.org/release/CatalystX-OAuth2) - Client
* [CatalystX::OAuth2::Provider](https://metacpan.org/release/CatalystX-OAuth2-Provider) - Server
* [LWP::Authen::OAuth2](https://metacpan.org/pod/LWP::Authen::OAuth2) - Client


---
## Questions?
