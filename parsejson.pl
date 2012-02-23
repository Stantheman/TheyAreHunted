#!/usr/bin/env perl
use strict;
use warnings;
use JSON;
use Data::Printer;
use MP3::Tag;

my $json_filename = shift or die "Usage: $0 /path/to/json";
open (my $json_fh, '<', $json_filename) or die "Can't open $json_filename: $!";
my $list_filename = 'songids.txt';
open (my $list_fh, '+<', $list_filename) or die "Can't open $list_filename: $!";
my @existing_songs = <$list_fh>;

foreach my $song (@{decode_json(<$json_fh>)}) {
	next if grep $song->{id}, @existing_songs; # peace if we have this song
				
	print "$song->{label}\t$song->{artist}->{label}\t$song->{id}\n";
	_get_song_info($song->{id});
}

sub _get_song_info {
	my $eid = shift or return;
	my $json = qx(curl -s 'http://wearehunted.com/ajax/both_mp3/' -d "t=$eid" -d "origin=emerging" -H "X-Hunted:Halt! Who goes there?" -H "X-Requested-With:XMLHttpRequest");
	p $json;
	exit 0;
}
