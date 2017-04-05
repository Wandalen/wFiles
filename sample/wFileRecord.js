if( typeof module !== 'undefined' )
{
  require( 'wTools' )
  require( '../staging/amid/file/FileBase.s' )
  require( '../staging/amid/file/FileMid.s' )
}

var _ = wTools;

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

/* Getting file record using name and path to directory where file is located */
var fileName = 'file';
var directory = '/my_folder'
var provider = _.FileProvider.HardDrive();
var record = _.FileRecord( fileName, { fileProvider : provider, dir : directory } );
console.log( record );

/* Getting file record using dir and relative options */
var filePath = '/my_folder/file';
var dir = '/dir/my_folder';
var relative = '/X';
var provider = _.FileProvider.HardDrive();
/* dir option affects on record.absolute property, relative option is used to create record.relative property */
var record = _.FileRecord( filePath , { fileProvider : provider, dir : dir, relative : relative } );
console.log( record );

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

/* Using notOlderAge options to check if file was created 1 second ago */
var filePath = '/my_folder/file';
var provider = _.FileProvider.HardDrive();
var age = 1000; // 1000 ms
var record = _.FileRecord( filePath, { fileProvider : provider, notOlderAge : age } );
/* returns false, because in this case we use not existing path */
console.log( record.inclusion );
