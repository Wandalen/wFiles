( function _EncodersExtended_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../Tools.s' );
  require( '../l4_files/entry/EncodersExtended.s' );
  _.include( 'wTesting' );
}

//

var _ = _global_.wTools;
var Parent = wTester;

//

function onSuiteBegin()
{
  let context = this;
  debugger;
  context.provider = _.FileProvider.HardDrive();
  debugger;
  context.testSuitePath = context.provider.path.pathDirTempOpen( 'EncodersExtended' );
}

//

function onSuiteEnd()
{
  let context = this;
  // _.assert( _.strHas( this.testSuitePath, 'tmp.tmp' ) );
  context.provider.path.pathDirTempClose( this.testSuitePath );
  this.provider.finit();
}

//

function pathFor( filePath )
{
  let path = this.provider.path;
  filePath =  path.join( this.testSuitePath, filePath );
  return path.normalize( filePath );
}

// --
// tests
// --

function readWriteCson( test )
{
  let self = this;
  let provider = self.provider;
  let path = provider.path;
  let testPath = self.pathFor( 'written/' + test.name );
  let testFilePath = path.join( testPath, 'config.cson' );

  /**/

  let src =
  {
    string: 'string',
    number: 1.123,
    bool: false,
    array: [ 1, '1', true ],
    regexp: /\.string$/,
    map: { a: 'string', b: 1, c: false },
  }

  let src2 = { a0 : { b0 : { c0 : { p : 1 }, c1 : 1 }, b1 : 1 }, a1 : 1 };

  /**/

  test.case = 'write and read cson file, using map as data';
  provider.filesDelete( testPath );
  provider.fileWrite({ filePath : testFilePath, data : src, encoding : 'cson' });
  var got = provider.fileRead({ filePath : testFilePath, encoding : 'cson' });
  test.identical( got, src );
  var got = provider.fileRead({ filePath : testFilePath });
  var expected =
`string: 'string'
number: 1.123
bool: false
array: [
  1
  '1'
  true
]
regexp: /\\.string$/
map:
  a: 'string'
  b: 1
  c: false
`
  test.identical( got,expected )

  /**/

  test.case = 'write and read cson file, using complex map as data';
  provider.filesDelete( testPath );
  provider.fileWrite({ filePath : testFilePath, data : src2, encoding : 'cson' });
  var got = provider.fileRead({ filePath : testFilePath, encoding : 'cson' });
  test.identical( got, src2 );
  var got = provider.fileRead({ filePath : testFilePath });
  console.log( got )
  var expected =
`a0:
  b0:
    c0: p: 1
    c1: 1
  b1: 1
a1: 1
`
  test.identical( got,expected )
}

//

function readWriteYaml( test )
{
  let self = this;
  let provider = self.provider;
  let path = provider.path;
  let testPath = self.pathFor( 'written/' + test.name );
  let testFilePath = path.join( testPath, 'config.yml' );

  /**/

  let src =
  {
    string: 'string',
    number: 1.123,
    bool: false,
    array: [ 1, '1', true ],
    regexp: /\.string$/,
    map: { a: 'string', b: 1, c: false },
  }

  let src2 = { a0 : { b0 : { c0 : { p : 1 }, c1 : 1 }, b1 : 1 }, a1 : 1 };

  /* */

  test.case = 'write and read yaml file, using map as data';
  provider.filesDelete( testPath );
  provider.fileWrite({ filePath : testFilePath, data : src, encoding : 'yaml' });
  var got = provider.fileRead({ filePath : testFilePath, encoding : 'yaml' });
  test.identical( got, src );
  var got = provider.fileRead({ filePath : testFilePath });
  var expected =
`string: string
number: 1.123
bool: false
array:
  - 1
  - '1'
  - true
regexp: !<tag:yaml.org,2002:js/regexp> /\\.string$/
map:
  a: string
  b: 1
  c: false
`
  test.identical( got,expected )

  /**/

  test.case = 'write and read yaml file, using complex map as data';
  provider.filesDelete( testPath );
  provider.fileWrite({ filePath : testFilePath, data : src2, encoding : 'yaml' });
  var got = provider.fileRead({ filePath : testFilePath, encoding : 'yaml' });
  test.identical( got, src2 );
  var got = provider.fileRead({ filePath : testFilePath });
  var expected =
`a0:
  b0:
    c0:
      p: 1
    c1: 1
  b1: 1
a1: 1
`
  test.identical( got,expected )

}

//

function readWriteBson( test )
{
  let self = this;
  let provider = self.provider;
  let path = provider.path;
  let testPath = self.pathFor( 'written/' + test.name );
  let testFilePath = path.join( testPath, 'config' );

  let src =
  {
    string: 'string',
    number: 1.123,
    bool: false,
    array: [ 1, '1', true ],
    regexp: /\.string$/,
    map: { a: 'string', b: 1, c: false },
  }

  /**/

  test.case = 'write and read yaml file, using map as data';
  provider.filesDelete( testPath );
  provider.fileWrite({ filePath : testFilePath, data : src, encoding : 'bson' });
  var got = provider.fileRead({ filePath : testFilePath, encoding : 'bson' });
  test.identical( got, src );
}

//

function performance( test )
{
  let self = this;

  let Yaml = require( 'js-yaml' );
  let Bson = require( 'bson' );
  let Coffee = require( 'coffeescript' );
  let Js2coffee = require( 'js2coffee' );

  let readResults = [];
  let writeResults = [];
  let times = 10000;

  /**/

  let src =
  {
    string: 'string',
    number: 1.1234567,
    bool: false,
    array: [ 1, '1', true ],
    date : new Date(),
    map: { a: 'string', b: 1, c: false },
  }


  /* bson */

  var timeNow = _.time.now();
  var serialized;
  for( var i = 0; i < times; i++ )
  {
    serialized = Bson.serialize( src );
  }
  let bsonWriteTime = _.time.spent( timeNow );
  writeResults.push([ 'bson', bsonWriteTime, times ]);

  var timeNow = _.time.now();
  var deserialized;
  for( var i = 0; i < times; i++ )
  {
    deserialized = Bson.deserialize( serialized );
  }
  let bsonReadTime = _.time.spent( timeNow );
  readResults.push([ 'bson', bsonReadTime, times  ]);

  /* cson */

  var timeNow = _.time.now();
  var serialized;
  for( var i = 0; i < times; i++ )
  {
    let data = _.toStr( src, { jsLike : 1, keyWrapper : '' } );
    data = '(' + data + ')';
    serialized = Js2coffee( data );
  }
  let csonWriteTime = _.time.spent( timeNow );
  writeResults.push([ 'cson', csonWriteTime, times ]);

  var timeNow = _.time.now();
  var deserialized;
  for( var i = 0; i < times; i++ )
  {
    deserialized = Coffee.eval( serialized )
  }
  let csonReadTime = _.time.spent( timeNow );
  readResults.push([ 'cson', csonReadTime, times ]);

  /* Yaml */

  var timeNow = _.time.now();
  var serialized;
  for( var i = 0; i < times; i++ )
  {
    serialized = Yaml.dump( src );
  }
  let yamlWriteTime = _.time.spent( timeNow );
  writeResults.push([ 'yaml', yamlWriteTime, times  ]);

  var timeNow = _.time.now();
  var deserialized;
  for( var i = 0; i < times; i++ )
  {
    deserialized = Yaml.load( serialized )
  }
  let yamlReadTime = _.time.spent( timeNow );
  readResults.push([ 'yaml', yamlReadTime, times  ]);

  /* json.fine */

  var timeNow = _.time.now();
  var serialized;
  for( var i = 0; i < times; i++ )
  {
    serialized = _.cloneData({ src : src });
    serialized = _.toJson( serialized, { cloning : 0 } );
  }
  let jsonFineWriteTime = _.time.spent( timeNow );
  writeResults.push([ 'json.fine', jsonFineWriteTime, times  ]);

  /* json */

  var timeNow = _.time.now();
  var deserialized;
  for( var i = 0; i < times; i++ )
  {
    deserialized = _.jsonParse( serialized );
  }
  let jsonReadTime = _.time.spent( timeNow );
  readResults.push([ 'json', jsonReadTime, times  ]);

  /* json.min */

  var timeNow = _.time.now();
  var serialized;
  for( var i = 0; i < times; i++ )
  {
    serialized = JSON.stringify( src );
  }
  let jsonMinWriteTime = _.time.spent( timeNow );
  writeResults.push([ 'json.min', jsonMinWriteTime, times  ]);

  /* js.structure */

  var timeNow = _.time.now();
  var serialized;
  for( var i = 0; i < times; i++ )
  {
    serialized = _.toJs( src );
  }
  let jsStructureWriteTime = _.time.spent( timeNow );
  writeResults.push([ 'js.structure', jsStructureWriteTime, times  ]);

  var timeNow = _.time.now();
  var deserialized;
  for( var i = 0; i < times; i++ )
  {
    deserialized = _.exec({ code : serialized, prependingReturn : 1 });
  }
  let jsStructureReadTime = _.time.spent( timeNow );
  readResults.push([ 'js.structure', jsStructureReadTime, times  ]);

  /* read results( deserialization ) */

  var o =
  {
    data : readResults,
    head : [ 'read encoder', 'time', 'number of runs' ],
    colWidth : 15
  }

  var output = _.strTable( o );
  console.log( output );

  /* write results( serialization ) */

  var o =
  {
    data : writeResults,
    head : [ 'write encoder', 'time', 'number of runs' ],
    colWidth : 15
  }

  var output = _.strTable( o );
  console.log( output );

}

performance.experimental = 1;

// --
// declare
// --

var Self =
{

  name : 'Tools/mid/files/EncodersExtended',
  silencing : 1,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

  context :
  {
    testSuitePath : null,
    pathFor : pathFor,
    provider : null,
  },

  tests :
  {
    readWriteCson,
    readWriteYaml,
    readWriteBson,
    performance
  },

}

//

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
