#!/usr/bin/perl

# --
# tunage is a command-line control system
# for iTunes.
# 
# [Version: 1.2]
# [For: iTunes 12.7.3.46]
# --

# constants #
$osascript = '/usr/bin/osascript';
$itunes    = '"iTunes"';
$xscratchx = '"xscratchx"';
$machina   = '"eppc://127.0.0.1"';
$volume = 20;
$empty = '""';

# helpers #
sub scriptify {
	$x = pop @_;
	$x =~ s/\n/\' -e \'/g;
	$x = "-e '$x'";
	return $x;
}

# verbs #
sub playAlbum {
	$album = pop @_;

	$x =<<EOF;
tell application $itunes
	set myTracks to (tracks where album is $album)
	
	if (myTracks = {}) then
		return "No album by that name"
	end if

	if exists (playlist $xscratchx of first source) then
		delete (playlist $xscratchx of first source)
	end if
	set myPlaylist to make new user playlist with properties {name: $xscratchx}

	repeat with aTrack in myTracks
		duplicate aTrack to myPlaylist
	end repeat

	play myPlaylist
end tell
EOF
	scriptify($x);

	#$err = "$x\n"; 
	$err = `$osascript $x` ;
	print $err if ($err ne '');
}

sub playArtist {
	$artist = pop @_;

	$x =<<EOF;
tell application $itunes 
	set myTracks to (tracks where artist is $artist)
	
	if (myTracks = {}) then
		return "No artist by that name"
	end if

	if exists (playlist $xscratchx of first source) then
		delete (playlist $xscratchx of first source)
	end if
	set myPlaylist to make new user playlist with properties {name: $xscratchx}

	repeat with aTrack in myTracks
		duplicate aTrack to myPlaylist
	end repeat

	play myPlaylist
end tell
EOF
	scriptify($x);

	#$err = "$x\n"; 
	$err = `$osascript $x` ;
	print $err if ($err ne '');
}

sub playPlaylist {
	$playlist = pop @_;

	$x =<<EOF;
tell application $itunes
	play playlist $playlist
end tell
EOF
	scriptify($x);

	#$err = "$x\n"; 
	$err = `$osascript $x` ;
	print $err if ($err ne '');
}

sub pause { 
	$x =<<EOF;	
tell application "iTunes"
	playpause
end tell
EOF
	scriptify($x);
	
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub stop { 
	$x =<<EOF;	
tell application "iTunes"
	stop
end tell
EOF
	scriptify($x);
	
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub resume { 
	$x =<<EOF;	
tell application "iTunes"
	play
end tell
EOF
	scriptify($x);
	
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub playnext {
	$x =<<EOF;
tell application "iTunes"
	next track
end tell
EOF
	scriptify($x);
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub playprevious {
	$x =<<EOF;
tell application "iTunes"
	previous track
end tell
EOF
	scriptify($x);
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub setVolume {
	$setting = pop @_;

	$x = "set volume output volume $setting";
	scriptify($x);
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub listAlbumsForArtist {
        $flag = pop @_;
	$x =<<EOF;
tell application $itunes
	set sList to {}
	set sTracks to (tracks where artist is $flag)
        
        repeat with sTrack in sTracks
		set sMot to (album of sTrack)
		if not (sList contains sMot) then
			set sList to {sMot} & sList
		end if
	end repeat

	set text item delimiters of AppleScript to ASCII character 10
	return sList as string
end tell
EOF
	scriptify($x);
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub listTracksForAlbum {
        $flag = pop @_;
	$x =<<EOF;
tell application $itunes
	set sList to {}
	set sTracks to (tracks where album is $flag)
        
        repeat with sTrack in sTracks
		set sMot to (name of sTrack)
		if not (sList contains sMot) then
			set sList to {sMot} & sList
		end if
	end repeat

	set text item delimiters of AppleScript to ASCII character 10
	return sList as string
end tell
EOF
	scriptify($x);
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub lister {
        $flag = pop @_;
	$x =<<EOF;
tell application $itunes
	set sList to {}
	set sTracks to (tracks where $flag is not $empty)
        
        repeat with sTrack in sTracks
		set sMot to ($flag of sTrack)
		if not (sList contains sMot) then
			set sList to {sMot} & sList
		end if
	end repeat

	set text item delimiters of AppleScript to ASCII character 10
	return sList as string
end tell
EOF
}

sub listArtists {
	$x = lister('artist');
	scriptify($x);
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub listAlbums {
	$x = lister('album');
	scriptify($x);
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub listPlaylists {
        $flag = pop @_;
	$x =<<EOF;
tell application "iTunes"
    set sList to {}
    
    repeat with sPlist in playlists
        set sName to (name of sPlist)
        set sList to sList & {sName}
    end repeat
    
    set text item delimiters of AppleScript to ASCII character 10
    
    return sList as string
end tell
EOF
	scriptify($x);
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub listTracksForPlaylist {
    $flag = pop @_;
    $x =<<EOF;
tell application "iTunes"
    set sList to {}
    set sPlaylist to playlist $flag
    
    repeat with sTrack in (tracks of sPlaylist)
        set sName to (name of sTrack)
        set sList to sList & {sName}
    end repeat
    
    set text item delimiters of AppleScript to ASCII character 10
    
    return sList as string
end tell
EOF
    scriptify($x);
    $err = `$osascript $x`;
    print $err if ($err ne '');
}

sub printHelp() {
	print<<EOF
list [artists|albums|playlists]
list albums for artist "name"
list tracks for album "name"
play [album|artist|playlist] "name"
pause
stop
turn [up|down]
next
previous
help (shows this)
quit
EOF
;
}

sub startApp {
	$x=<<EOF;
tell application $itunes
	run
end tell
EOF
;
	scriptify($x);
	$err = `$osascript $x`;
	print $err if ($err ne '');
}

sub quitApp {
	$x=<<EOF;
tell application $itunes
	quit
end tell
EOF
;
	scriptify($x);
	$err = `$osascript $x`;
	print $err if ($err ne '');
}


# --- #
# main control loop #
$cmd = join(' ', @ARGV);
$wasCmdLine = 0;

if ($cmd) {
	$wasCmdLine = 1;
}

startApp();
setVolume($volume);
do {
	if ($wasCmdLine) {
		print 'CMD: ', $cmd, "\n";
	}

	chomp($cmd);
	@words = split(' ', $cmd);

	# switch on verb and qualified object #
	if ($words[0] eq 'play') {
		if ($words[1] eq 'album') {
			if ($words[2] =~ /\"/) {
				playAlbum(join(' ', @words[2..$#words]));
			} else {
				print "please quote album name\n";
			}
		} elsif($words[1] eq 'artist') {
			if ($words[2] =~ /\"/) {
				playArtist(join(' ', @words[2..$#words]));
			} else {
				print "please quote artist name\n";
			}
		} elsif($words[1] eq 'playlist') {
			if ($words[2] =~ /\"/) {
				playPlaylist(join(' ', @words[2..$#words]));
			} else {
				print "please quote playlist name\n";
			}
		} else {
			print "syntax: play [album|artist|playlist] \"name\"\n"; 
		}
	} elsif ($words[0] eq 'pause') {
		pause();
	} elsif ($words[0] eq 'stop') {
		stop();
	} elsif ($words[0] eq 'resume') {
		resume();
	} elsif ($words[0] eq 'turn') {
		if ($words[1] eq 'up') {
			$volume = $volume+10;
			setVolume($volume);
		} elsif ($words[1] eq 'down') {
			$volume = $volume-10;
			setVolume($volume);
		}
	} elsif ($words[0] eq 'next') {
		playnext();
	} elsif ($words[0] eq 'previous') {
		playprevious();
	} elsif ($words[0] eq 'list') {
		if ($words[1] eq 'artists') {
			listArtists();
		} elsif ($words[1] eq 'playlists') {
            listPlaylists();
		} elsif ($words[1] eq 'albums' && $words[2] eq 'for' && $words[3] eq 'artist') {
			if ($words[4] =~ /\"/) {
				listAlbumsForArtist(join(' ', @words[4..$#words]));
			} else {
				print "please quote artist name\n";
			}
		} elsif ($words[1] eq 'tracks' && $words[2] eq 'for' && $words[3] eq 'album') {
			if ($words[4] =~ /\"/) {
				listTracksForAlbum(join(' ', @words[4..$#words]));
			} else {
				print "please quote album name\n";
			}
		} elsif ($words[1] eq 'tracks' && $words[2] eq 'for' && $words[3] eq 'playlist') {
			if ($words[4] =~ /\"/) {
				listTracksForPlaylist(join(' ', @words[4..$#words]));
			} else {
				print "please quote playlist name\n";
			}
		} elsif ($words[1] eq 'albums') {
			listAlbums();
		}
	} elsif ($words[0] eq 'help') {
		printHelp();
	} elsif ($words[0] eq 'quititunes') {
		quitApp();
	} elsif ($words[0] eq 'quit' or $words[0] eq 'exit' or $words[0] eq '\q') {
		exit();
	}

	# prompt #
	if ($wasCmdLine) {
		exit();
	} else {
		print "play> ";
	}
} while ($cmd = <STDIN>);
