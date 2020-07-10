require( 'wFiles' );
var _ = wTools;

// files tree

var tree =
{
  'root' :
  {
    'File.js' : 'console.log( \'This is content of File.js\' )',
    'folder' :
    {
      'File.txt' : 'This is content of File.txt',
    }
  },
  'dir1' : {}
};

// file provider, copy files tree to memory

var extract = _.FileProvider.Extract( { filesTree : tree } );

// asynchronous deletion of files

_.time.out( 100, function ()
{
  console.log( extract.filesTree );
  console.log( '' );
  extract.filesDelete( '/root/' );
  console.log( extract.filesTree );
} );
