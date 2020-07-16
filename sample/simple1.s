
if( typeof module !== 'undefined' )
let _ = require( '..' )

_.include( 'wProcess' )

let o = 
{
  currentPath : __dirname,
  sync : 1
}

let shell = _.sheller( o );

debugger
shell( 'ls' )
