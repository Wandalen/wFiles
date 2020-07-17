
if( typeof module !== 'undefined' )
require( 'wFiles' )

let _ = wTools;

if( _.FileRecord )
{
  var f1 = _.fileProvider.record( `${__dirname}/Sample2.s` );
  var f2 = _.fileProvider.record( `${__dirname}/data/File1.txt` );
  var filesSame = _.fileProvider.filesAreSameForSure( f1, f2 );
  console.log( 'filesSame :', filesSame ); // logs: false

  var f1 = _.fileProvider.record( `${__dirname}/Sample2.s` );
  var f2 = _.fileProvider.record( `${__dirname}/Sample2.s` );
  var filesSame = _.fileProvider.filesAreSameForSure( f1, f2 );
  console.log( 'filesSame :', filesSame ); // logs: true
}

/* qqq : rewrite samples */
