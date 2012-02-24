#!/usr/bin/env perl
use strict;
use warnings;
use JSON;
use Data::Printer;
use MP3::Tag;
use File::Path "make_path";
use LWP::UserAgent;

my $json_filename = shift or die "Usage: $0 /path/to/json";
my $list_filename = '/srv/git/wearehunted/songids.txt';
open (my $json_fh, '<', $json_filename) or die "Can't open $json_filename: $!";
open (my $list_fh, '+<', $list_filename) or die "Can't open $list_filename: $!";
my @existing_songs = <$list_fh>;
my $agentstring = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.75 Safari/535.';
my $ua = LWP::UserAgent->new(
	agent   => $agentstring, 
	timeout => 10,
);
my $song_path = '/home/stan/new-songs/wearehunted';
make_path($song_path) unless (-d $song_path);

my $count = 0;
foreach my $song (@{decode_json(<$json_fh>)}) {
	next if grep /$song->{id}/, @existing_songs;

	(my $unix_title = $song->{label}) =~ s/(\s|\/)/_/g;
	(my $unix_artist = $song->{artist}->{label}) =~ s/(\s|\/)/_/g;
	
	my $url = _get_song_url($song->{id});
	unless ($url){
		print "Couldn't download $song->{label} by $song->{artist}->{label}\n" if (-t);
		next;
	}
	# assuming mp3
	print "Getting $song->{label}\n" if (-t);
	my $res = $ua->mirror($url, "$song_path/$unix_artist-$unix_title.mp3");
	die "Couldn't mirror: $url $!" . p($res->is_redirect) unless ($res->is_success || $res->is_redirect);
	my $mp3 = MP3::Tag->new("$song_path/$unix_artist-$unix_title.mp3");
	$mp3->update_tags( {
		"title"  => $song->{label},
		"artist" => $song->{artist}->{label}
	});
	print $list_fh "$song->{id}\n";
	$count++;
}

print "downloaded $count songs" if (-t);
close $json_fh;
close $list_fh;

sub _get_song_url {
	my $eid = shift or return;
	my $json = qx(curl -s 'http://wearehunted.com/ajax/both_mp3/' -d "t=$eid" -d "origin=emerging" -H "X-Hunted:Halt! Who goes there?" -H "X-Requested-With:XMLHttpRequest" -A '$agentstring');
	return decode_json($json)->{files}[0];
}

