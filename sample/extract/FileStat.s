if( typeof module !== 'undefined' )
require( 'wFiles' )

var tree =
{
  'dir1' :
  {
    'dir2' :
    {
      'fileStat.txt' : 'some data...',
    }
  }
}

//

var _ = wTools;
var provider = _.FileProvider.Extract({ filesTree : tree });

// fileStat sync

var stats = provider.statRead
({
  filePath : '/dir1/dir2/fileStat.txt',
  sync : 1
});
console.log( stats );

// fileStat async

provider.statRead
({
  filePath : '/dir1/dir2/fileStat.txt',
  throwing : 1,
  sync : 0
})
.finallyGive( ( err, stat ) =>
{
  if( err ) throw err;
  console.log( stat );
});
