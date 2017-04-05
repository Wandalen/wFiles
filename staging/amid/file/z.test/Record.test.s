( function _Record_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileMid.s' );

  var _ = wTools;

  _.include( 'wTesting' );

}

//

var _ = wTools;
var Parent = wTools.Testing;

//

function fileRecord( test )
{

  var path = '/file/deck/minimal/minimal.coord';

  debugger;
  var r = _.fileProvider.fileRecord( path );

  test.identical( r.absolute,path );
  test.identical( r.relative,'./minimal.coord' );

  test.identical( r.ext,'coord' );
  test.identical( r.extWithDot,'.coord' );

  test.identical( r.name,'minimal' );
  test.identical( r.nameWithExt,'minimal.coord' );

  //

  var dir = _.pathRealMainDir();
  var fileRecord = _.FileRecord;
  var filePath,got;
  var o = { fileProvider :  _.fileProvider };

  function check( got, path, o )
  {
    var pathName = _.pathName( path );
    var ext = _.pathExt( path );
    var stat = _.fileProvider.fileStat( path );

    test.identical( got.absolute, path );

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
  check( got, filePath );

  /*absolute path, terminal file*/

  filePath = _.pathRealMainFile();
  var got = fileRecord( filePath,recordOptions );
  check( got, filePath );

  /*absolute path, dir*/

  filePath = dir;
  var got = fileRecord( filePath,recordOptions );
  check( got, filePath,recordOptions );

  /*absolute path, change dir to it root, filePath - dir*/

  filePath = dir;
  var recordOptions = _.FileRecordOptions( o, { dir : _.pathDir( dir ) } );
  var got = fileRecord( filePath,recordOptions );
  check( got, filePath,recordOptions );
  test.identical( got.stat.isDirectory(), true )

  /*relative path without dir/relative options*/

  filePath = _.pathRelative( dir, _.pathRealMainFile() );
  var recordOptions = _.FileRecordOptions( o, {} );
  test.shouldThrowErrorSync( function()
  {
    fileRecord( filePath, recordOptions );
  });

  /*relative path with dir option*/

  filePath = _.pathRelative( dir, _.pathRealMainFile() );
  var recordOptions = _.FileRecordOptions( o, { dir : dir } );
  var got = fileRecord( filePath,recordOptions );
  check( got, _.pathRealMainFile(),recordOptions );

  /*relative path with relative option*/

  filePath = _.pathRelative( dir, _.pathRealMainFile() );
  var recordOptions = _.FileRecordOptions( o, { relative : dir } );
  var got = fileRecord( filePath,recordOptions );
  check( got, _.pathRealMainFile(),recordOptions );

  /*relative path with dir+relative, relative is root of dir*/

  filePath = _.pathRelative( dir, _.pathRealMainFile() );
  var recordOptions = _.FileRecordOptions( o, { dir : dir, relative : _.pathDir( dir ) } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, './z.test/Record.test.s' );
  test.identical( got.stat.isFile(), true );

  /*relative option can be any absolute path*/

  filePath = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, { relative : '/X' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*dir option can be any absolute path*/

  filePath = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, { dir : '/X' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*relative option is path to dir on other drive*/

  filePath = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, { relative : 'X:\\x' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '../..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*dir option is path to dir on other drive*/

  filePath = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, { relative : 'X:\\x' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '../..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );


  /*dir path must be absolute*/

  filePath = _.pathRealMainFile();
  test.shouldThrowErrorSync( function()
  {
    fileRecord( filePath, { dir : 'z.test' } );
  });

  /*relative path must be absolute*/

  filePath = _.pathRealMainFile();
  test.shouldThrowErrorSync( function()
  {
    fileRecord( filePath,{ relative : 'z.test' } );
  });

  //

  test.description = 'filePath absolute dir/relative options'
  filePath = _.pathRealMainFile();

  /*dir - path to other disk*/

  var recordOptions = _.FileRecordOptions( o, { dir : '/X'  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathRealMainDir() );
  test.identical( _.objectIs( got.stat), true );

  /*relative - path to other disk*/

  var recordOptions = _.FileRecordOptions( o, { relative : '/X'  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathRealMainDir() );
  test.identical( _.objectIs( got.stat), true );

  /*dir - path to dir that contains that file*/

  var recordOptions = _.FileRecordOptions( o, { dir : _.pathRealMainDir()  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, './' + _.pathName({ path : filePath, withExtension : 1 }) );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathRealMainDir() );
  test.identical( _.objectIs( got.stat), true );

  /*relative - path to dir that contains that file*/

  var recordOptions = _.FileRecordOptions( o, { relative : _.pathRealMainDir()  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, './' + _.pathName({ path : filePath, withExtension : 1 }) );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathRealMainDir() );
  test.identical( _.objectIs( got.stat), true );

  /*dir === filePath */

  var recordOptions = _.FileRecordOptions( o, { dir : filePath  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '.');
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathRealMainDir() );
  test.identical( _.objectIs( got.stat), true );

  /*relative === filePath */

  var recordOptions = _.FileRecordOptions( o, { relative : filePath  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '.');
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathRealMainDir() );
  test.identical( _.objectIs( got.stat), true );

  /*dir + relative, affects only on record.relative */

  var recordOptions = _.FileRecordOptions( o, { dir : '/a', relative : '/x'  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.pathRealMainDir() );
  test.identical( _.objectIs( got.stat), true );

  //

  test.description = 'filePath relative dir/relative options'
  var pathName = _.pathName({ path : _.pathRealMainFile(), withExtension : 1 });
  filePath = './' + pathName;

  //

  /*dir - path to other disk*/

  var recordOptions = _.FileRecordOptions( o, { dir : '/X'  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.real, _.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.dir, recordOptions.dir );
  test.identical( got.stat, null );

  /*relative - path to other disk*/

  var recordOptions = _.FileRecordOptions( o, { relative : '/X'  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.pathJoin( recordOptions.relative, pathName ) );
  test.identical( got.real, _.pathJoin( recordOptions.relative, pathName ) );
  test.identical( got.dir, recordOptions.relative );
  test.identical( got.stat, null );

  /*dir - path to dir with file*/

  var recordOptions = _.FileRecordOptions( o, { dir : _.pathRealMainDir() } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.dir );
  test.identical( _.objectIs( got.stat ), true );

  /*relative - path to dir with file*/

  var recordOptions = _.FileRecordOptions( o, { relative : _.pathRealMainDir() } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.pathJoin( recordOptions.relative, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.relative );
  test.identical( _.objectIs( got.stat ), true );

  /*dir === filePath*/

  var recordOptions = _.FileRecordOptions( o, { dir : _.pathRealMainFile() } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.dir );
  test.identical( got.stat, null );

  /*relative === filePath*/

  var recordOptions = _.FileRecordOptions( o, { relative : _.pathRealMainFile() } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.pathJoin( recordOptions.relative, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.relative );
  test.identical( got.stat, null );

  /*dir+relative, relative affects only record.relative, dir affects on record.absolute,record.real*/

  var recordOptions = _.FileRecordOptions( o, { dir : '/x', relative : '/a' } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.relative, '..' + _.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.absolute, _.pathJoin( recordOptions.dir, pathName ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordOptions.dir );
  test.identical( got.stat, null );

  //

  test.description = 'masking';
  filePath = _.pathRealMainFile();

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

  filePath = dir;
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { maskTerminal : mask  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  /*maskDir, filePath is dir*/

  filePath = dir;
  var mask = _.regexpMakeObject( 'test', 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { maskDir : mask  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  /*maskDir, filePath is dir*/

  filePath = dir;
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { maskDir : mask  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  /*maskDir, filePath is terminal*/

  filePath = _.pathRealMainFile();
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var recordOptions = _.FileRecordOptions( o, { maskDir : mask  } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, true );

  //

  test.description = 'notOlder/notNewer';

  /*notOlder*/

  filePath = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, { dir : dir, notOlder : new Date( Date.UTC( 1900, 1, 1 ) ) } );
  var got = fileRecord( filePath,recordOptions );
  console.log( got.mtime )
  test.identical( got.inclusion, true );

  /*notNewer*/

  filePath = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, { dir : dir, notNewer : new Date( Date.UTC( 1900, 1, 1 ) ) } );
  var got = fileRecord( filePath,recordOptions );
  test.identical( got.inclusion, false );

  //

  test.description = 'onRecord';

  /**/

  function _onRecord()
  {
    var self = this;
    test.identical( self.name, _.pathName( filePath ) );
  }
  filePath = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, { dir : dir, onRecord : _onRecord} );
  fileRecord( filePath,recordOptions );

  //

  test.description = 'etc';

  /*strict mode on by default, record is not extensible*/

  filePath = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, {} );
  var got = fileRecord( filePath,recordOptions );
  test.shouldThrowErrorSync( function()
  {
    got.newProperty = 1;
  });

  /*strict mode off*/

  filePath = _.pathRealMainFile();
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

  tests :
  {

    fileRecord : fileRecord,

  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
