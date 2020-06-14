( function _System_Extract_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = _global_.wTools;
var Parent = wTests[ 'Tools.mid.files.fileProvider.Abstract' ];

_.assert( !!Parent );

//

var filesTree =
{
  // 'folder.abc' :
  // {
  //   'test1.js' : "test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n",
  //   'test2' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
  //   'folder2.x' :
  //   {
  //     'test1.txt' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
  //   }
  // },
  // 'test_dir' :
  // {
  //   'test3.js' : 'test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n',
  // },
  // 'file1' : 'Excepteur sint occaecat cupidatat non proident',
  // 'file' : 'abc',
  // 'linkToFile' : [{ hardLink : '/file' }],
  // 'linkToUnknown' : [{ hardLink : '/unknown' }],
  // 'linkToDir' : [{ hardLink : '/test_dir' }],
  // 'softLinkToFile' : [{ softLink : '../file' }],
  // 'softLinkToUnknown' : [{ softLink : '../unknown' }],
  // 'softLinkToDir' : [{ softLink : '../test_dir' }],
}

//

function pathFor( filePath )
{
  return this.providerEffective.originPath +  '/' + filePath;
}

function onSuiteBegin()
{
  var self = this;
  self.providerEffective = _.FileProvider.Extract
  ({
    filesTree,
    protocols : [ 'current', 'second' ],
    usingExtraStat : 1
  });
  self.provider.providerRegister( self.providerEffective );

  self.provider.defaultProvider = self.providerEffective;
  self.globalFromPreferred = _.routineJoin( self.providerEffective.path, self.providerEffective.path.globalFromPreferred );
  self.provider.UsingBigIntForStat = self.providerEffective.UsingBigIntForStat;
  // self.provider.defaultOrigin = self.providerEffective.originPath;
  // self.provider.defaultProtocol = self.providerEffective.protocol;
}

function onRoutineEnd( test )
{
  let context = this;
  let provider = context.provider;
  _.sure( _.arraySetIdentical( _.mapKeys( provider.providersWithProtocolMap ), [ 'second', 'current' ] ), test.name, 'has not restored system!' );
}

function onSuiteEnd()
{
  let self = this;
  self.providerEffective.finit();
  self.provider.finit();
}

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.fileProvider.System.Extract',
  abstract : 0,
  silencing : 1,
  enabled : 1,

  onSuiteBegin,
  onSuiteEnd,
  onRoutineEnd,

  context :
  {
    provider : _.FileProvider.System({ empty : 1 }),
    providerEffective : null,
    filesTree,
    pathFor,
    globalFromPreferred : null
  },

  tests :
  {
  },

}

//

var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
