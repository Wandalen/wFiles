
if( typeof module !== 'undefined' )
var _ = require( '..' )

_.include( 'wAppBasic' )

let o = 
{
  currentPath : __dirname,
  sync : 1
}

let shell = _.sheller( o );

debugger
shell( 'ls' )
