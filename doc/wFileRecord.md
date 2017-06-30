#### wFileRecord
Allows to create record that holds information about file:

|  Name 	|Type| Description  	|
|---	|---	|---  |
|relative |string |relative path to the file based on provided relative/dir options
|absolute |string |full path to file
|real |string |equal to absolute except case when resolvingTextLink option is used
|dir |string |path to dir where file is located
|isDirectory |bool |indicates whether the file is a folder
|inclusion |bool |indicates whether the file has passed all provided masks and date checks
|ext |string |file's extension
|extWithDot |string |same as ext but with dot
|name |string |name of a file without extension
|nameWithExt |string |name of a file with extension
|hash |string |file hash, can be obtained from hashGet method
|stat |object |[fs.Stats object](https://nodejs.org/api/fs.html#fs_class_fs_stats), if record.real path not exist stat will be null

#### Usage
Constructor arguments:
* filePath - absolute/relative path to file, if path is relative dir/relative option must be provided.
* o - options map.

##### Options:

|  Name 	|Type| Description  	|
|---	|---	|---  |
|dir |string|absolute path to dir where file is located, can be skipped if filePath is absolute
|relative|string|record.relative path is generated regarding to this option
|maskAll|wRegexpObject|prime mask for file/folder
|maskTerminal|wRegexpObject|additional mask for a file
|maskDir|wRegexpObject|additional mask for a directory
|notOlder|Date|checks if file is not older that specified date
|notOlderAge|Date|checks if age of a file is less or equal to duration between current  and specified dates
|notNewer|Date|checks if file is not newer that specified date
|notNewerAge|Date|checks if age of a file is bigger or equal to duration between current  and specified dates
|onRecord|function/Array|function/array of functions to call on record creation
|safe|bool|allows only safe file path, enabled by default
|strict|bool|prevents record object extension, enabled by default
|verbosity|bool|enables output of additional messages, disabled by default
|resolvingSoftLink|boool|makes file stat object using filePath as symbolic link
|resolvingTextLink|bool|enables support of relative soft links
|fileProvider|object|file provider, instanceof _.FileProvider.Abstract

Relative option always affects on `record.relative` property and not depends on type of filePath( relative/absolute ). If `relative` option is not specified, the value of `dir` is copied to `relative`.
Dir option always affects on `record.absolute` property. If `filePath` is relative and `dir` option is not specified, value of 'relative' is assigned to 'dir'.
Record `real` property is always equal to `absolute` except case when `resolvingTextLink` option is used.


##### Methods:
* changeExt - changes file extension.
* hashGet - returns file hash.
* toAbsolute - static function,returns absolute file path.

##### Example #1
```javascript
/* Getting file record using absolute path */
var filePath = '/D/folder/file_name';
/*
FileProvider.HardDrive - Allows files manipulations on local drive.
wFileRecord uses it to generate record.stat object.
More about provider: https://github.com/Wandalen/wFiles/blob/master/README.md
*/
var provider = _.FileProvider.HardDrive();
var record = _.FileRecord( filePath, { fileProvider : provider } );
console.log( record );
```

##### Example #2
```javascript
/* Getting file record using name and path to directory where file is located */
var fileName = 'file';
var directory = '/my_folder'
var provider = _.FileProvider.HardDrive();
var record = _.FileRecord( fileName, { fileProvider : provider, dir : directory } );
console.log( record );
```
##### Example #3
```javascript
/* Getting file record using dir and relative options */
var filePath = '/my_folder/file';
var dir = '/dir/my_folder';
var relative = '/X';
var provider = _.FileProvider.HardDrive();
/* dir option affects on record.absolute property, relative option is used to create record.relative property */
var record = _.FileRecord( filePath , { fileProvider : provider, dir : dir, relative : relative } );
console.log( record );
```
##### Example #4
```javascript
/* Using mask to filter file record */
var filePath = '/my_folder/file';
/*
RegExpObject - Object-container of regular expressions.
More about RegexpObject: https://github.com/Wandalen/wRegexpObject/blob/master/README.md
*/
var mask = _.RegexpObject( 'file','includeAny' );
var provider = _.FileProvider.HardDrive();
/* Generated record.relative path will be tested by provided mask and result( true/false ) recorded into record.inclusion property */
var record = _.FileRecord( filePath , { fileProvider : provider, maskAll : mask } );
console.log( record.inclusion );
```

##### Example #5
```javascript
/* Using notOlderAge options to check if file was created 1 second ago */
var filePath = '/my_folder/file';
var provider = _.FileProvider.HardDrive();
var age = 1000; // 1000 ms
var record = _.FileRecord( filePath, { fileProvider : provider, notOlderAge : age } );
/* returns false, because in this case we use not existing path */
console.log( record.inclusion );
```
