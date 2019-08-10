#### wFileFiter.Archive
FileProvider that allows to track file changes in a directory and restore broken hardlinks.

Archive contains several maps that stores info about file changes:

* **fileMap** - Info about all tracked files.
* **fileAddedMap** - Info about files added since the last archive update.
* **fileRemovedMap** - Info about files removed since the last archive update.
* **fileModifiedMap** - Info about files which content was changed since the last archive update.

The key of each map is a absolute path to a file. Value store by the key is a object with a properties:

For a **directory** is:

|  Name 	|Type| Description  	|
|---	|---	|---  |
|mtime |number | time of last modification
|absolutePath |string | absolute path to a directory

For a **terminal** file:

|  Name 	|Type| Description  	|
|---	|---	|---  |
|mtime |number | time of last modification
|absolutePath |string | absolute path to a file
|size |number | current size of a file
|hash |string | digest of file content
|hash2 |number | inode number
|nlink |number | number of hardlinks to a file

Additional maps :
* **fileByHashMap** - .
* **fileHashMap** - .
* **dependencyMap** - .

##### Properties of a archive:

|  Name 	|Type| Description  	|
|---	|---	|---  |
|verbosity |number | Controls level of details in output made by routines.
|trackPath |string | Absolute path to directory which will be tracked.
|trackingHardLinks |boolean | Compare number of hardlinks to a file on archive update, to determine if file was changed.
|fileMapAutosaving |boolean | Automaticaly saves fileMap in directory defined by path from trackPath property.
|archiveFileName   |string  | Archive file name on disk.

Each parameter can be setted through acrhive property of a provider.

##### Methods:
* archiveUpdateFileMap - saves info about files trackPath on first run and updates it accordingly to new changes on next runs.
* contentUpdate - .
* statUpdate - .
* dependencyAdd - .
* fileHashMapForm - .
* restoreLinksBegin - saves info about tracked files from trackPath, that info is used by **restoreLinksEnd** to resore broken hardlinks.
* restoreLinksEnd - restores hardlinks that was broken since last **restoreLinksBegin** routine call.

#### Usage
```javascript
var provider = _.FileFilter.Archive();
/* setting the directory to track */
provider.archive.trackPath = __dirname;
/* getting info about files from trackPath */
provider.archive.archiveUpdateFileMap();
/* printing last info about files from tracked directory */
console.log( provider.archive.fileMap )
```

##### Example #1
```javascript
/* tracking changes */
var provider = _.FileFilter.Archive();
/* setting the directory to track */
provider.archive.trackPath = __dirname;
/* adding new file */
provider.fileWrite( _.pathJoin( __dirname, 'file' ), '' );
/* getting info about files from trackPath */
provider.archive.archiveUpdateFileMap();
/* making some changes in file */
provider.fileWrite( _.pathJoin( __dirname, 'file' ), 'abc' );
/* updating again and getting info about new changes made from last archive update */
provider.archive.archiveUpdateFileMap();
```

##### Example #2
```javascript
/* storing archive on a disk */
var provider = _.FileFilter.Archive();
provider.archive.trackPath = __dirname;
provider.archive.verbosity = 0;
/* fileMapAutosaving  enables saving fileMap on a disk */
provider.archive.fileMapAutosaving = 1;
provider.archive.archiveUpdateFileMap();
var fileMapPath = _.pathJoin( provider.archive.trackPath, provider.archive.archiveFileName );
var fileMap = provider.fileReadJson( fileMapPath );
console.log( 'fileMap :', fileMap );
```

##### Example #3
```javascript
/* restoring broken hardlink */
var provider = _.FileFilter.Archive();
provider.archive.trackPath = __dirname;
/* trackingHardLinks must be enabled */
provider.archive.trackingHardLinks = 1;
/* preparing files */
var path1 = _.pathJoin( __dirname, 'file1' );
var path2 = _.pathJoin( __dirname, 'file2' );
provider.fileWrite( path1, 'abc' );
provider.fileWrite( path2, 'abc' );
/* creating hardlink */
provider.linkHard( path1, path2 )
/* preparing info for restore */
provider.archive.restoreLinksBegin();
/* breaking the hardlink by recreating the file, but with different content */
provider.fileDelete( path1 );
provider.fileWrite( path1, 'bca' );
/* restoring the hardlink */
provider.archive.restoreLinksEnd();
/* printing content, both files must contain 'bca' */
console.log( provider.fileRead( path1 ) )
console.log( provider.fileRead( path2 ) )
```
