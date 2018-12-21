( function _Record_test_s_( ) {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  if( !_global_.wTools.FileProvider )
  require( '../files/UseTop.s' );

  _.include( 'wTesting' );

}

//

var _ = _global_.wTools;
var Parent = wTester;
var testRootDirectory;

//

function onSuiteBegin()
{
  if( Config.platform === 'nodejs' )
  testRootDirectory = _.path.dirTempOpen( _.path.join( __dirname, '../..' ), 'FileRecord' );
  else
  testRootDirectory = _.path.current();
}

//

function onSuiteEnd()
{
  if( Config.platform === 'nodejs' )
  {
    _.assert( _.strEnds( testRootDirectory, 'FileRecord' ) );
    _.path.dirTempClose( testRootDirectory );
  }
}

//

/*
  qqq : split the test routine
*/

function record( test )
{

  var path = '/files/deck/minimal/minimal.coord';
  var r = _.fileProvider.recordFactory().record( path );

  test.identical( r.isDir, false );

  test.identical( r.absolute,path );
  test.identical( r.relative,'./minimal.coord' );

  test.identical( r.ext,'coord' );
  test.identical( r.extWithDot,'.coord' );

  test.identical( r.name,'minimal' );
  test.identical( r.fullName,'minimal.coord' );

  var dir = _.path.normalize( __dirname );
  var fileRecord = _.FileRecord;
  var filePath,got;
  var filter = {}
  var o =
  {
    fileProvider :   _.fileProvider,
    filter : null
  };

  function check( got, path, o )
  {
    path = _.path.normalize( path );
    var name = _.path.name( path );
    var ext = _.path.ext( path );
    var stat = _.fileProvider.statResolvedRead( path );

    test.identical( got.absolute, _.path.normalize( path ) );

    if( o && o.dirPath === path )
    test.identical( got.relative, '.' );
    else
    test.identical( got.relative, './' + name + '.' + ext );

    test.identical( got.ext, ext );
    test.identical( got.extWithDot, '.' + ext );

    test.identical( got.name, name );
    test.identical( got.fullName, name + '.' + ext );

    if( stat )
    test.identical( got.stat.size, stat.size );
    else
    test.identical( got.stat, null );
  }

  //

  test.case = 'dir/relative options';
  var recordContext = _.FileRecordFactory( o, { dirPath : dir } ).form();

  /*absolute path, not exist*/

  var filePath = _.path.join( dir, 'invalid.txt' );
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, true );
  check( got, filePath );

  /*absolute path, terminal file*/

  var filePath = _.path.normalize( __filename );
  var got = recordContext.record({ input : filePath, context : recordContext });
  check( got, filePath );

  /*absolute path, dir*/

  var filePath = _.path.normalize( dir );
  var got = recordContext.record({ input : filePath, context : recordContext });
  check( got, filePath,recordContext );

  /*absolute path, change dir to it root, filePath - dir*/

  var filePath = _.path.normalize( dir );
  var recordContext = _.FileRecordFactory( o, { dirPath : _.path.dir( dir ) } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  check( got, filePath,recordContext );
  test.identical( got.stat.isDir(), true )
  test.identical( got.isDir, true );

  /*relative path without dir/relative options*/

  // filePath = _.path.relative( dir, __filename );
  // var recordContext = _.FileRecordFactory( o, {} );
  // test.shouldThrowErrorSync( function()
  // {
  //   recordContext.record({ input : filePath, context : recordContext });
  // });

  /*relative path with dir option*/

  var filePath = _.path.relative( dir, __filename );
  var recordContext = _.FileRecordFactory( o, { dirPath : dir } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  check( got, __filename,recordContext );

  /*relative path with relative option*/

  var filePath = _.path.relative( dir, __filename );
  var recordContext = _.FileRecordFactory( o, { basePath : dir } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  check( got, __filename,recordContext );

  /*relative path with dir+relative, relative is root of dir*/

  var filePath = _.path.relative( dir, __filename );
  var recordContext = _.FileRecordFactory( o, { dirPath : dir, basePath : _.path.dir( dir ) } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  // test.identical( got.relative, './file.test/Record.test.s' );
  test.identical( got.relative, './' + _.path.relative( _.path.join( __filename, '../..' ) ,__filename ) );
  test.identical( got.stat.isTerminal(), true );

  /*relative option can be any absolute path*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordFactory( o, { basePath : '/X' } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isTerminal(), true );

  /*dir option can be any absolute path*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordFactory( o, { dirPath : '/X' } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isTerminal(), true );

  /*relative option is path to dir on other drive*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordFactory( o, { basePath : 'X:\\x' } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, '../..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isTerminal(), true );

  /*dir option is path to dir on other drive*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordFactory( o, { basePath : 'X:\\x' } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, '../..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isTerminal(), true );


  /*dir path must be absolute*/

  var filePath = __filename;
  test.shouldThrowErrorSync( function()
  {
    record( filePath, { dirPath : 'z.test' } );
  });

  /*relative path must be absolute*/

  var filePath = __filename;
  test.shouldThrowErrorSync( function()
  {
    record( filePath,{ basePath : 'z.test' } );
  });

  //

  test.case = 'filePath absolute dir/relative options'
  var filePath = _.path.normalize( __filename );

  /*dir - path to other disk*/

  var recordContext = _.FileRecordFactory( o, { dirPath : '/X'  } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative - path to other disk*/

  var recordContext = _.FileRecordFactory( o, { basePath : '/X'  } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*dir - path to dir that contains that file*/

  var recordContext = _.FileRecordFactory( o, { dirPath : __dirname  } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, './' + _.path.name({ path : filePath, withExtension : 1 }) );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative - path to dir that contains that file*/

  var recordContext = _.FileRecordFactory( o, { basePath : __dirname  } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, './' + _.path.name({ path : filePath, withExtension : 1 }) );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*dir === filePath */

  var recordContext = _.FileRecordFactory( o, { dirPath : filePath  } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, '.');
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative === filePath */

  var recordContext = _.FileRecordFactory( o, { basePath : filePath  } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, '.');
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ));
  test.identical( _.objectIs( got.stat), true );

  /*dir + relative, affects only on record.relative */

  var recordContext = _.FileRecordFactory( o, { dirPath : '/a', basePath : '/x'  } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ));
  test.identical( _.objectIs( got.stat), true );

  //

  test.case = 'filePath relative dir/relative options'
  var name = _.path.name({ path : _.path.normalize( __filename ), withExtension : 1 });
  var filePath = './' + name;

  //

  /*dir - path to other disk, path exists*/

  _.fileProvider.fieldSet( 'safe', 1 );
  var dirPath = _.path.normalize( __dirname );
  dirPath = dirPath.substr( 0, dirPath.indexOf( '/', 1 ) );
  var recordContext = _.FileRecordFactory( o, { dirPath : dirPath } ).form();
  test.shouldThrowError( () => record( '/',recordContext ) );
  _.fileProvider.fieldSet( 'safe', 1 );

  /*dir - path to other disk, path doesn't exist*/

  _.fileProvider.fieldSet( 'safe', 1 );
  var recordContext = _.FileRecordFactory( o, { dirPath : '/X' } ).form();
  test.mustNotThrowError( () => recordContext.record({ input : filePath, context : recordContext }) );
  _.fileProvider.fieldSet( 'safe', 1 );

  /*relative - path to other disk*/

  _.fileProvider.fieldSet( 'safe', 0 );
  var recordContext = _.FileRecordFactory( o, { basePath : '/X' } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.join( recordContext.basePath, name ) );
  test.identical( got.real, _.path.join( recordContext.basePath, name ) );
  test.identical( got.dir, recordContext.basePath );
  test.identical( got.stat, null );
  _.fileProvider.fieldReset( 'safe', 0 );

  /*dir - path to dir with file*/

  var recordContext = _.FileRecordFactory( o, { dirPath : __dirname } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.join( recordContext.dirPath, name ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordContext.dirPath );
  test.identical( _.objectIs( got.stat ), true );

  /*relative - path to dir with file*/

  var recordContext = _.FileRecordFactory( o, { basePath : __dirname } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.join( recordContext.basePath, name ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordContext.basePath );
  test.identical( _.objectIs( got.stat ), true );

  /*dir === filePath*/

  var recordContext = _.FileRecordFactory( o, { dirPath : __filename } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.join( recordContext.dirPath, name ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordContext.dirPath );
  test.identical( got.stat, null );

  /*relative === filePath*/

  var recordContext = _.FileRecordFactory( o, { basePath : __filename } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.join( recordContext.basePath, name ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordContext.basePath );
  test.identical( got.stat, null );

  /*dir+relative, relative affects only record.relative, dir affects on record.absolute,record.real*/

  _.fileProvider.fieldSet( 'safe', 0 );
  var recordContext = _.FileRecordFactory( o, { dirPath : '/x', basePath : '/a' } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.relative, '..' + _.path.join( recordContext.dirPath, name ) );
  test.identical( got.absolute, _.path.join( recordContext.dirPath, name ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordContext.dirPath );
  test.identical( got.stat, null );
  _.fileProvider.fieldReset( 'safe', 0 );

  /* softlink, resolvingSoftLink  1 */

  // _.fileProvider.fieldSet( 'resolvingSoftLink', 1 );
  // var src = _.path.join( testRootDirectory, 'src' );
  // var dst = _.path.join( testRootDirectory, 'dst' );
  // _.fileProvider.fileWrite( src, 'src' );
  // _.fileProvider.softLink( dst, src );
  // var got = _.fileProvider.recordFactory().record( dst );
  // test.identical( got.absolute, dst );
  // test.identical( got.real, src );
  // _.fileProvider.fieldReset( 'resolvingSoftLink', 1 );

  /* softlink, resolvingSoftLink  0 */

  _.fileProvider.fieldSet( 'resolvingSoftLink', 0 );
  var src = _.path.join( testRootDirectory, 'src' );
  var dst = _.path.join( testRootDirectory, 'dst' );
  _.fileProvider.fileWrite( src, 'src' );
  _.fileProvider.softLink( dst, src );
  var got = _.fileProvider.recordFactory().record( dst );
  test.identical( got.absolute, dst );
  test.identical( got.real, dst );
  _.fileProvider.fieldReset( 'resolvingSoftLink', 0 );

  //

  test.case = 'onRecord';

  /* */

  function _onRecord( record )
  {
    test.identical( record.name, _.path.name( filePath ) );
  }
  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordFactory( o, { dirPath : dir, onRecord : _onRecord} ).form();
  recordContext.record({ input : filePath, context : recordContext });

  //

  test.case = 'etc';

  /*strict mode on by default, record is not extensible*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordFactory( o, { dirPath : _.path.dir( filePath ) } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.shouldThrowErrorSync( function()
  {
    got.newProperty = 1;
  });

  /*strict mode off*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordFactory( o, { dirPath : _.path.dir( filePath ), strict : 0 } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.mustNotThrowError( function()
  {
    got.newProperty = 1;
    test.identical( got.newProperty, 1 );
  });

  //

  if( !Config.debug )
  return;

  test.shouldThrowError( () =>
  {
    _.FileRecordFactory( o, {} ).form();
  })
}

//

function filtering( test )
{
  var dir = _.path.normalize( __dirname );
  var fileRecord = _.FileRecord;
  var filePath,got;
  var filter = {}
  var o =
  {
    fileProvider :   _.fileProvider,
    filter : null
  };

  test.case = 'masking';
  var filePath = _.path.normalize( __filename );

  function makeFilter( o )
  {
    _.mapSupplement( o, { hubFileProvider : _.fileProvider } );

    var f = _.FileRecordFilter( o );
    f.form();
    return f;
  }

  /*maskAll#1*/

  var mask = _.RegexpObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskAll : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, false );

  var mask = _.RegexpObject( '.', 'includeAny' );
  var filter = makeFilter({  maskAll : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, true );

  /*maskAll#2*/

  var mask = _.RegexpObject( 'Abc', 'includeAny' );
  var filter = makeFilter({  maskAll : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, false );

  /*maskTerminal*/

  var mask = _.RegexpObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskTerminal : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, false );

  var mask = _.RegexpObject( '.', 'includeAny' );
  var filter = makeFilter({  maskAll : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, true );

  /*maskTerminal, filePath is not terminal*/

  var filePath = _.path.normalize( dir );
  var mask = _.RegexpObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskTerminal : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, true );

  /*maskDirectory, filePath is dir*/

  var filePath = _.path.normalize( dir );
  var mask = _.RegexpObject( 'test', 'includeAny' );
  var filter = makeFilter({  maskDirectory : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, false );

  var filePath = _.path.normalize( dir );
  var mask = _.RegexpObject( '.', 'includeAny' );
  var filter = makeFilter({  maskDirectory : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, true );

  /*maskDirectory, filePath is dir*/

  var filePath = _.path.normalize( dir );
  var mask = _.RegexpObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskDirectory : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, false );

  /*maskDirectory, filePath is terminal*/

  var filePath = _.path.normalize( __filename );
  var mask = _.RegexpObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskDirectory : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, true );

  //

  test.case = 'notOlder/notNewer';

  /*notOlder*/

  var filePath = _.path.normalize( __filename );
  var filter = makeFilter({ notOlder : new Date( Date.UTC( 1900, 1, 1 ) ), basePath : filePath, inFilePath : filePath })
  debugger
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath  }).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  console.log( got.mtime )
  test.identical( got.isActual, true );

  /*notNewer*/

  var filePath = _.path.normalize( __filename );
  var filter = makeFilter({ notNewer : new Date( Date.UTC( 1900, 1, 1 ) ), basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath  }).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, false );

  /* notOlderAge */

  var filePath = _.path.normalize( __filename );
  var filter = makeFilter({ notOlderAge : new Date( Date.UTC( 1970, 1, 1 ) ), basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath  }).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, true );

  /* notNewerAge */

  var filePath = _.path.normalize( __filename );
  var filter = makeFilter({ notNewerAge : new Date( Date.UTC( 1970, 1, 1 ) ), basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : filePath  }).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, false );

  test.case = 'both not* and mask* are used';

  var filePath = _.path.normalize( __filename );
  var maskTerminal = _.RegexpObject( /.*\.test\.s/, 'includeAny' );
  var filter = makeFilter
  ({
    maskTerminal : maskTerminal,
    notOlder : new Date( Date.UTC( 1970, 1, 1 ) ),
    inFilePath : _.path.dir( filePath )
  })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : _.path.dir( filePath ) }).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, true );

  /* notNewer check gives false, maskTerminal will be ignored */

  var filePath = _.path.normalize( __filename );
  var maskTerminal = _.RegexpObject( /.*\.test\.s/, 'includeAny' );
  var filter = makeFilter
  ({
    maskTerminal : maskTerminal,
    notNewer : new Date( Date.UTC( 1900, 1, 1 ) ),
    inFilePath : _.path.dir( filePath )
  })
  var recordContext = _.FileRecordFactory( o, { filter : filter, basePath : _.path.dir( filePath )  }).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.identical( got.isActual, false );

  //

  test.case = 'onRecord';

  /* */

  function _onRecord( record )
  {
    test.identical( record.name, _.path.name( filePath ) );
  }
  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordFactory( o, { dirPath : dir, onRecord : _onRecord} ).form();
  recordContext.record({ input : filePath, context : recordContext });

  //

  test.case = 'etc';

  /*strict mode on by default, record is not extensible*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordFactory( o, { dirPath : _.path.dir( filePath ) } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.shouldThrowErrorSync( function()
  {
    got.newProperty = 1;
  });

  /*strict mode off*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordFactory( o, { dirPath : _.path.dir( filePath ), strict : 0 } ).form();
  var got = recordContext.record({ input : filePath, context : recordContext });
  test.mustNotThrowError( function()
  {
    got.newProperty = 1;
    test.identical( got.newProperty, 1 );
  });

  //

  if( !Config.debug )
  return;

  test.shouldThrowError( () =>
  {
    _.FileRecordFactory( o, {} ).form();
  })
}

//

function recordForLink( test )
{
  let self = this;

  let dir = _.path.join( testRootDirectory, test.name );
  let o =
  {
    fileProvider : _.fileProvider,
    basePath : dir
  }
  let pathToMissing = _.path.join( dir, 'missing' );
  let pathTerminal = _.path.join( dir, 'terminal' );
  let pathToDir = _.path.join( dir, 'directory' );
  let pathLinkToMissing = _.path.join( dir, 'linkToMissing' );
  let pathLinkToTerminal = _.path.join( dir, 'linkToTerminal' );
  let pathLinkToDir = _.path.join( dir, 'pathLinkToDir' );
  let pathLinkToLinkToTerminal = _.path.join( dir, 'pathLinkToLinkToTerminal' );
  let pathLinkToLinkToDir = _.path.join( dir, 'pathLinkToLinkToDir' );
  let pathLinkToLinkToMissing = _.path.join( dir, 'pathLinkToLinkToMissing' );

  _.fileProvider.filesDelete( dir );
  _.fileProvider.fileWrite( pathTerminal, pathTerminal );
  _.fileProvider.dirMake( pathToDir );
  _.fileProvider.softLink( pathLinkToTerminal, pathTerminal );
  _.fileProvider.softLink( pathLinkToDir, pathToDir );
  _.fileProvider.softLink( pathLinkToLinkToTerminal, pathLinkToTerminal );
  _.fileProvider.softLink( pathLinkToLinkToDir, pathLinkToDir );
  _.fileProvider.softLink({ dstPath : pathLinkToMissing, srcPath : pathToMissing, allowingMissed : 1 });
  _.fileProvider.softLink({ dstPath : pathLinkToLinkToMissing, srcPath : pathLinkToMissing, allowingMissed : 1 });

  test.case = 'link to missing';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 0 }).form();
  var record = recordContext.record( pathLinkToMissing );
  test.identical( record.absolute, pathLinkToMissing );
  test.identical( record.real, pathLinkToMissing );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkToMissing );
  test.identical( record.absolute, pathLinkToMissing );
  test.identical( record.real, pathLinkToMissing );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 0 }).form();
  test.shouldThrowError( () => { recordContext.record( pathLinkToMissing ) } );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkToMissing );
  test.identical( record.absolute, pathLinkToMissing );
  test.identical( record.real, null /* qqq : can real contain path to not existing file */ );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );
  test.identical( record.stat, null );

  test.case = 'link to link to missing';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 0 }).form();
  var record = recordContext.record( pathLinkToLinkToMissing );
  test.identical( record.absolute, pathLinkToLinkToMissing );
  test.identical( record.real, pathLinkToLinkToMissing );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkToLinkToMissing );
  test.identical( record.absolute, pathLinkToLinkToMissing );
  test.identical( record.real, pathLinkToLinkToMissing );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 0 }).form();
  test.shouldThrowError( () => { recordContext.record( pathLinkToLinkToMissing ) } );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkToLinkToMissing );
  test.identical( record.absolute, pathLinkToLinkToMissing );
  test.identical( record.real, null /* qqq : can real contain path to not existing file */ );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );
  test.identical( record.stat, null );

  test.case = 'link to terminal';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkToTerminal );
  test.identical( record.absolute, pathLinkToTerminal );
  test.identical( record.real, pathLinkToTerminal );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkToTerminal );
  test.identical( record.absolute, pathLinkToTerminal );
  test.identical( record.real, pathTerminal );
  test.is( !record.isSoftLink );
  debugger
  test.is( record.isTerminal );

  test.case = 'link to directory';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkToDir );
  test.identical( record.absolute, pathLinkToDir );
  test.identical( record.real, pathLinkToDir );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkToDir );
  test.identical( record.absolute, pathLinkToDir );
  test.identical( record.real, pathToDir );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( record.isDir );

  test.case = 'link - link - terminal';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkToLinkToTerminal );
  test.identical( record.absolute, pathLinkToLinkToTerminal );
  test.identical( record.real, pathLinkToLinkToTerminal );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkToLinkToTerminal );
  test.identical( record.absolute, pathLinkToLinkToTerminal );
  test.identical( record.real, pathTerminal );
  test.is( !record.isSoftLink );
  test.is( record.isTerminal );

  test.case = 'link - link - directory';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkToLinkToDir );
  test.identical( record.absolute, pathLinkToLinkToDir );
  test.identical( record.real, pathLinkToLinkToDir );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkToLinkToDir );
  test.identical( record.absolute, pathLinkToLinkToDir );
  test.identical( record.real, pathToDir );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( record.isDir );

  test.case = 'self cycled';

  var pathSelfCycled = _.path.join( dir, 'pathSelfCycled' );
  _.fileProvider.softLink({ dstPath : pathSelfCycled, srcPath : pathSelfCycled, allowingMissed : 1 });

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 0 }).form();
  var record = recordContext.record( pathSelfCycled );
  test.identical( record.absolute, pathSelfCycled );
  test.identical( record.real, pathSelfCycled );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 1 }).form();
  var record = recordContext.record( pathSelfCycled );
  test.identical( record.absolute, pathSelfCycled );
  test.identical( record.real, pathSelfCycled );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 0 }).form();
  test.shouldThrowError( () => { recordContext.record( pathSelfCycled ) } );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 1 }).form();
  var record = recordContext.record( pathSelfCycled );
  test.identical( record.absolute, pathSelfCycled );
  test.identical( record.real, pathSelfCycled );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  test.case = 'cycled';

  var pathA = _.path.join( dir, 'pathA' );
  var pathB = _.path.join( dir, 'pathB' );
  _.fileProvider.softLink({ dstPath : pathA, srcPath : pathB, allowingMissed : 1 });
  _.fileProvider.softLink({ dstPath : pathB, srcPath : pathA, allowingMissed : 1 });

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 0 }).form();
  var record = recordContext.record( pathA );
  test.identical( record.absolute, pathA );
  test.identical( record.real, pathA );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 1 }).form();
  var record = recordContext.record( pathA );
  test.identical( record.absolute, pathA );
  test.identical( record.real, pathA );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 0 }).form();
  test.shouldThrowError( () => { recordContext.record( pathSelfCycled ) } );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 1 }).form();
  var record = recordContext.record( pathA );
  test.identical( record.absolute, pathA );
  test.identical( record.real, pathB );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

}

//

function recordForRelativeLink( test )
{
  let self = this;

  let dir = _.path.join( testRootDirectory, test.name );
  let o =
  {
    fileProvider : _.fileProvider,
    basePath : dir
  }
  let pathToMissing = _.path.join( dir, 'missing' );
  let pathTerminal = _.path.join( dir, 'terminal' );
  let pathToDir = _.path.join( dir, 'directory' );
  let pathLinkToMissing = _.path.join( dir, 'linkToMissing' );
  let pathLinkToTerminal = _.path.join( dir, 'linkToTerminal' );
  let pathLinkToDir = _.path.join( dir, 'pathLinkToDir' );
  let pathLinkToLinkToTerminal = _.path.join( dir, 'pathLinkToLinkToTerminal' );
  let pathLinkToLinkToDir = _.path.join( dir, 'pathLinkToLinkToDir' );
  let pathLinkToLinkToMissing = _.path.join( dir, 'pathLinkToLinkToMissing' );

  /* */

  _.fileProvider.filesDelete( dir );
  _.fileProvider.fileWrite( pathTerminal, pathTerminal );
  _.fileProvider.dirMake( pathToDir );
  _.fileProvider.softLink( pathLinkToTerminal, _.path.relative( pathLinkToTerminal, pathTerminal ) );
  _.fileProvider.softLink( pathLinkToDir, _.path.relative( pathLinkToDir, pathToDir ) );
  _.fileProvider.softLink( pathLinkToLinkToTerminal, _.path.relative( pathLinkToLinkToTerminal, pathLinkToTerminal ) );
  _.fileProvider.softLink( pathLinkToLinkToDir, _.path.relative( pathLinkToLinkToDir, pathLinkToDir ) );
  _.fileProvider.softLink({ dstPath : pathLinkToMissing, srcPath : _.path.relative( pathLinkToMissing, pathToMissing ), allowingMissed : 1 });
  _.fileProvider.softLink({ dstPath : pathLinkToLinkToMissing, srcPath : _.path.relative( pathLinkToLinkToMissing, pathLinkToMissing ), allowingMissed : 1 });

  test.case = 'link to missing';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 0 }).form();
  var record = recordContext.record( pathLinkToMissing );
  test.identical( record.absolute, pathLinkToMissing );
  test.identical( record.real, pathLinkToMissing );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkToMissing );
  test.identical( record.absolute, pathLinkToMissing );
  test.identical( record.real, pathLinkToMissing );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 0 }).form();
  test.shouldThrowError( () => { recordContext.record( pathLinkToMissing ) } );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkToMissing );
  test.identical( record.absolute, pathLinkToMissing );
  test.identical( record.real, null /* qqq : can real contain path to not existing file */ );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );
  test.identical( record.stat, null );

  test.case = 'link relative - link relative to missing';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 0 }).form();
  var record = recordContext.record( pathLinkToLinkToMissing );
  test.identical( record.absolute, pathLinkToLinkToMissing );
  test.identical( record.real, pathLinkToLinkToMissing );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkToLinkToMissing );
  test.identical( record.absolute, pathLinkToLinkToMissing );
  test.identical( record.real, pathLinkToLinkToMissing );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 0 }).form();
  test.shouldThrowError( () => { recordContext.record( pathLinkToLinkToMissing ) } );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkToLinkToMissing );
  test.identical( record.absolute, pathLinkToLinkToMissing );
  test.identical( record.real, null /* qqq : can real contain path to not existing file */ );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );
  test.identical( record.stat, null );

  test.case = 'link to terminal';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkToTerminal );
  test.identical( record.absolute, pathLinkToTerminal );
  test.identical( record.real, pathLinkToTerminal );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkToTerminal );
  test.identical( record.absolute, pathLinkToTerminal );
  test.identical( record.real, pathTerminal );
  test.is( !record.isSoftLink );
  test.is( record.isTerminal );

  test.case = 'link to directory';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkToDir );
  test.identical( record.absolute, pathLinkToDir );
  test.identical( record.real, pathLinkToDir );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkToDir );
  test.identical( record.absolute, pathLinkToDir );
  test.identical( record.real, pathToDir );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( record.isDir );

  test.case = 'link relative - link relative - terminal';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkToLinkToTerminal );
  test.identical( record.absolute, pathLinkToLinkToTerminal );
  test.identical( record.real, pathLinkToLinkToTerminal );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkToLinkToTerminal );
  test.identical( record.absolute, pathLinkToLinkToTerminal );
  test.identical( record.real, pathTerminal );
  test.is( !record.isSoftLink );
  test.is( record.isTerminal );

  test.case = 'link relative - link relative - directory';

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkToLinkToDir );
  test.identical( record.absolute, pathLinkToLinkToDir );
  test.identical( record.real, pathLinkToLinkToDir );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkToLinkToDir );
  test.identical( record.absolute, pathLinkToLinkToDir );
  test.identical( record.real, pathToDir );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( record.isDir );

  test.case = 'link absolute - link relative - missing';

  var pathLinkAbsolute = _.path.join( dir, 'pathLinkAbsolute' );
  var pathLinkRelative = _.path.join( dir, 'pathLinkRelative' );
  _.fileProvider.softLink({ dstPath : pathLinkRelative, srcPath : _.path.resolve( pathLinkRelative, pathToMissing ), allowingMissed : 1 });
  _.fileProvider.softLink( pathLinkAbsolute, pathLinkRelative );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 0 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathLinkAbsolute );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathLinkAbsolute );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 0 }).form();
  test.shouldThrowError( () => { recordContext.record( pathLinkAbsolute ) } );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, null /* qqq : can real contain path to not existing file */ );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );
  test.identical( record.stat, null );

  test.case = 'link absolute - link relative - terminal';

  var pathLinkAbsolute = _.path.join( dir, 'pathLinkAbsolute' );
  var pathLinkRelative = _.path.join( dir, 'pathLinkRelative' );
  _.fileProvider.softLink( pathLinkRelative, _.path.resolve( pathLinkRelative, pathTerminal ) );
  _.fileProvider.softLink( pathLinkAbsolute, pathLinkRelative );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathLinkAbsolute );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathTerminal );
  test.is( !record.isSoftLink );
  test.is( record.isTerminal );
  test.is( !record.isDir );

  test.case = 'link absolute - link relative - directory';

  var pathLinkAbsolute = _.path.join( dir, 'pathLinkAbsolute' );
  var pathLinkRelative = _.path.join( dir, 'pathLinkRelative' );
  _.fileProvider.softLink( pathLinkRelative, _.path.resolve( pathLinkRelative, pathToDir ) );
  _.fileProvider.softLink( pathLinkAbsolute, pathLinkRelative );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathLinkAbsolute );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathToDir );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( record.isDir );

  test.case = 'link relative - link absolute - missing';

  var pathLinkAbsolute = _.path.join( dir, 'pathLinkAbsolute' );
  var pathLinkRelative = _.path.join( dir, 'pathLinkRelative' );
  _.fileProvider.softLink({ dstPath : pathLinkAbsolute, srcPath : pathToMissing, allowingMissed : 1 });
  _.fileProvider.softLink( pathLinkRelative, _.path.relative( pathLinkRelative, pathLinkAbsolute ) );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 0 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathLinkAbsolute );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathLinkAbsolute );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 0 }).form();
  test.shouldThrowError( () => { recordContext.record( pathLinkAbsolute ) } );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 1 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, null /* qqq : can real contain path to not existing file */ );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );
  test.identical( record.stat, null );

  test.case = 'link relative - link absolute - terminal';

  var pathLinkAbsolute = _.path.join( dir, 'pathLinkAbsolute' );
  var pathLinkRelative = _.path.join( dir, 'pathLinkRelative' );
  _.fileProvider.softLink( pathLinkAbsolute, pathTerminal );
  _.fileProvider.softLink( pathLinkRelative, _.path.relative( pathLinkRelative, pathLinkAbsolute ) );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathLinkAbsolute );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathTerminal );
  test.is( !record.isSoftLink );
  test.is( record.isTerminal );
  test.is( !record.isDir );

  test.case = 'link absolute - link relative - directory';

  var pathLinkAbsolute = _.path.join( dir, 'pathLinkAbsolute' );
  var pathLinkRelative = _.path.join( dir, 'pathLinkRelative' );
  _.fileProvider.softLink( pathLinkAbsolute, pathToDir );
  _.fileProvider.softLink( pathLinkRelative, _.path.relative( pathLinkRelative, pathLinkAbsolute ) );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathLinkAbsolute );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( !record.isDir );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1 }).form();
  var record = recordContext.record( pathLinkAbsolute );
  test.identical( record.absolute, pathLinkAbsolute );
  test.identical( record.real, pathToDir );
  test.is( !record.isSoftLink );
  test.is( !record.isTerminal );
  test.is( record.isDir );

  test.case = 'self cycled';

  var pathSelfCycled = _.path.join( dir, 'pathSelfCycled' );
  _.fileProvider.softLink({ dstPath : pathSelfCycled, srcPath : '../pathSelfCycled', allowingMissed : 1 });

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 0 }).form();
  var record = recordContext.record( pathSelfCycled );
  test.identical( record.absolute, pathSelfCycled );
  test.identical( record.real, pathSelfCycled );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 1 }).form();
  var record = recordContext.record( pathSelfCycled );
  test.identical( record.absolute, pathSelfCycled );
  test.identical( record.real, pathSelfCycled );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 0 }).form();
  test.shouldThrowError( () => { recordContext.record( pathSelfCycled ) } );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 1 }).form();
  var record = recordContext.record( pathSelfCycled );
  test.identical( record.absolute, pathSelfCycled );
  test.identical( record.real, pathSelfCycled );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  test.case = 'cycled';

  var pathA = _.path.join( dir, 'pathA' );
  var pathB = _.path.join( dir, 'pathB' );
  _.fileProvider.softLink({ dstPath : pathA, srcPath : _.path.relative( pathA, pathB ), allowingMissed : 1 });
  _.fileProvider.softLink({ dstPath : pathB, srcPath : _.path.relative( pathB, pathA ), allowingMissed : 1 });

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 0 }).form();
  var record = recordContext.record( pathA );
  test.identical( record.absolute, pathA );
  test.identical( record.real, pathA );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 0, allowingMissed : 1 }).form();
  var record = recordContext.record( pathA );
  test.identical( record.absolute, pathA );
  test.identical( record.real, pathA );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 0 }).form();
  test.shouldThrowError( () => { recordContext.record( pathSelfCycled ) } );

  var recordContext = _.FileRecordFactory( o, { resolvingSoftLink : 1, allowingMissed : 1 }).form();
  var record = recordContext.record( pathA );
  test.identical( record.absolute, pathA );
  test.identical( record.real, pathB );
  test.is( record.isSoftLink );
  test.is( !record.isTerminal );

}

// --
// proto
// --

var Self =
{

  name : 'Tools/mid/files/Record',
  silencing : 1,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

  tests :
  {

    record : record,
    filtering : filtering,
    recordForLink : recordForLink,
    recordForRelativeLink : recordForRelativeLink

  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
