( function _Record_test_s_( ) {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      require.resolve( toolsPath )/*hhh*/;
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath )/*hhh*/;
  }


  var _ = _global_.wTools;

  if( !_global_.wTools.FileProvider )
  require( '../file/FileTop.s' );

  _.include( 'wTesting' );

}

//

var _ = _global_.wTools;
var Parent = _.Tester;
var testRootDirectory;

//

function onSuitBegin()
{
  if( !isBrowser )
  testRootDirectory = _.dirTempMake( _.pathJoin( __dirname, '../..' ) );
  else
  testRootDirectory = _.pathCurrent();
}

//

function onSuitEnd()
{
  _.fileProvider.filesDelete( testRootDirectory );
}

//

function fileRecord( test )
{

  var path = '/file/deck/minimal/minimal.coord';

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

  var dir = _.pathNormalize( __dirname );
  var fileRecord = _.FileRecord;
  var filePath,got;
  var o = { fileProvider :  _.fileProvider };

  function check( got, path, o )
  {
    path = _.pathNormalize( path );
    var pathName = _.pathName( path );
    var ext = _.pathExt( path );
    var stat = _.fileProvider.fileStat( path );

    test.identical( got.absolute, _.pathNormalize( path ) );

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

  test.description = 'dir/relative options';
  var recordOptions = _.FileRecordOptions( o, { dir : dir } );

  /*absolute path, not exist*/

  filePath = _.pathJoin( dir, 'invalid.txt' );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );
  check( got, filePath );

  /*absolute path, terminal file*/

  filePath = _.pathNormalize( __filename );
  var got = fileRecord( filePath,recordOptions );
  check( got, filePath );

  /*absolute path, dir*/

  filePath = _.pathNormalize( dir );
  var got = fileRecord( filePath,recordOptions );
  check( got, filePath,recordOptions );

  /*absolute path, change dir to it root, filePath - dir*/

  filePath = _.pathNormalize( dir );
  var recordOptions = _.FileRecordOptions( o, { dir : _.pathDir( dir ) } );
  var got = fileRecord( filePath,recordOptions );
  check( got, filePath,recordOptions );
  test.identical( got.stat.isDirectory(), true )
  test.identical( got._isDir(), true );

  /*relative path without dir/relative options*/

  filePath = _.pathRelative( dir, __filename );
  var recordOptions = _.FileRecordOptions( o, {} );
  test.shouldThrowErrorSync( function()
  {
    fileRecord( filePath, recordOptions );
  });

  /*relative path with dir option*/

  filePath = _.pathRelative( dir, __filename );
  var recordOptions = _.FileRecordOptions( o, { dir : dir } );
  var got = fileRecord( filePath,recordOptions );
  check( got, __filename,recordOptions );

  /*relative path with relative option*/

  filePath = _.pathRelative( dir, __filename );
  var recordOptions = _.FileRecordOptions( o, { relative : dir } );
  var got = fileRecord( filePath,recordOptions );
  check( got, __filename,recordOptions );

  /*relative path with dir+relative, relative is root of dir*/

  filePath = _.pathRelative( dir, __filename );
  var recordOptions = _.FileRecordOptions( o, { dir : dir, relative : _.pathDir( dir ) } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, './file.test/Record.test.s' );
  test.identical( got.stat.isFile(), true );

  /*relative option can be any absolute path*/

  filePath = _.pathNormalize( __filename );
  var recordOptions = _.FileRecordOptions( o, { relative : '/X' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*dir option can be any absolute path*/

  filePath = _.pathNormalize( __filename );
  var recordOptions = _.FileRecordOptions( o, { dir : '/X' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*relative option is path to dir on other drive*/

  filePath = _.pathNormalize( __filename );
  var recordOptions = _.FileRecordOptions( o, { relative : 'X:\\x' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '../..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*dir option is path to dir on other drive*/

  filePath = _.pathNormalize( __filename );
  var recordOptions = _.FileRecordOptions( o, { relative : 'X:\\x' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '../..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );


  /*dir path must be absolute*/

  filePath = __filename;
  test.shouldThrowErrorSync( function()
  {
    fileRecord( filePath, { dir : 'z.test' } );
  });

  /*relative path must be absolute*/

  filePath = __filename;
  test.shouldThrowErrorSync( function()
  {
    fileRecord( filePath,{ relative : 'z.test' } );
  });

  //

  test.description = 'filePath absolute dir/relative options'
  filePath = _.pathNormalize( __filename );

  /*dir - path to other disk*/

  var recordOptions = _.FileRecordOptions( o, { dir : '/X'  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathNormalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative - path to other disk*/

  var recordOptions = _.FileRecordOptions( o, { relative : '/X'  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathNormalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*dir - path to dir that contains that file*/

  var recordOptions = _.FileRecordOptions( o, { dir : __dirname  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, './' + _.pathName({ path : filePath, withExtension : 1 }) );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathNormalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative - path to dir that contains that file*/

  var recordOptions = _.FileRecordOptions( o, { relative : __dirname  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, './' + _.pathName({ path : filePath, withExtension : 1 }) );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathNormalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*dir === filePath */

  var recordOptions = _.FileRecordOptions( o, { dir : filePath  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '.');
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathNormalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative === filePath */

  var recordOptions = _.FileRecordOptions( o, { relative : filePath  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '.');
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathNormalize( __dirname ));
  test.identical( _.objectIs( got.stat), true );

  /*dir + relative, affects only on record.relative */

  var recordOptions = _.FileRecordOptions( o, { dir : '/a', relative : '/x'  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathNormalize( __dirname ));
  test.identical( _.objectIs( got.stat), true );

  //

  test.description = 'filePath relative dir/relative options'
  var pathName = _.pathName({ path : _.pathNormalize( __filename ), withExtension : 1 });
  filePath = './' + pathName;

  //

  /*dir - path to other disk, path exists*/

  _.fileProvider.fieldSet( 'safe', 1 );
  var dirPath = _.pathNormalize( __dirname );
  dirPath = dirPath.substring( 0, dirPath.indexOf( '/', 0 ) );
  var recordOptions = _.FileRecordOptions( o, { dir : dirPath } );
  test.shouldThrowError( () => fileRecord( filePath,recordOptions ) );
  _.fileProvider.fieldSet( 'safe', 1 );

  /*dir - path to other disk, path doesn't exist*/

  _.fileProvider.fieldSet( 'safe', 1 );
  var recordOptions = _.FileRecordOptions( o, { dir : '/X' } );
  test.mustNotThrowError( () => fileRecord( filePath,recordOptions ) );
  _.fileProvider.fieldSet( 'safe', 1 );

  /*relative - path to other disk*/

  _.fileProvider.fieldSet( 'safe', 0 );
  var recordOptions = _.FileRecordOptions( o, { relative : '/X' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.pathJoin( recordOptions.relative, pathName ) );
  test.identical( got.real, _.pathJoin( recordOptions.relative, pathName ) );
  test.identical( got.dir, recordOptions.relative );
  test.identical( got.stat, null );
  _.fileProvider.fieldReset( 'safe', 0 );

  /*dir - path to dir with file*/

  var recordOptions = _.FileRecordOptions( o, { dir : __dirname } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.dir );
  test.identical( _.objectIs( got.stat ), true );

  /*relative - path to dir with file*/

  var recordOptions = _.FileRecordOptions( o, { relative : __dirname } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.pathJoin( recordOptions.relative, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.relative );
  test.identical( _.objectIs( got.stat ), true );

  /*dir === filePath*/

  var recordOptions = _.FileRecordOptions( o, { dir : __filename } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.dir );
  test.identical( got.stat, null );

  /*relative === filePath*/

  var recordOptions = _.FileRecordOptions( o, { relative : __filename } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.pathJoin( recordOptions.relative, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.relative );
  test.identical( got.stat, null );

  /*dir+relative, relative affects only record.relative, dir affects on record.absolute,record.real*/

  _.fileProvider.fieldSet( 'safe', 0 );
  var recordOptions = _.FileRecordOptions( o, { dir : '/x', relative : '/a' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + _.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.absolute, _.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.dir );
  test.identical( got.stat, null );
  _.fileProvider.fieldReset( 'safe', 0 );

  /* softlink, resolvingSoftLink  1 */

  // _.fileProvider.fieldSet( 'resolvingSoftLink', 1 );
  // var pathSrc = _.pathJoin( testRootDirectory, 'src' );
  // var pathDst = _.pathJoin( testRootDirectory, 'dst' );
  // _.fileProvider.fileWrite( pathSrc, 'src' );
  // _.fileProvider.linkSoft( pathDst, pathSrc );
  // var got = _.fileProvider.fileRecord( pathDst );
  // test.identical( got.absolute, pathDst );
  // test.identical( got.real, pathSrc );
  // _.fileProvider.fieldReset( 'resolvingSoftLink', 1 );

  /* softlink, resolvingSoftLink  0 */

  _.fileProvider.fieldSet( 'resolvingSoftLink', 0 );
  var pathSrc = _.pathJoin( testRootDirectory, 'src' );
  var pathDst = _.pathJoin( testRootDirectory, 'dst' );
  _.fileProvider.fileWrite( pathSrc, 'src' );
  _.fileProvider.linkSoft( pathDst, pathSrc );
  var got = _.fileProvider.fileRecord( pathDst );
  test.identical( got.absolute, pathDst );
  test.identical( got.real, pathDst );
  _.fileProvider.fieldReset( 'resolvingSoftLink', 0 );

  //

  test.description = 'masking';
  filePath = _.pathNormalize( __filename );

  /*maskAll#1*/

  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { maskAll : mask  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  /*maskAll#2*/

  var mask = _.regexpMakeObject( 'Abc', 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { maskAll : mask  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  /*maskTerminal*/

  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { maskTerminal : mask  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  /*maskTerminal, filePath is not terminal*/

  filePath = _.pathNormalize( dir );
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { maskTerminal : mask  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  /*maskDir, filePath is dir*/

  filePath = _.pathNormalize( dir );
  var mask = _.regexpMakeObject( 'test', 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { maskDir : mask  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  /*maskDir, filePath is dir*/

  filePath = _.pathNormalize( dir );
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { maskDir : mask  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  /*maskDir, filePath is terminal*/

  filePath = _.pathNormalize( __filename );
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { maskDir : mask  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  //

  test.description = 'notOlder/notNewer';

  /*notOlder*/

  filePath = _.pathNormalize( __filename );
  var recordOptions = _.FileRecordOptions( o, { dir : dir, notOlder : new Date( Date.UTC( 1900, 1, 1 ) ) } );
  var got = fileRecord( filePath,recordOptions );
  console.log( got.mtime )
  test.identical( got.inclusion, true );

  /*notNewer*/

  filePath = _.pathNormalize( __filename );
  var recordOptions = _.FileRecordOptions( o, { dir : dir, notNewer : new Date( Date.UTC( 1900, 1, 1 ) ) } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  /* notOlderAge */

  filePath = _.pathNormalize( __filename );
  var recordOptions = _.FileRecordOptions( o, { dir : dir, notOlderAge : new Date( Date.UTC( 1990, 1, 1 ) ) } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  /* notNewerAge */

  filePath = _.pathNormalize( __filename );
  var recordOptions = _.FileRecordOptions( o, { dir : dir, notNewerAge : new Date( Date.UTC( 1990, 1, 1 ) ) } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  test.description = 'both not* and mask* are used';

  filePath = _.pathNormalize( __filename );
  var maskTerminal = _.RegexpObject( /.*\.test\.s/, 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { dir : dir, maskTerminal : maskTerminal, notOlder : new Date( Date.UTC( 1900, 1, 1 ) ) } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  /* notNewer check gives false, maskTerminal will be ignored */

  filePath = _.pathNormalize( __filename );
  var maskTerminal = _.RegexpObject( /.*\.test\.s/, 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { dir : dir, maskTerminal : maskTerminal, notNewer : new Date( Date.UTC( 1900, 1, 1 ) ) } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  //

  test.description = 'onRecord';

  /* */

  function _onRecord( record )
  {
    test.identical( record.name, _.pathName( filePath ) );
  }
  filePath = _.pathNormalize( __filename );
  var recordOptions = _.FileRecordOptions( o, { dir : dir, onRecord : _onRecord} );
  fileRecord( filePath,recordOptions );

  //

  test.description = 'etc';

  /*strict mode on by default, record is not extensible*/

  filePath = _.pathNormalize( __filename );
  var recordOptions = _.FileRecordOptions( o, {} );
  var got = fileRecord( filePath,recordOptions );
  test.shouldThrowErrorSync( function()
  {
    got.newProperty = 1;
  });

  /*strict mode off*/

  filePath = _.pathNormalize( __filename );
  var recordOptions = _.FileRecordOptions( o, { strict : 0 } );
  var got = fileRecord( filePath, recordOptions );
  test.mustNotThrowError( function()
  {
    got.newProperty = 1;
    test.identical( got.newProperty, 1 );
  });

}

// --
// proto
// --

var Self =
{

  name : 'FileRecord',
  silencing : 1,

  onSuitBegin : onSuitBegin,
  onSuitEnd : onSuitEnd,

  tests :
  {

    fileRecord : fileRecord,

  },

}

Self = wTestSuit( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
