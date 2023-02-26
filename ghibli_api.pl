#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
use Mojo::JSON qw(decode_json encode_json true false);
use Mojo::File qw(curfile); # Get path of current file

my $path = curfile;
my $file_data = $path->dirname."/data/data.json";
my $json_data = read_data($file_data);

## Commun errors
my $error501 = "Render JSON Failed";

#################### CORS ######################
app->hook(after_dispatch => sub {
    my $c = shift;
    my $origin = $c->req->headers->origin;
   # say "HOOK ORIGIN: $origin";

    $c->res->headers->header('Access-Control-Allow-Origin' => $origin);
});


options '*' => sub {
    my $c = shift;
    my $origin = $c->req->headers->origin;
    say "OPTION ORIGIN: $origin";


    $c->res->headers->header('Access-Control-Allow-Origin' => $origin);
    $c->res->headers->header('Access-Control-Allow-Credentials' => 'true');
    $c->res->headers->header('Access-Control-Allow-Methods' => 'GET, OPTIONS, POST, DELETE, PUT');
    $c->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type');
    #$c->res->headers->header('Access-Control-Max-Age' => '1728000');

    $c->respond_to(any => { data => '', status => 200 });

};


get '/' => sub ($c) {
  $c->stash(info => $file_data);
  $c->render(template => 'index');
};

get '/json_info' => sub ($c) {
	$c->render(json => $json_data);
};

# Principal routes to return JSON data with requests
get '/films' => sub ($c) {
	if ($json_data) {
      eval {
	   $c->render(json => $json_data->{films});
	  };
	  if ($@){
	     die {
		 	status => $error501,
			data => $@,
			line => "By line ".__LINE__
		 };
	  }
	}
};

get '/people' => sub ($c) {
  $c->render(json => $json_data->{people});
};

get '/locations' => sub ($c) {
  $c->render(json => $json_data->{locations});
};

get '/species' => sub ($c) {
  $c->render(json => $json_data->{species});
};

get '/vehicles' => sub ($c) {
  $c->render(json => $json_data->{vehicles});
};

# --------------- Subroutines --------------------- #
sub read_data {
  my $file = shift;
  my $filecontent = ();
  my $json_info = undef;

  if (-e $file) { # open file if exist
    open my $fh, '<', $file or die {success => "false", status => "Cannot open file $file"};
    $filecontent = do {local $/; <$fh>}; # Read all the file with one line of code
    close $fh;
	$json_info = decode_json($filecontent);
  }
  warn "We read the file every time\n";
  return $json_info;
}

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<h1>Welcome to the Mojolicious real-time web framework!</h1>
<h2><%=$info%></h2>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
