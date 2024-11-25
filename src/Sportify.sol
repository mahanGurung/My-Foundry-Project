// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Spotify {
    struct Artist {
        uint256 id;
        string name;
        address artistAdd;
    }

    struct Album {
        uint256 id;
        string name;
        string artistName;
        string category;
        bool exists;
    }

    struct Song {
        uint256 id;
        string name;
        string artistName;
        string category;
        string album;
        bool exists;
    }

    mapping(uint256 => Artist) public artists;
    uint256[] public artistIds;
    uint256 public artistCount;

    mapping(uint256 => Album) public albums;
    uint256[] public albumIds;
    uint256 public albumCount;

    mapping(uint256 => Song) public songs;
    uint256[] public songIds;
    uint256 public songCount;

    function addArtist(string memory _name) public {
        artistCount++;
        artists[artistCount] = Artist(artistCount, _name, msg.sender);
        artistIds.push(artistCount);
    }

    function addAlbum(string memory _name, string memory _artistName, string memory _category) public {
        bool artistExists = false;
        for (uint256 i = 0; i < artistIds.length; i++) {
            if (keccak256(abi.encode(artists[artistIds[i]].artistAdd)) == keccak256(abi.encode(msg.sender))) {
                artistExists = true;
                break;
            }
        }
        require(artistExists, "Only registered artists can add albums");
        albumCount++;
        albums[albumCount] = Album(albumCount, _name, _artistName, _category, true);
        albumIds.push(albumCount);
    }

    function addSong(string memory _name, string memory _artistName, string memory _category, string memory _album)
        public
    {
        bool artistExists = false;
        for (uint256 i = 0; i < artistIds.length; i++) {
            if (keccak256(abi.encode(artists[artistIds[i]].artistAdd)) == keccak256(abi.encode(msg.sender))) {
                artistExists = true;
                break;
            }
        }
        require(artistExists, "Only registered artists can add albums");
        string memory album = bytes(_album).length > 0 ? _album : "No album";
        songCount++;
        songs[songCount] = Song(songCount, _name, _artistName, _category, album, true);
        songIds.push(songCount);
    }

    function getSong(uint256 _id) public view returns (string memory, string memory) {
        require(songs[_id].exists, "Song does not exist");
        return (songs[_id].name, songs[_id].artistName);
    }

    function deleteSong(uint256 _id) public {
        require(songs[_id].exists, "Song does not exist");
        songs[_id].exists = false;
    }

    function deleteAlbum(uint256 _id) public {
        require(albums[_id].exists, "Album doesn't exist");
        string memory albumName = albums[_id].name;

        for (uint256 i = 0; i < songCount; i++) {
            if (keccak256(abi.encodePacked(songs[i + 1].album)) == keccak256(abi.encodePacked(albumName))) {
                songs[i + 1].exists = false;
            } else {
                songs[i + 1].exists = true;
            }
        }
        albums[_id].exists = false;
    }

    function getAllArtists() public view returns (Artist[] memory) {
        Artist[] memory allArtists = new Artist[](artistCount);

        for (uint256 i = 0; i < artistCount; i++) {
            allArtists[i] = artists[artistIds[i]];
        }

        return allArtists;
    }

    function getAllAlbum() public view returns (Album[] memory) {
        Album[] memory allAlbums = new Album[](albumCount);
        for (uint256 i = 0; i < albumCount; i++) {
            allAlbums[i] = albums[albumIds[i]];
        }

        return allAlbums;
    }

    function getAllSong() public view returns (Song[] memory) {
        Song[] memory allSongs = new Song[](songCount);
        for (uint256 i = 0; i < songCount; i++) {
            allSongs[i] = songs[songIds[i]];
        }
        return allSongs;
    }
}
