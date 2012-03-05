#!/usr/bin/env perl
use strict;
use warnings;
use JSON;
use MP3::Tag;
use File::Path "make_path";
use LWP::UserAgent;
use Cwd;

# figure out where to stuff the songs
my $song_path = shift || getcwd . '/wearehunted_songs/';
make_path($song_path) unless (-d $song_path);

# get the song ids from our flat file
my $list_filename = getcwd . "/songids.txt";
open (my $list_fh, '+<', $list_filename) or die "Can't open $list_filename: $!";
my @existing_songs = <$list_fh>;

# suck in the json with a believable looking UA string
my $ua = LWP::UserAgent->new(
    agent   => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.75 Safari/535.',
    timeout => 20
);
my $json = _get_json($ua);

# start eating songs
my $count = 0;
foreach my $song (@{decode_json($json)}) {
	next if grep /$song->{id}/, @existing_songs;

	# pipes and backslashes in filenames are bad
	(my $unix_title = $song->{label}) =~ s/(\s|\/)/_/g;
	(my $unix_artist = $song->{artist}->{label}) =~ s/(\s|\/)/_/g;
	
	my $url = _get_song_url($song->{id}, $ua);
	unless ($url){
		print "Couldn't download $song->{label} by $song->{artist}->{label}\n" if (-t);
		next;
	}
	# assuming mp3 filetype
	print "Getting $song->{label}\n" if (-t);
	my $res = $ua->mirror($url, "$song_path/$unix_artist-$unix_title.mp3");
	die "Couldn't mirror $url: $res->error_as_HTML" if $res->is_error; 

	my $mp3 = MP3::Tag->new("$song_path/$unix_artist-$unix_title.mp3");
	# itunes only shows comments if they're english
	$mp3->config('default_language' => 'ENG');
	$mp3->update_tags( {
		"title"    => $song->{label},
		"artist"   => $song->{artist}->{label},
		"comment" => "From WeAreHunted. Pulled on " . scalar(localtime(time)) . " from $url",
	});
	print $list_fh "$song->{id}\n";
	$count++;
}

print "downloaded $count songs" if (-t);
close $list_fh;

sub _get_json {
	my $ua = shift; 
	my $response = $ua->get('http://wearehunted.com/emerging/',
			 'X-Hashsignal'     => 'Hashsignal',
			 'X-Requested-With' => 'XMLHttpRequest'
	);
	die "WeAreHunted returned an error: $response->error_as_HTML" if $response->is_error;
	return ($response->decoded_content =~ m/HUNTED\.chart\.entities = (\[\{.*);/)[0] or die "Couldn't parse out json: $!";
}

sub _get_song_url {
	my $eid = shift or return;
	my $ua = shift;
	my $response = $ua->post('http://wearehunted.com/ajax/both_mp3/',
		{
			't'      => $eid,
			'origin' => 'emerging',
		},
		'X-Hunted'         => 'Halt! Who goes there?',
		'X-Requested-With' => 'XMLHttpRequest'
	);
    die "WeAreHunted returned an error: $response->error_as_HTML" if $response->is_error;
	return decode_json($response->decoded_content)->{files}[0];
}
