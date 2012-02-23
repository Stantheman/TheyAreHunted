#!/usr/bin/env perl
use strict;
use warnings;
use JSON;
use Data::Printer;
use MP3::Tag;
use File::Path "make_path";

my $json_filename = shift or die "Usage: $0 /path/to/json";
open (my $json_fh, '<', $json_filename) or die "Can't open $json_filename: $!";
my $list_filename = 'songids.txt';
open (my $list_fh, '+<', $list_filename) or die "Can't open $list_filename: $!";
my @existing_songs = <$list_fh>;
my $song_path = '/home/stan/new-songs/wearehunted';
make_path($song_path) unless (-d $song_path);

foreach my $song (@{decode_json(<$json_fh>)}) {
	next if grep /$song->{id}/, @existing_songs;

	(my $unix_title = $song->{label}) =~ s/ /_/g;
	(my $unix_artist = $song->{artist}->{label}) =~ s/ /_/g;
	my $url = _get_song_url($song->{id});
	# assuming mp3
	qx(/usr/bin/wget $url -O "$song_path/$unix_artist-$unix_title.mp3");
	my $mp3 = MP3::Tag->new("$song_path/$unix_artist-$unix_title.mp3");
	$mp3->update_tags( {
		"title"  => $song->{label},
		"artist" => $song->{artist}->{label}
	});
}

sub _get_song_url {
	my $eid = shift or return;
	my $json = qx(curl -s 'http://wearehunted.com/ajax/both_mp3/' -d "t=$eid" -d "origin=emerging" -H "X-Hunted:Halt! Who goes there?" -H "X-Requested-With:XMLHttpRequest");
	return decode_json($json)->{files}[0];
}

