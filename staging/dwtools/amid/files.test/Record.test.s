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
  testRootDirectory = _.path.dirTempOpen( _.path.join( __dirname, '../..' ), 'FileRecord' );
  else
  testRootDirectory = _.path.current();
}

//

function onSuiteEnd()
{
  if( !isBrowser )
  {
    _.assert( _.strEnds( testRootDirectory, 'FileRecord' ) );
    _.path.dirTempClose( testRootDirectory );
  }
}

//

/*
  qqq : split the test routine
*/

function fileRecord( test )
{

  var path = '/files/deck/minimal/minimal.coord';
  var r = _.fileProvider.fileRecord( path );

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
    var stat = _.fileProvider.fileStat( path );

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
  var recordContext = _.FileRecordContext( o, { dirPath : dir } );

  /*absolute path, not exist*/

  var filePath = _.path.join( dir, 'invalid.txt' );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, false );
  check( got, filePath );

  /*absolute path, terminal file*/

  var filePath = _.path.normalize( __filename );
  var got = fileRecord( filePath,recordContext );
  check( got, filePath );

  /*absolute path, dir*/

  var filePath = _.path.normalize( dir );
  var got = fileRecord( filePath,recordContext );
  check( got, filePath,recordContext );

  /*absolute path, change dir to it root, filePath - dir*/

  var filePath = _.path.normalize( dir );
  var recordContext = _.FileRecordContext( o, { dirPath : _.path.dir( dir ) } );
  var got = fileRecord( filePath,recordContext );
  check( got, filePath,recordContext );
  test.identical( got.stat.isDirectory(), true )
  test.identical( got.isDir, true );

  /*relative path without dir/relative options*/

  // filePath = _.path.relative( dir, __filename );
  // var recordContext = _.FileRecordContext( o, {} );
  // test.shouldThrowErrorSync( function()
  // {
  //   fileRecord( filePath, recordContext );
  // });

  /*relative path with dir option*/

  var filePath = _.path.relative( dir, __filename );
  var recordContext = _.FileRecordContext( o, { dirPath : dir } );
  var got = fileRecord( filePath,recordContext );
  check( got, __filename,recordContext );

  /*relative path with relative option*/

  var filePath = _.path.relative( dir, __filename );
  var recordContext = _.FileRecordContext( o, { basePath : dir } );
  var got = fileRecord( filePath,recordContext );
  check( got, __filename,recordContext );

  /*relative path with dir+relative, relative is root of dir*/

  var filePath = _.path.relative( dir, __filename );
  var recordContext = _.FileRecordContext( o, { dirPath : dir, basePath : _.path.dir( dir ) } );
  var got = fileRecord( filePath,recordContext );
  // test.identical( got.relative, './file.test/Record.test.s' );
  test.identical( got.relative, './' + _.path.relative( _.path.join( __filename, '../..' ) ,__filename ) );
  test.identical( got.stat.isFile(), true );

  /*relative option can be any absolute path*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordContext( o, { basePath : '/X' } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*dir option can be any absolute path*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordContext( o, { dirPath : '/X' } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*relative option is path to dir on other drive*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordContext( o, { basePath : 'X:\\x' } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, '../..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );

  /*dir option is path to dir on other drive*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordContext( o, { basePath : 'X:\\x' } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, '../..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.stat.isFile(), true );


  /*dir path must be absolute*/

  var filePath = __filename;
  test.shouldThrowErrorSync( function()
  {
    fileRecord( filePath, { dirPath : 'z.test' } );
  });

  /*relative path must be absolute*/

  var filePath = __filename;
  test.shouldThrowErrorSync( function()
  {
    fileRecord( filePath,{ basePath : 'z.test' } );
  });

  //

  test.case = 'filePath absolute dir/relative options'
  var filePath = _.path.normalize( __filename );

  /*dir - path to other disk*/

  var recordContext = _.FileRecordContext( o, { dirPath : '/X'  } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative - path to other disk*/

  var recordContext = _.FileRecordContext( o, { basePath : '/X'  } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, '..' + filePath );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*dir - path to dir that contains that file*/

  var recordContext = _.FileRecordContext( o, { dirPath : __dirname  } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, './' + _.path.name({ path : filePath, withExtension : 1 }) );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative - path to dir that contains that file*/

  var recordContext = _.FileRecordContext( o, { basePath : __dirname  } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, './' + _.path.name({ path : filePath, withExtension : 1 }) );
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*dir === filePath */

  var recordContext = _.FileRecordContext( o, { dirPath : filePath  } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, '.');
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ) );
  test.identical( _.objectIs( got.stat), true );

  /*relative === filePath */

  var recordContext = _.FileRecordContext( o, { basePath : filePath  } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, '.');
  test.identical( got.absolute, filePath );
  test.identical( got.real, filePath );
  test.identical( got.dir, _.path.normalize( __dirname ));
  test.identical( _.objectIs( got.stat), true );

  /*dir + relative, affects only on record.relative */

  var recordContext = _.FileRecordContext( o, { dirPath : '/a', basePath : '/x'  } );
  var got = fileRecord( filePath,recordContext );
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
  var recordContext = _.FileRecordContext( o, { dirPath : dirPath } );
  test.shouldThrowError( () => fileRecord( '/',recordContext ) );
  _.fileProvider.fieldSet( 'safe', 1 );

  /*dir - path to other disk, path doesn't exist*/

  _.fileProvider.fieldSet( 'safe', 1 );
  var recordContext = _.FileRecordContext( o, { dirPath : '/X' } );
  test.mustNotThrowError( () => fileRecord( filePath,recordContext ) );
  _.fileProvider.fieldSet( 'safe', 1 );

  /*relative - path to other disk*/

  _.fileProvider.fieldSet( 'safe', 0 );
  var recordContext = _.FileRecordContext( o, { basePath : '/X' } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.join( recordContext.basePath, name ) );
  test.identical( got.real, _.path.join( recordContext.basePath, name ) );
  test.identical( got.dir, recordContext.basePath );
  test.identical( got.stat, null );
  _.fileProvider.fieldReset( 'safe', 0 );

  /*dir - path to dir with file*/

  var recordContext = _.FileRecordContext( o, { dirPath : __dirname } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.join( recordContext.dirPath, name ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordContext.dirPath );
  test.identical( _.objectIs( got.stat ), true );

  /*relative - path to dir with file*/

  var recordContext = _.FileRecordContext( o, { basePath : __dirname } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.join( recordContext.basePath, name ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordContext.basePath );
  test.identical( _.objectIs( got.stat ), true );

  /*dir === filePath*/

  var recordContext = _.FileRecordContext( o, { dirPath : __filename } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.join( recordContext.dirPath, name ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordContext.dirPath );
  test.identical( got.stat, null );

  /*relative === filePath*/

  var recordContext = _.FileRecordContext( o, { basePath : __filename } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.relative, filePath );
  test.identical( got.absolute, _.path.join( recordContext.basePath, name ) );
  test.identical( got.real, got.absolute );
  test.identical( got.dir, recordContext.basePath );
  test.identical( got.stat, null );

  /*dir+relative, relative affects only record.relative, dir affects on record.absolute,record.real*/

  _.fileProvider.fieldSet( 'safe', 0 );
  var recordContext = _.FileRecordContext( o, { dirPath : '/x', basePath : '/a' } );
  var got = fileRecord( filePath,recordContext );
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
  // _.fileProvider.linkSoft( dst, src );
  // var got = _.fileProvider.fileRecord( dst );
  // test.identical( got.absolute, dst );
  // test.identical( got.real, src );
  // _.fileProvider.fieldReset( 'resolvingSoftLink', 1 );

  /* softlink, resolvingSoftLink  0 */

  _.fileProvider.fieldSet( 'resolvingSoftLink', 0 );
  var src = _.path.join( testRootDirectory, 'src' );
  var dst = _.path.join( testRootDirectory, 'dst' );
  _.fileProvider.fileWrite( src, 'src' );
  _.fileProvider.linkSoft( dst, src );
  var got = _.fileProvider.fileRecord( dst );
  test.identical( got.absolute, dst );
  test.identical( got.real, dst );
  _.fileProvider.fieldReset( 'resolvingSoftLink', 0 );

  /* - */

  test.case = 'masking';
  var filePath = _.path.normalize( __filename );

  function makeFilter( o )
  {
    _.mapSupplement( o, { fileProvider : _.fileProvider } );

    var f = _.FileRecordFilter( o );
    f.form();
    return f;
  }

  /*maskAll#1*/

  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskAll : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath, recordContext );
  test.identical( got.isActual, false );

  var mask = _.regexpMakeObject( '.', 'includeAny' );
  var filter = makeFilter({  maskAll : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath, recordContext );
  test.identical( got.isActual, true );

  /*maskAll#2*/

  var mask = _.regexpMakeObject( 'Abc', 'includeAny' );
  var filter = makeFilter({  maskAll : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, false );

  /*maskTerminal*/

  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskTerminal : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, false );

  var mask = _.regexpMakeObject( '.', 'includeAny' );
  var filter = makeFilter({  maskAll : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath, recordContext );
  test.identical( got.isActual, true );

  /*maskTerminal, filePath is not terminal*/

  var filePath = _.path.normalize( dir );
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskTerminal : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, true );

  /*maskDirectory, filePath is dir*/

  var filePath = _.path.normalize( dir );
  var mask = _.regexpMakeObject( 'test', 'includeAny' );
  var filter = makeFilter({  maskDirectory : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, false );

  var filePath = _.path.normalize( dir );
  var mask = _.regexpMakeObject( '.', 'includeAny' );
  var filter = makeFilter({  maskDirectory : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, true );

  /*maskDirectory, filePath is dir*/

  var filePath = _.path.normalize( dir );
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskDirectory : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, false );

  /*maskDirectory, filePath is terminal*/

  var filePath = _.path.normalize( __filename );
  var mask = _.regexpMakeObject( 'Record', 'includeAny' );
  var filter = makeFilter({  maskDirectory : mask, basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { filter : filter, basePath : filePath } );
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, true );

  //

  test.case = 'notOlder/notNewer';

  /*notOlder*/

  var filePath = _.path.normalize( __filename );
  var filter = makeFilter({ notOlder : new Date( Date.UTC( 1900, 1, 1 ) ), basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { dirPath : dir, filter : filter, basePath : filePath  });
  var got = fileRecord( filePath,recordContext );
  console.log( got.mtime )
  test.identical( got.isActual, true );

  /*notNewer*/

  var filePath = _.path.normalize( __filename );
  var filter = makeFilter({ notNewer : new Date( Date.UTC( 1900, 1, 1 ) ), basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { dirPath : dir, filter : filter, basePath : filePath  });
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, false );

  /* notOlderAge */

  var filePath = _.path.normalize( __filename );
  var filter = makeFilter({ notOlderAge : new Date( Date.UTC( 1970, 1, 1 ) ), basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { dirPath : dir, filter : filter, basePath : filePath  });
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, true );

  /* notNewerAge */

  var filePath = _.path.normalize( __filename );
  var filter = makeFilter({ notNewerAge : new Date( Date.UTC( 1970, 1, 1 ) ), basePath : filePath, inFilePath : filePath })
  var recordContext = _.FileRecordContext( o, { dirPath : dir, filter : filter, basePath : filePath  });
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, false );

  test.case = 'both not* and mask* are used';

  var filePath = _.path.normalize( __filename );
  var maskTerminal = _.RegexpObject( /.*\.test\.s/, 'includeAny' );
  var filter = makeFilter
  ({
    maskTerminal : maskTerminal,
    notOlder : new Date( Date.UTC( 1970, 1, 1 ) ),
    basePath : _.path.dir( filePath ),
    inFilePath : filePath
  })
  var recordContext = _.FileRecordContext( o, { dirPath : dir, filter : filter, basePath : _.path.dir( filePath )  });
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, true );

  /* notNewer check gives false, maskTerminal will be ignored */

  var filePath = _.path.normalize( __filename );
  var maskTerminal = _.RegexpObject( /.*\.test\.s/, 'includeAny' );
  var filter = makeFilter
  ({
    maskTerminal : maskTerminal,
    notNewer : new Date( Date.UTC( 1900, 1, 1 ) ),
    basePath : _.path.dir( filePath ),
    inFilePath : filePath
  })
  var recordContext = _.FileRecordContext( o, { dirPath : dir, filter : filter, basePath : _.path.dir( filePath )  });
  var got = fileRecord( filePath,recordContext );
  test.identical( got.isActual, false );

  //

  test.case = 'onRecord';

  /* */

  function _onRecord( record )
  {
    test.identical( record.name, _.path.name( filePath ) );
  }
  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordContext( o, { dirPath : dir, onRecord : _onRecord} );
  fileRecord( filePath,recordContext );

  //

  test.case = 'etc';

  /*strict mode on by default, record is not extensible*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordContext( o, { dirPath : _.path.dir( filePath ) } );
  var got = fileRecord( filePath,recordContext );
  test.shouldThrowErrorSync( function()
  {
    got.newProperty = 1;
  });

  /*strict mode off*/

  var filePath = _.path.normalize( __filename );
  var recordContext = _.FileRecordContext( o, { dirPath : _.path.dir( filePath ), strict : 0 } );
  var got = fileRecord( filePath, recordContext );
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
