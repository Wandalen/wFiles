( function _FileProvider_Extract_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  require( './aFileProvider.test.s' );
}

//

let _ = _global_.wTools;
let Parent = wTests[ 'Tools.mid.files.fileProvider.Abstract' ];
_.assert( !!Parent );

// --
// context
// --

function onSuiteBegin( test )
{
  let context = this;
  Parent.onSuiteBegin.apply( this, arguments );

  context.provider = _.FileProvider.Extract({ usingExtraStat : 1, protocols : [ 'current', 'second' ] });
  context.system = _.FileProvider.System({ providers : [ context.provider ] });
  context.system.defaultProvider = context.provider;

  context.suiteTempPath = context.provider.path.tempOpen( 'FilesFind' );
  context.globalFromPreferred = function globalFromPreferred( path ){ return path };

}

//

function onSuiteEnd()
{
  let context = this;
  let path = this.provider.path;
  // _.assert( _.mapKeys( context.provider.filesTree ).length === 1 ); // qqq : uncomment it, please
  return Parent.onSuiteEnd.apply( this, arguments );
}

//

function pathFor( filePath )
{
  let self = this;
  return self.provider.path.normalize( '/' + filePath );
}

//

function providerMake()
{
  let context = this;
  let provider = _.FileProvider.Extract({ protocols : [ 'current', 'second' ] });
  let system = _.FileProvider.System({ providers : [ provider ] }); /* xxx : try without the system ? */
  _.assert( system.defaultProvider === null );
  return provider;
}

// --
// tests
// --

function copy( test )
{

  test.case = 'default';

  var extract1 = new _.FileProvider.Extract();
  var extract2 = new _.FileProvider.Extract({});
  test.is( extract1.filesTree !== extract2.filesTree );

  test.case = 'from map with constructor';

  var op = { filesTree : {} }
  var extract1 = new _.FileProvider.Extract( op );
  var extract2 = new _.FileProvider.Extract( op );
  test.is( op.filesTree === extract1.filesTree );
  test.is( extract1.filesTree === extract2.filesTree );

  test.case = 'from map with copy';

  var op = { filesTree : {} }
  var extract1 = new _.FileProvider.Extract( op );
  var extract2 = new _.FileProvider.Extract();
  extract2.copy( op );
  test.is( op.filesTree === extract1.filesTree );
  test.is( extract1.filesTree === extract2.filesTree );

  // /* zzz : fix that */
  //
  // test.case = 'from another instance with constructor';
  //
  // var op = { filesTree : {} }
  // var extract1 = new _.FileProvider.Extract( op );
  // var extract2 = new _.FileProvider.Extract( extract1 );
  // test.is( op.filesTree === extract1.filesTree );
  // test.is( extract1.filesTree !== extract2.filesTree );
  //
  // test.case = 'from another instance with copy';
  //
  // var op = { filesTree : {} }
  // var extract1 = new _.FileProvider.Extract( op );
  // var extract2 = new _.FileProvider.Extract();
  // extract2.copy( extract1 );
  // test.is( op.filesTree === extract1.filesTree );
  // test.is( extract1.filesTree !== extract2.filesTree );
  //
  // test.case = 'from another instance with clone';
  //
  // var op = { filesTree : {} }
  // var extract1 = new _.FileProvider.Extract( op );
  // var extract2 = extract1.clone();
  // extract2.copy( extract1 );
  // test.is( op.filesTree === extract1.filesTree );
  // test.is( extract1.filesTree !== extract2.filesTree );

}

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.fileProvider.Extract',
  silencing : 1,
  abstract : 0,
  enabled : 1,
  routineTimeOut : 30000,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    pathFor,
    providerMake,

    // filesTree,
    provider : _.FileProvider.Extract( { usingExtraStat : 1 } ),
    globalFromPreferred : null,
    testFile : '/file1'
  },

  tests :
  {

    copy,

  },

}

//

let Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
