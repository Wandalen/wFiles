( function _File_path_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../Files.ss' );

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
  var fileRecord = _.fileProvider.fileRecord;
  var pathFile,got;
  var o = { fileProvider :  _.fileProvider };

  function check( got, path, o )
  {
    var pathName = _.pathName( path );
    var ext = _.pathExt( path );
    var stat = _.fileProvider.fileStat( path );

    test.identical( got.absolute, path );

    if( o && o.dir === path )
    test.identical( got.relative, './.' );
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

  pathFile = _.pathJoin( dir, 'invalid.txt' );
  var got = fileRecord( pathFile,recordOptions );
  check( got, pathFile );

  /*absolute path, terminal file*/

  pathFile = _.pathRealMainFile();
  var got = fileRecord( pathFile,recordOptions );
  check( got, pathFile );

  /*absolute path, dir*/

  pathFile = dir;
  var got = fileRecord( pathFile,recordOptions );
  check( got, pathFile,recordOptions );

  /*absolute path, change dir to it root, pathFile - dir*/

  pathFile = dir;
  var recordOptions = _.FileRecordOptions( o, { dir : _.pathDir( dir ) } );
  var got = fileRecord( pathFile,recordOptions );
  check( got, pathFile,recordOptions );
  test.identical( got.stat.isDirectory(), true )

  /*relative path without dir/relative options*/

  pathFile = _.pathRelative( dir, _.pathRealMainFile() );
  var recordOptions = _.FileRecordOptions( o, {} );
  test.shouldThrowErrorSync( function()
  {
    fileRecord( pathFile, recordOptions );
  });

  /*relative path with dir option*/

  pathFile = _.pathRelative( dir, _.pathRealMainFile() );
  var recordOptions = _.FileRecordOptions( o, { dir : dir } );
  var got = fileRecord( pathFile,recordOptions );
  check( got, _.pathRealMainFile(),recordOptions );

  /*relative path with relative option*/

  pathFile = _.pathRelative( dir, _.pathRealMainFile() );
  var recordOptions = _.FileRecordOptions( o, { relative : dir } );
  var got = fileRecord( pathFile,recordOptions );
  check( got, _.pathRealMainFile(),recordOptions );

  /*relative path with dir+relative, relative is root of dir*/

  pathFile = _.pathRelative( dir, _.pathRealMainFile() );
  var recordOptions = _.FileRecordOptions( o, { dir : dir, relative : _.pathDir( dir ) } );
  var got = fileRecord( pathFile,recordOptions );
  test.identical( got.relative, './z.test/Files.record.test.ss' );
  test.identical( got.stat.isFile(), true );

  /*relative option can be any absolute path*/

  pathFile = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, { relative : '/X' } );
  var got = fileRecord( pathFile,recordOptions );
  test.identical( got.relative, '.' + pathFile );
  test.identical( got.absolute, recordOptions.relative + pathFile );
  test.identical( got.stat, null );

  /*dir option can be any absolute path*/

  pathFile = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, { dir : '/X' } );
  var got = fileRecord( pathFile,recordOptions );
  test.identical( got.relative, '.' + pathFile );
  test.identical( got.absolute, recordOptions.relative + pathFile );
  test.identical( got.stat, null );

  /*relative option is path to dir on other drive*/

  pathFile = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, { relative : 'X:\\x' } );
  var got = fileRecord( pathFile,recordOptions );
  test.identical( got.relative, './..' + pathFile );
  test.identical( got.absolute, recordOptions.relative + pathFile );
  test.identical( got.stat, null );

  /*dir option is path to dir on other drive*/

  pathFile = _.pathRealMainFile();
  var recordOptions = _.FileRecordOptions( o, { relative : 'X:\\x' } );
  var got = fileRecord( pathFile,recordOptions );
  test.identical( got.relative, './..' + pathFile );
  test.identical( got.absolute, recordOptions.relative + pathFile );
  test.identical( got.stat, null );


  /*dir path must be absolute*/

  pathFile = _.pathRealMainFile();
  test.shouldThrowErrorSync( function()
  {
    fileRecord( pathFile, { dir : 'z.test' } );
  });

  /*relative path must be absolute*/

  pathFile = _.pathRealMainFile();
  test.shouldThrowErrorSync( function()
  {
    fileRecord( pathFile,{ relative : 'z.test' } );
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
