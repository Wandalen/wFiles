( function _Record_test_s_( ) {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }


  var _ = _global_.wTools;

  if( !_global_.wTools.FileProvider )
  require( '../files/UseTop.s' );

  _.include( 'wTesting' );

}

//

var _ = _global_.wTools;
var Parent = _.Tester;
var testRootDirectory;

//

function onSuiteBegin()
{
  if( !isBrowser )
  testRootDirectory = _.path.dirTempMake( _.path.pathJoin( __dirname, '../..' ) );
  else
  testRootDirectory = _.path.pathCurrent();
}

//

function onSuiteEnd()
{
  _.fileProvider.filesDelete( testRootDirectory );
}

//

function fileRecord( test )
{
  var path = '/files/deck/minimal/minimal.coord';

  debugger;
  var r = _.fileProvider.fileRecord( path );

  test.identical( r._isDir(), false );

  test.identical( r.absolute,path );
  test.identical( r.relative,'./minimal.coord' );

  test.identical( r.ext,'coord' );
  test.identical( r.extWithDot,'.coord' );

  test.identical( r.name,'minimal' );
  test.identical( r.nameWithExt,'minimal.coord' );

  //

  var dir = _.path.pathNormalize( __dirname );
  var fileRecord = _.FileRecord;
  var filePath,got;
  var filter = _.FileRecordFilter({ fileProvider :  _.fileProvider }).form()
  var o =
  {
    fileProvider :   _.fileProvider,
    filter : filter
  };

  function check( got, path, o )
  {
    path = _.path.pathNormalize( path );
    var pathName = _.path.pathName( path );
    var ext = _.path.pathExt( path );
    var stat = _.fileProvider.fileStat( path );

    test.identical( got.absolute, _.path.pathNormalize( path ) );

    if( o && o.dir === path )
    test.identical( got.relative, '.' );
    else
    test.identical( got.relative, './' + pathName + '.' + ext );

    test.identical( got.ext, ext );
    test.identical( got.extWithDot, '.' + ext );

    test.identical( got.name, pathName );
    test.identical( got.nameWithExt, pathName + '.' + ext );

    if( stat )
    test.identical( got.stat.size, stat.size );
    else
    test.identical( got.stat, null );
  }

  //

  test.case = 'dir/relative options';
  debugger
  var recordOptions = _.FileRecordContext( o, { dir : dir } );

  /*absolute path, not exist*/

  var filePath = _.path.pathJoin( dir, 'invalid.txt' );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );
  check( got, filePath );

  /*absolute path, terminal file*/

  var filePath = _.path.pathNormalize( __filename );
  var got = fileRecord( filePath,recordOptions );
  check( got, filePath );

  /*absolute path, dir*/

  var filePath = _.path.pathNormalize( dir );
  var got = fileRecord( filePath,recordOptions );
  check( got, filePath,recordOptions );

  /*absolute path, change dir to it root, filePath - dir*/

  var filePath = _.path.pathNormalize( dir );
  var recordOptions = _.FileRecordContext( o, { dir : _.path.pathDir( dir ) } );
  var got = fileRecord( filePath,recordOptions );
  check( got, filePath,recordOptions );
  test.identical( got.stat.isDirectory(), true )
  test.identical( got._isDir(), true );

  /*relative path without dir/relative options*/

  // filePath = _.path.pathRelative( dir, __filename );
  // var recordOptions = _.FileRecordContext( o, {} );
  // test.shouldThrowErrorSync( function()
  // {
  //   fileRecord( filePath, recordOptions );
  // });

  /*relative path with dir option*/

  var filePath = _.path.pathRelative( dir, __filename );
  var recordOptions = _.FileRecordContext( o, { dir : dir } );
  var got = fileRecord( filePath,recordOptions );
  check( got, __filename,recordOptions );

  /*relative path with relative option*/

  var filePath = _.path.pathRelative( dir, __filename );
  var recordOptions = _.FileRecordContext( o, { basePath : dir } );
  var got = fileRecord( filePath,recordOptions );
  check( got, __filename,recordOptions );

  /*relative path with dir+relative, relative is root of dir*/

  var filePath = _.path.pathRelative( dir, __filename );
  var recordOptions = _.FileRecordContext( o, { dir : dir, basePath : _.path.pathDir( dir ) } );
  var got = fileRecord( filePath,recordOptions );
  // test.identical( got.relative, './file.test/Record.test.s' );
  test.identical( got.relative, './' + _.path.pathRelative( _.path.pathJoin( __filename, '../..' ) ,__filename ) );
  test.identical( got.stat.isFile(), true );

  /*relative option can be any absolute path*/

  var filePath = _.path.pathNormalize( __filename );
  var recordOptions = _.FileRecordContext( o, { basePath : '/X' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*dir option can be any absolute path*/

  var filePath = _.path.pathNormalize( __filename );
  var recordOptions = _.FileRecordContext( o, { dir : '/X' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*relative option is path to dir on other drive*/

  var filePath = _.path.pathNormalize( __filename );
  var recordOptions = _.FileRecordContext( o, { basePath : 'X:\\x' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '../..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*dir option is path to dir on other drive*/

  var filePath = _.path.pathNormalize( __filename );
  var recordOptions = _.FileRecordContext( o, { basePath : 'X:\\x' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '../..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );


  /*dir path must be absolute*/

  var filePath = __filename;
  test.shouldThrowErrorSync( function()
  {
    fileRecord( filePath, { dir : 'z.test' } );
  });

  /*relative path must be absolute*/

  var filePath = __filename;
  test.shouldThrowErrorSync( function()
  {
    fileRecord( filePath,{ basePath : 'z.test' } );
  });

  //

  test.case = 'filePath absolute dir/relative options'
  var filePath = _.path.pathNormalize( __filename );

  /*dir - path to other disk*/

  var recordOptions = _.FileRecordContext( o, { dir : '/X'  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.pathNormalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative - path to other disk*/

  var recordOptions = _.FileRecordContext( o, { basePath : '/X'  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.pathNormalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*dir - path to dir that contains that file*/

  var recordOptions = _.FileRecordContext( o, { dir : __dirname  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, './' + _.path.pathName({ path : filePath, withExtension : 1 }) );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.pathNormalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative - path to dir that contains that file*/

  var recordOptions = _.FileRecordContext( o, { basePath : __dirname  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, './' + _.path.pathName({ path : filePath, withExtension : 1 }) );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.pathNormalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*dir === filePath */

  var recordOptions = _.FileRecordContext( o, { dir : filePath  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '.');
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.pathNormalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative === filePath */

  var recordOptions = _.FileRecordContext( o, { basePath : filePath  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '.');
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.pathNormalize( __dirname ));
  test.identical( _.objectIs( got.stat), true );

  /*dir + relative, affects only on record.relative */

  var recordOptions = _.FileRecordContext( o, { dir : '/a', basePath : '/x'  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.pathNormalize( __dirname ));
  test.identical( _.objectIs( got.stat), true );

  //

  test.case = 'filePath relative dir/relative options'
  var pathName = _.path.pathName({ path : _.path.pathNormalize( __filename ), withExtension : 1 });
  var filePath = './' + pathName;

  //

  /*dir - path to other disk, path exists*/

  _.fileProvider.fieldSet( 'safe', 1 );
  var dirPath = _.path.pathNormalize( __dirname );
  dirPath = dirPath.substr( 0, dirPath.indexOf( '/', 1 ) );
  var recordOptions = _.FileRecordContext( o, { dir : dirPath } );
  test.shouldThrowError( () => fileRecord( '/',recordOptions ) );
  _.fileProvider.fieldSet( 'safe', 1 );

  /*dir - path to other disk, path doesn't exist*/

  _.fileProvider.fieldSet( 'safe', 1 );
  var recordOptions = _.FileRecordContext( o, { dir : '/X' } );
  test.mustNotThrowError( () => fileRecord( filePath,recordOptions ) );
  _.fileProvider.fieldSet( 'safe', 1 );

  /*relative - path to other disk*/

  _.fileProvider.fieldSet( 'safe', 0 );
  var recordOptions = _.FileRecordContext( o, { basePath : '/X' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.pathJoin( recordOptions.basePath, pathName ) );
  test.identical( got.real, _.path.pathJoin( recordOptions.basePath, pathName ) );
  test.identical( got.dir, recordOptions.basePath );
  test.identical( got.stat, null );
  _.fileProvider.fieldReset( 'safe', 0 );

  /*dir - path to dir with file*/

  var recordOptions = _.FileRecordContext( o, { dir : __dirname } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.dir );
  test.identical( _.objectIs( got.stat ), true );

  /*relative - path to dir with file*/

  var recordOptions = _.FileRecordContext( o, { basePath : __dirname } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.pathJoin( recordOptions.basePath, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.basePath );
  test.identical( _.objectIs( got.stat ), true );

  /*dir === filePath*/

  var recordOptions = _.FileRecordContext( o, { dir : __filename } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.dir );
  test.identical( got.stat, null );

  /*relative === filePath*/

  var recordOptions = _.FileRecordContext( o, { basePath : __filename } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.pathJoin( recordOptions.basePath, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.basePath );
  test.identical( got.stat, null );

  /*dir+relative, relative affects only record.relative, dir affects on record.absolute,record.real*/

  _.fileProvider.fieldSet( 'safe', 0 );
  var recordOptions = _.FileRecordContext( o, { dir : '/x', basePath : '/a' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + _.path.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.absolute, _.path.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.dir );
  test.identical( got.stat, null );
  _.fileProvider.fieldReset( 'safe', 0 );

  /* softlink, resolvingSoftLink  1 */

  // _.fileProvider.fieldSet( 'resolvingSoftLink', 1 );
  // var pathSrc = _.path.pathJoin( testRootDirectory, 'src' );
  // var pathDst = _.path.pathJoin( testRootDirectory, 'dst' );
  // _.fileProvider.fileWrite( pathSrc, 'src' );
  // _.fileProvider.linkSoft( pathDst, pathSrc );
  // var got = _.fileProvider.fileRecord( pathDst );
  // test.identical( got.absolute, pathDst );
  // test.identical( got.real, pathSrc );
  // _.fileProvider.fieldReset( 'resolvingSoftLink', 1 );

  /* softlink, resolvingSoftLink  0 */

  _.fileProvider.fieldSet( 'resolvingSoftLink', 0 );
  var pathSrc = _.path.pathJoin( testRootDirectory, 'src' );
  var pathDst = _.path.pathJoin( testRootDirectory, 'dst' );
  _.fileProvider.fileWrite( pathSrc, 'src' );
  _.fileProvider.linkSoft( pathDst, pathSrc );
  var got = _.fileProvider.fileRecord( pathDst );
  test.identical( got.absolute, pathDst );
  test.identical( got.real, pathDst );
  _.fileProvider.fieldReset( 'resolvingSoftLink', 0 );

  //

  test.case = 'masking';
  var filePath = _.path.pathNormalize( __filename );

  function makeFilter( o )
  {
    _.mapSupplement( o, { fileProvider : _.fileProvider } );
    var f = _.FileRecordFilter( o );
    f.form();
    return f;
  }

  /*maskAll#1*/

  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskAll : mask })
  var recordOptions = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  /*maskAll#2*/

  var mask = _.regexpMakeObject( 'Abc', 'includeAny' );
  var filter = makeFilter({  maskAll : mask })
  var recordOptions = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  /*maskTerminal*/

  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskTerminal : mask })
  var recordOptions = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  /*maskTerminal, filePath is not terminal*/

  var filePath = _.path.pathNormalize( dir );
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskTerminal : mask })
  var recordOptions = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  /*maskDir, filePath is dir*/

  var filePath = _.path.pathNormalize( dir );
  var mask = _.regexpMakeObject( 'test', 'includeAny' );
  var filter = makeFilter({  maskDir : mask })
  var recordOptions = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  /*maskDir, filePath is dir*/

  var filePath = _.path.pathNormalize( dir );
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskDir : mask })
  var recordOptions = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  /*maskDir, filePath is terminal*/

  var filePath = _.path.pathNormalize( __filename );
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskDir : mask })
  var recordOptions = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  //

  test.case = 'notOlder/notNewer';

  /*notOlder*/

  var filePath = _.path.pathNormalize( __filename );
  var filter = makeFilter({ notOlder : new Date( Date.UTC( 1900, 1, 1 ) ) })
  var recordOptions = _.FileRecordContext( o, { dir : dir, filter : filter  });
  var got = fileRecord( filePath,recordOptions );
  console.log( got.mtime )
  test.identical( got.inclusion, true );

  /*notNewer*/

  var filePath = _.path.pathNormalize( __filename );
  var filter = makeFilter({ notNewer : new Date( Date.UTC( 1900, 1, 1 ) ) })
  var recordOptions = _.FileRecordContext( o, { dir : dir, filter : filter  });
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  /* notOlderAge */

  var filePath = _.path.pathNormalize( __filename );
  var filter = makeFilter({ notOlderAge : new Date( Date.UTC( 1990, 1, 1 ) ) })
  var recordOptions = _.FileRecordContext( o, { dir : dir, filter : filter  });
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  /* notNewerAge */

  var filePath = _.path.pathNormalize( __filename );
  var filter = makeFilter({ notNewerAge : new Date( Date.UTC( 1990, 1, 1 ) ) })
  var recordOptions = _.FileRecordContext( o, { dir : dir, filter : filter  });
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  test.case = 'both not* and mask* are used';

  var filePath = _.path.pathNormalize( __filename );
  var maskTerminal = _.RegexpObject( /.*\.test\.s/, 'includeAny' );
  var filter = makeFilter({ maskTerminal : maskTerminal, notOlder : new Date( Date.UTC( 1900, 1, 1 ) ) })
  var recordOptions = _.FileRecordContext( o, { dir : dir, filter : filter  });
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  /* notNewer check gives false, maskTerminal will be ignored */

  var filePath = _.path.pathNormalize( __filename );
  var maskTerminal = _.RegexpObject( /.*\.test\.s/, 'includeAny' );
  var filter = makeFilter({ maskTerminal : maskTerminal, notNewer : new Date( Date.UTC( 1900, 1, 1 ) ) })
  var recordOptions = _.FileRecordContext( o, { dir : dir, filter : filter  });
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  //

  test.case = 'onRecord';

  /* */

  function _onRecord( record )
  {
    test.identical( record.name, _.path.pathName( filePath ) );
  }
  var filePath = _.path.pathNormalize( __filename );
  var recordOptions = _.FileRecordContext( o, { dir : dir, onRecord : _onRecord} );
  fileRecord( filePath,recordOptions );

  //

  test.case = 'etc';

  /*strict mode on by default, record is not extensible*/

  var filePath = _.path.pathNormalize( __filename );
  var recordOptions = _.FileRecordContext( o, { dir : _.path.pathDir( filePath ) } );
  var got = fileRecord( filePath,recordOptions );
  test.shouldThrowErrorSync( function()
  {
    got.newProperty = 1;
  });

  /*strict mode off*/

  var filePath = _.path.pathNormalize( __filename );
  var recordOptions = _.FileRecordContext( o, { dir : _.path.pathDir( filePath ), strict : 0 } );
  var got = fileRecord( filePath, recordOptions );
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
    _.FileRecordContext( o, {} );
  })
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

    fileRecord : fileRecord,

  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
