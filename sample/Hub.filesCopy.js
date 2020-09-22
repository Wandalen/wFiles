if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

/* filesCopy HardDrive -> Extract */

var hub = _.FileProvider.Hub();
var simpleStructure = _.FileProvider.Extract
({
  filesTree : Object.create( null )
});

hub.providerRegister( simpleStructure );

var hdUrl = _.fileProvider.urlFromLocal( _.normalize( __dirname ) );
var ssUrl = simpleStructure.urlFromLocal( '/dir/copy/to' );

hub.filesCopy
({
  dst : ssUrl,
  src : hdUrl,
  preserveTime : 0
});

var tree = _.toStr( simpleStructure.filesTree, { levels : 4 } );
console.log( tree );

