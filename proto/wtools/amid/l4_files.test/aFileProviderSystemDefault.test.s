( function _aFileProviderSystemDefault_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

let _ = _global_.wTools;
let Parent = wTests[ 'Tools.mid.files.fileProvider.Abstract' ];

_.assert( !!Parent );

//

function pathFor( filePath )
{
  return this.providerEffective.originPath +  '/' + filePath;
}

//

function onRoutineEnd( test )
{
  let context = this;
  let provider = context.provider;
  _.sure( _.arraySetIdentical( _.mapKeys( provider.providersWithProtocolMap ), [ 'second', 'current' ] ), test.name, 'has not restored system!' );
}

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.fileProvider.system.default.Abstract',
  abstract : 1,
  silencing : 1,

  onRoutineEnd,

  context :
  {
    pathFor,
  },

  tests :
  {
  },

}

//

let Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
