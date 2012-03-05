TheyAreHunted
=============

This script downloads every song from the emerging section of wearehunted.com. Tested on Debian, but should work with any flavor of Linux (probably Macs too).  

Features
--------
 * Tracks the songs it downloads to save bandwidth (no duplicates!) 
 * Designed for cron and works fine manually too
 * Tags the downloaded file with the title, artist, and a comment with the original date pulled and source URL
 * Replaces non-safe filename characters with underscores in the filename
 * Prints to the terminal only when being run by hand 

Install
-------

TheyAreHunted is a perl script and uses the following non-standard modules:

 * MP3::Tag
 * LWP::UserAgent
 * JSON

You can install these using your favorite method to install perl modules. If you don't have a favorite method, try cpanm:

    curl -L http://cpanmin.us | perl - --sudo App::cpanminus
	cpanm --sudo MP3::Tag LWP::UserAgent JSON

Usage
-----

TheyAreHunted will run with no parameters, ie:

    perl getsongs.pl

This will download the top 99 songs from the front page of WeAreHunted, to a directory called *./wearehunted_songs*. If you'd rather the files go to a different directory, tell the script:

    perl getsongs.pl /home/user/put/songs/here

You can use this line for a weekly cronjob. Since the script maintains a list of downloaded songs, you'll only get the new songs.

Notes
-----

Here's a few notes:

 * The songs are all 128kbps quality. If that's a problem, you should probably be buying your music.
 * Be nice to WeArehunted. They're really awesome. If you slam their servers, they'll either ban you or everyone.
 * This script is provided for educational purposes only. I don't take any responsibility for anything you do with this.
 * The script inserts the date the song was scraped into the comments tag. It would be neat to graph the rate of new songs per <cronjob period> over time.
 * Isn't the project name hilarious? I think so.

Author: Stan Schwertly

http://www.schwertly.com

