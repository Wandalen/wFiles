#### wFileRecord
Allows to create record that holds information about file:

|  Name 	|Type| Description  	|
|---	|---	|---  |
|relative |string |relative path to file based on provided relative/dir option
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
|relative|string|path related to filePath, used to build relative path to a file
|maskAll|wRegexpObject|prime mask for file/folder
|maskTerminal|wRegexpObject|additional mask for a file
|maskDir|wRegexpObject|additional mask for a directory
|notOlder|Date|checks if file is not older that specified date
|notOlderAge|Date|checks if age of a file is less or equal to duration between current  and specified dates
|notNewer|Date|checks if file is not newer that specified date
|notNewerAge|Date|checks if age of a file is bigger or equal to duration between current  and specified dates
|onRecord|function/Array|function/array of functions to call on current record instance
|safe|bool|allows only safe file path, enabled by default
|strict|bool|prevents record object extension, enabled by default
|verbosity|bool|enables output of additional messages, disabled by default
|resolvingSoftLink|boool|makes file stat object using filePath as symbolic link
|resolvingTextLink|bool|
|fileProvider|object|file provider must be instanceof _.FileProvider.Abstract

Relative option always affects on `record.relative` path. Also it can affects on `record.absolute`( o.dir === o.relative ) in case when `filePath` is relative path and `dir` option is not specified.

##### Methods:
* changeExt - changes file extension.
* hashGet - returns file hash.
* toAbsolute - static function,returns absolute file path.

##### Example #1
```javascript
/*Simplest using only absolute path*/
var path = _.pathRealMainFile();// absolute path to current file
var record = _.fileProvider.fileRecord( path );
console.log( record );
```

##### Example #2
```javascript
/*relative only specified*/
/*path is absolute,relative affects only on record.relative*/
var path = '/dir/some_file';
var record = _.FileRecord( path, { fileProvider : _.fileProvider, relative : '/X' } );
console.log( record );

/*path is relative, relative affects on record properties*/
var path = './dir/some_file';
var record = _.FileRecord( path, { fileProvider : _.fileProvider, relative : '/X' } );
console.log( record );
```

##### Example #3
```javascript
/*dir only specified, relative is equal to dir*/
/*path is absolute*/
var path = '/dir/some_file';
var record = _.FileRecord( path, { fileProvider : _.fileProvider, dir : '/A' } );
console.log( record );

/*path is relative*/
var path = './dir/some_file';
var record = _.FileRecord( path, { fileProvider : _.fileProvider, dir : '/A' } );
console.log( record );
```

##### Example #4
```javascript
/*Mask*/
var path = '/dir/some_file';
var mask = 'dir';// can be string or regexp
var regexpObject = _.regexpMakeObject( mask, 'includeAny' );
var record = _.FileRecord( path, { fileProvider : _.fileProvider, dir : '/A', maskAll : regexpObject } );
console.log( record.inclusion );// result of mask test on record.relative
```

##### Example #5
```javascript
/*Date check*/
var path = _.pathRealMainFile();//path must exist to get stat object
var date = new Date( Date.UTC( 2016, 1, 1 ) );
var record = _.FileRecord( path, { fileProvider : _.fileProvider, notOlderAge : date } );
console.log( record.inclusion );//result of check if file age is not bigger then time between current and specified dates.
```
