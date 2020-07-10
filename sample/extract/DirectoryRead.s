if( typeof module !== 'undefined' )
require( 'wFiles' )

var tree =
{
  'dir1' :
  {
    'dir2' :
    {
      'file1.txt' : 'some data...',
      'file2.txt' : 'some data...',
    }
  }
}

//

var _ = wTools;
var provider = _.FileProvider.Extract({ filesTree : tree });

//directoryRead sync

var content = provider.dirRead({ filePath : '/dir1/dir2' });
console.log( content );

// directoryRead async

var con = provider.dirRead({ filePath : '/dir1/dir2', sync : 0 });
con.got( ( content ) => console.log( content ) );
