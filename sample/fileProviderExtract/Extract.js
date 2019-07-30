require( 'wFiles' );
var _ = wTools;

// files tree

var tree =
{
  'root' :
  {
    'File.js' : "console.log( 'This is content of File.js' )",
    'folder' :
    {
      'File.txt' : "This is content of File.txt",
    }
  },
  'user' :
  {
    'UserFile' : 'This is content of UserFile'
  }
};

// file provider, copy files tree to memory

var extract = _.FileProvider.Extract( { filesTree : tree } );

// asynchronous deletion of files

var filesDelete = _.timeOut( 100, function ()
{
  console.log( extract.filesTree );
  console.log( '' );
  extract.filesDelete( '/user/' );
  console.log( extract.filesTree );
});

// asynchronous copying of files

var fileCopy = extract.fileCopy( { dstPath : '/user/File.txt', srcPath : '/root/folder/File.txt' , sync : 0  } );

// copy files to hard drive

extract.readToProvider( _.FileProvider.HardDrive(), _.path.current() );

// files tree in memory

console.log( extract.filesTree );
console.log( '' );