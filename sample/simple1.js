
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

if( _.filesFind )
{

  var files = _.filesFind( __dirname,_.pathRegexpSafeShrink() );
  console.log( 'at ' + __dirname );
  console.log( _.entitySelect( files,'*.absolute' ) );

}
