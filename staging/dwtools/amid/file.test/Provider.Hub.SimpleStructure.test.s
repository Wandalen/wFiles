( function _FileProvider_Hub_SimpleStructure_test_s_( ) {

'use strict'; /*ddd*/

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = wTools;
var Parent = wTests[ 'FileProvider' ];

_.assert( Parent );

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
  'linkToFile' : [{ hardLink : './file' }],
  'linkToUnknown' : [{ hardLink : './unknown' }],
  'linkToDir' : [{ hardLink : './test_dir' }],
  'softLinkToFile' : [{ softLink : './file' }],
  'softLinkToUnknown' : [{ softLink : './unknown' }],
  'softLinkToDir' : [{ softLink : './test_dir' }],
}

//

function makePath( filePath )
{
  return '://' +  '/' + filePath;
}

function onSuitBegin()
{
  var self = this;
  var provider = _.FileProvider.SimpleStructure( { filesTree : filesTree } )
  self.provider.providerRegister( provider  );
  self.provider.defaultProvider = provider;
  self.provider.defaultOrigin = provider.originPath;
  self.provider.defaultProtocol = '';
}

// --
// proto
// --

var Proto =
{

  name : 'FileProvider.Hub.SimpleStructure',
  abstract : 0,
  silencing : 1,

  onSuitBegin : onSuitBegin,

  context :
  {
    provider : _.FileProvider.Hub({ empty : 1 }),
    filesTree : filesTree,
    makePath : makePath,
    testFile : 'file1'
  },

  tests :
  {
  },

}

//

var Self = new wTestSuit( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
