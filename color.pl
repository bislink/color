#!/usr/bin/perl 
use Mojolicious::Lite; 
helper 'open_file' => sub {
	my $c = shift;
	my $cd = ''; $cd = app->home->to_abs();
	my @c;
	if ( open( my $fh, '<', "$cd/colors_rgb.txt") ) {
		while (my $line = <$fh> ) { 
			if ( $line ) { push(@c, "$line"); } 
		}
		close $fh;
	} else {
		push(@c, qq{ Error 12 Unable to open file } );
	}
	return @c;
};
# end helper open file
# helper li
helper 'li' => sub {
	my $c = shift;
	#
	my ( $letter, @letter) = @_;
	my %in; my %out; 
	#
	%in = (
		letter => 'a',
		@_,
	);
	for my $line (@letter) { 
		next if $line =~ /^colour/i;
		my ($color, $col, $hex, $r, $g, $b, $code) = split(/\|/, $line);
		$out{out} .= qq~\t<li style="background-color:$hex;">$col, $hex, rgb\($r, $g, $b\)</li>\n~;
	}
	#
	return $out{out};
};
# end li

# helper by letter
helper 'alpha' => sub {
	my $c = shift;
	my %in; my %out; my @all; my @letter; 
	%in = (
		letter => 'a',
		@_,
	);
	if ($in{letter} ne '') {
		@all = $c->open_file();
		for (@all ) { 
			if ( $_ =~ /^$in{letter}/i ) { 
				push( @letter, "$_"); 
			} else {
				##push( @letter, " 53 No Match ");
				$out{letter} = qq{53 No Match };
			}
		}
	}
	#
	$out{letter} = $c->li("$in{letter}", @letter );
	#
	return $out{letter};
};

# home page
get '/' => sub {
	my $c = shift;
	my %in; my %out; my $out;
	$in{cd} = app->home->to_abs();
	$out = qq{<ol>\n};
	my @c;
	@c = $c->open_file();
	my $serial = '0';
	my $total = scalar @c;
	my @sorted = sort @c;
	for my $line (@sorted)
	{
		chomp $line;
		$serial++;
		next if $line =~ /^colour/i;
		my ($color, $col, $hex, $r, $g, $b, $code) = split(/\|/, $line);
		#$out .= qq~\t<li style="background-color:$hex;">$col, $hex, rgb\($r, $g, $b\)</li>\n~;
		#
		for ('a'..'z') {
			if ( $line =~ /^$_/i) {
				push(@{$out{"$_"}}, "$line");
			}
		}
		#
	}
	#
	#for (@{$out{"a"}}) { $out .= qq{<li>$_</li>}; }
	$out .= $c->li( 'a', @{$out{"a"}} );
	#$out .= $c->li( letter => 'a', @{$out{"a"}} );
	$out .= qq{</ol>\n};
	#
	$c->stash( total => qq{$total} );
	$c->stash( out => qq{$out} );
	#
	$c->render('color');
};
# end get /

# begin get /letter
get '/letter' => sub {
	my $c = shift;
	my $let = $c->param('let');
	chomp $let;
	if ( $let ) {
		$c->stash( out => $c->alpha( letter => "$let") );
	} else {
		#$c->stash( out => "$let No Letter");
	}
	#
	$c->stash( let => "Letter $let");
	$c->render('letter');
};
# end get /letter
app->start;
1;
__DATA__
@@ color.html.ep
% layout 'd';
% title 'Colors';
Total <%== stash 'total' %> <br/> 
<%== stash 'out' %>

@@ letter.html.ep
% layout 'd';
% title 'Colors ';
<section><h2><%== stash 'let' %></h2>
	<%== stash 'out' %>
</section>

@@ layouts/d.html.ep
<!doctype html>
<html lang="en">
<head>
<title><%= title %></title>
<meta charset="utf-8">
<meta name="description" content="Colors - A1Z Hosting - www.a1z.us">
<meta name="keywords" content="hex and rgb colors, A1z, hosting, backup, blog, business, personal, charity">
<link rel="manifest" href="/c/colors/manifest.json">
<meta name="theme-color" content="#B12A34">
<link rel="apple-touch-icon" href="/favicon.ico">
<meta name="Robots" content="INDEX,FOLLOW">
<meta name="Rating" content="General">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<style>
	body { margin:0 2rem; font-size:18px; font-family: Verdana, Helvetica, sans-serif, serif;}
	h1 { margin:0; padding:0; }
	main { clear: both; }
	ol { margin:0; padding:0; }
	li { width:auto; min-height:2rem; margin:1rem 1rem; padding:1rem 1rem; font-size: 1.22rem;}
	nav { margin:0; padding:0; clear:both; }
	nav ul { margin:0; padding:0; clear:both; list-style-type: none;}
	nav ul li { margin:0.5rem 0.5rem; padding:0.5rem; float :left; clear: right; }
	nav ul li a { text-decoration: none; }
</style>
</head>
<body>

	<h1>Colors</h1>

	<nav>
		<ul>
			<li><a href="/index.html" title="Home">Home</a></li>
			<li><a href="<%= url_for '/' %>" title="Colors Home">Colors Home</a></li>
			%# no j, q, 
			% for ( 'a' .. 'i', 'k' .. 'p', 'r' .. 't', 'v', 'w', 'y') { 
				<li> <a href="<%= url_for 'letter' %>?let=<%= $_ %>" title="Get colors alphabetically: <%= $_ %>"><%= $_ %></a> </li> 
			% }
		</ul>
	</nav>

	<main>
		<%== content %> 
	</main>

	<footer>
		&copy; A1Z.us
	</footer>

	<script>
	// register service worker
	if ('serviceWorker' in navigator) {
			window.addEventListener('load', () => {
			navigator.serviceWorker.register('/c/colors/sw.js')
			.then((reg) => {
			console.log('Colors on https://msn.envy.a1z.us:12004 is ready. ', reg);
			});
		});
	}
	</script>

</body>
</html>

