( function _FileProvider_Hub_Extract_test_s_( ) {

'use strict';  

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = wTools;
var Parent = wTests[ 'Tools/mid/files/fileProvider/Abstract' ];

_.assert( !!Parent );

//

var filesTree =
{
  'folder.abc' :
  {
    'test1.js' : "test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n",
    'test2' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
    'folder2.x' :
    {
      'test1.txt' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
    }
  },
  'test_dir' :
  {
    'test3.js' : 'test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n',
  },
  'file1' : 'Excepteur sint occaecat cupidatat non proident',
  'file' : 'abc',
  'linkToFile' : [{ hardLink : '/file' }],
  'linkToUnknown' : [{ hardLink : '/unknown' }],
  'linkToDir' : [{ hardLink : '/test_dir' }],
  'softLinkToFile' : [{ softLink : '../file' }],
  'softLinkToUnknown' : [{ softLink : '../unknown' }],
  'softLinkToDir' : [{ softLink : '../test_dir' }],
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
    filesTree : filesTree,
    protocols : [ 'extract' ],
    usingExtraStat : 1
  });
  self.provider.providerRegister( self.providerEffective );

  self.provider.defaultProvider = self.providerEffective;
  self.globalFromLocal = _.routineJoin( self.providerEffective.path, self.providerEffective.path.globalFromLocal );
  self.provider.UsingBigIntForStat = self.providerEffective.UsingBigIntForStat;
  // self.provider.defaultOrigin = self.providerEffective.originPath;
  // self.provider.defaultProtocol = self.providerEffective.protocol;
}

// --
// declare
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/Hub/withExtract',
  abstract : 0,
  silencing : 1,
  enabled : 1,

  onSuiteBegin : onSuiteBegin,

  context :
  {
    provider : _.FileProvider.Hub({ empty : 1 }),
    providerEffective : null,
    filesTree : filesTree,
    pathFor : pathFor,
    globalFromLocal : null
    // testFile : 'file1'
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
