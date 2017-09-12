#### wFileFiter.Archive
FileProvider that allows to track file changes in a directory and restore broken hardlinks.

##### Options:

|  Name 	|Type| Description  	|
|---	|---	|---  |
|verbosity |number | Controls level of details in output made by routines.
|trackPath |string | Absolute path to directory which will be tracked.
|trackingHardLinks |boolean | Compare number of hardlinks to a file on archive update, to determine if file was changed.
|fileMapAutosaving |boolean | Automaticaly saves archive in directory defined by path from trackPath property.
|archiveFileName   |string  | Archive file name on disk.

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

##### Methods:
* archiveUpdateFileMap - saves info about files trackPath on first run and updates it accordingly to new changes on next runs.

##### Example #1
```javascript
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
