( function _aFileProviderSystemDefault_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

const _ = _global_.wTools;
const Parent = wTests[ 'Tools.files.fileProvider.Abstract' ];

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

const Proto =
{

  name : 'Tools.files.fileProvider.system.default.Abstract',
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

const Self = wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
