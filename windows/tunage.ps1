$itunes = New-Object -ComObject iTunes.Application;

$helpText = 'please tell me to "play" or "quit"';

$searchCodeAll = 0;
$searchCodeArtists = 2;
$searchCodeAlbums = 3;
$searchCodeComposers = 4;
$searchCodeTrackNames = 5;

##############
while ($input = Read-Host -Prompt '> ') {
    $words = $input -split ' '; #TODO: Multiword names!

    if ($words[0] -ieq 'play') {
        $zt = $itunes.CreatePlaylist('z_tunage');

        if ($words[1] -ieq 'playlist') {
            if ($words[2]) {
                $playlist = $itunes.LibrarySource.Playlists.ItemByName($words[2]);
                if ($playlist) {
                    $playlist.PlayFirstTrack();
                }
                else {
                    Write-Host 'Hmm... No playlist by that name was found.';
                }
            }
        }
        elseif ($words[1] -ieq 'album') {
            if ($words[2]) {
                $albumTracks = $itunes.LibraryPlaylist.Search($words[2], $searchCodeAlbums);

                foreach($at in $albumTracks) {
                    if ($at.Album -ieq $words[2]) {
                        $zt.AddTrack($at);
                    }
                }

                $zt.PlayFirstTrack();
            }
        }
        elseif ($words[1].ToLower() -eq 'track') {
            if ($words[2]) {
                #$track = $itunes.LibraryPlaylist.Tracks.ItemByName($words[2]);
                $track = $itunes.LibraryPlaylist.Search($words[2], $searchCodeTrackNames);
                if ($track) {
                    $track.Play();
                }
                else {
                    Write-Host 'Hmm... No track by that name was found.';
                }
            }
        }
        else {
            $itunes.Play();
        }
    }
    elseif ($words[0] -ieq 'list') {
        if ($words[1] -ieq 'tracks') {
            if ($words[2] -ieq 'for') {
                if ($words[3] -ieq 'album' -and $words[4]) {
                    $tracks = $itunes.LibraryPlaylist.Search($words[4], $searchCodeAlbums);

                    foreach ($t in $tracks) {
                        Write-Host $t.Name;
                    }
                }
                elseif ($words[3] -ieq 'playlist' -and $words[4]) {
                   $playlist = $itunes.LibrarySource.Playlists.ItemByName($words[4]);

                   foreach ($t in $playlist.Tracks) {
                       Write-Host $t.Name;
                   }
                }
            }
        }
        elseif ($words[1] -ieq 'playlists') {
            foreach ($p in $itunes.LibrarySource.Playlists) {
                Write-Host $p.Name;
            }
        }
        elseif ($words[1] -ieq 'albums') {
            if ($words[2] -ieq 'for') {
                if ($words[3] -ieq 'artist') {
                    $tracks = $itunes.LibraryPlaylist.Search($words[4], $searchCodeArtists);
                    
                    $seenAlbumNames = @();
                    foreach ($t in $tracks) {
                        if (-not ($seenAlbumNames -contains $t.Album)) {
                            Write-Host $t.Album;
                            $seenAlbumNames += $t.Album;
                        }
                    }
                }
            }
            
        }
    }
    elseif ($words[0] -ieq 'stop') {
        $itunes.Stop();
    }
    elseif ($words[0] -ieq 'pause') {
        $itunes.Pause();
    }
    elseif ($words[0] -ieq 'quit') {
        Write-Host 'Quit iTunes too?';
        $answer = Read-Host -Prompt '(Y/N) ';

        if ($answer -ieq 'Y') {
            $itunes.Quit();
        }
        break;
    }
    else {
        Write-Host 'Syntax Error';
        Write-Host $helpText;
    }
}

if ($itunes) {
    $null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$itunes);
    [gc]::Collect();
    Remove-Variable itunes;
}