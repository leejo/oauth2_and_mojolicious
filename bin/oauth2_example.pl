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
