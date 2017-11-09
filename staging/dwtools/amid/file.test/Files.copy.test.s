( function _Files_copy_test_s_( ) {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;

  try
  {
    require( '../../../Base.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  if( !wTools.FileProvider )
  require( '../file/FileTop.s' );

  _.include( 'wTesting' );

  // var rootDir = _.pathResolve( __dirname + '/../../../../tmp.tmp'  );

}

var _ = wTools;
var Parent = wTools.Tester;
var testRootDirectory;
var dstPath, srcPath;
var filePathSrc, filePathDst;
var filePathSoftSrc, filePathSoftDst;

//

function testDirMake()
{
  if( !isBrowser )
  testRootDirectory = _.dirTempMake( _.pathJoin( __dirname, '../..'  ) );
  else
  testRootDirectory = _.pathCurrent();

  dstPath = _.pathJoin( testRootDirectory, 'dst' );
  srcPath = _.pathJoin( testRootDirectory, 'src' );

  filePathSrc = _.pathJoin( srcPath, 'file.src' );
  filePathDst = _.pathJoin( dstPath, 'file.dst' );
  filePathSoftSrc = _.pathJoin( srcPath, 'file.soft.src' );
  filePathSoftDst = _.pathJoin( dstPath, 'file.soft.dst' );
}

//

function testDirClean()
{
  _.fileProvider.fileDelete( testRootDirectory );
}

//

var fileRead = ( path ) =>
{
  path = _.pathResolveTextLink( path );
  return _.fileProvider.fileRead( path );
}
var dirRead = ( path ) =>
{
  path = _.pathResolveTextLink( path );
  return _.fileProvider.directoryRead( path );
}
var testRootDirectoryClean = () => _.fileProvider.fileDelete( testRootDirectory );
var fileMake = ( path ) => _.fileProvider.fileWrite( path, path );
var fileStats = ( path ) =>
{
  path = _.pathResolveTextLink( path, true );
  return _.fileProvider.fileStat( path );
}

function prepareFile( path, type, link, level )
{
  if( level > 0 )
  {
    var name = _.pathName({ path : path, withExtension : 1 });
    path = _.pathDir( path );

    for( var l = 1 ; l <= level; l++ )
    path = _.pathJoin( path, 'level' + l );

    path = _.pathJoin( path, name );
  }

  if( !type )
  return path;

  var _path = path;

  if( link === 'soft' || link === 'text' )
  {
    path += '_';
  }

  if( type === 'terminal' || type === 'directory' )
  {
    if( type === 'directory' )
    fileMake( _.pathJoin( path, 'file' ) );
    else
    fileMake( path );
  }

  if( type === 'empty directory' )
  _.fileProvider.directoryMake( path );

  if( link === 'soft' )
  {
    _.fileProvider.linkSoft( _path, path );
  }

  if( link === 'text' )
  {
    _.fileProvider.fileWrite( _path, 'link ' + path );
  }

  return _path;
}

//

function drawInfo( info )
{
  var t = [];

  info.forEach( ( c ) =>
  {

    var srcType = c.src ? c.src.type : '-';
    var srcLink = c.src ? c.src.linkage : '-';

    var dstType = c.dst ? c.dst.type : '-';
    var dstLink = c.dst ? c.dst.linkage : '-';

    var level = c.level;

    if( !level )
    {
      if( c.src )
      level = c.src.level;
      else if( c.dst )
      level = c.dst.level;
    }

    t.push([ c.n, level, srcType, srcLink, dstType, dstLink, !!c.checks ])
  })

  var o =
  {
    data : t,
  	head : [ "#", 'level', 'src-type','src-link','dst-type', 'dst-link', 'passed' ],
  	colWidth : 15,
    colWidths :
    {
      0 : 5,
      1 : 5,
      6 : 7
    },
  }

  var output = _.strTable( o );
  console.log( output );
}

//

function filesCopy( test )
{
  var n = 0;
  var table = [];

  var checkIfPassed = ( info ) =>
  {
    var passed = true;
    for( var i = 0; i < info.checks.length; i++ )
    passed &= info.checks[ i ];
    info.checks = passed;
  }

  var typeOfFiles = [ 'terminal', 'empty directory', 'directory' ];
  var linkage = [ 'ordinary', 'soft', 'text' ];
  var levels = [ 0 ];

  var fixedOptions =
  {
    allowDelete : 1,
    allowWrite : 1,
    allowRewrite : 1,
    allowRewriteFileByDir : 1,
    recursive : 1,
    resolvingSoftLink : 1,
    resolvingTextLink : 1
  }

  var o =
  {
    dst : dstPath,
    src : srcPath
  }

  var combinations = [];

  levels.forEach( ( level ) =>
  {
    typeOfFiles.forEach( ( type ) =>
    {
      linkage.forEach( ( linkage ) =>
      {
        combinations.push
        ({
          level : level,
          type : type,
          linkage : linkage
        })
      })
    })
  })

  /* src present - dst missing */

  combinations.forEach( ( src ) =>
  {
    testRootDirectoryClean();

    var info =
    {
      n : ++n,
      src : src,
      dst : null,
      checks : []
    };

    test.description = _.toStr( { src : src, dst : null }, { levels : 2, wrap : 0 } );

    // console.log( _.toStr( info, { levels : 3 } ) )

    /* prepare to run filesCopy */

    o.src = srcPath;
    o.dst = dstPath;

    if( src.type === 'terminal' )
    o.src = _.pathJoin( srcPath, 'file.src' );

    o.src = prepareFile( o.src, src.type,src.linkage, src.level );
    o.dst = prepareFile( o.dst, null, null, src.level );

    var options = _.mapSupplement( o, fixedOptions );

    /* */

    var statsSrcBefore = fileStats( o.src );

    debugger
    var got = _.fileProvider.filesCopy( options );

    var statsSrc = fileStats( o.src );
    var statsDst = fileStats( o.dst );

    /* check if src wasnt changed */

    info.checks.push( test.identical( _.objectIs( statsSrc ), true ) );
    info.checks.push( test.identical( statsSrc.size, statsSrcBefore.size ) );

    /* check if src was copied to dst */

    info.checks.push( test.identical( _.objectIs( statsDst ), true ) );
    info.checks.push( test.identical( statsDst.size, statsSrc.size ) );
    info.checks.push( test.identical( statsDst.isDirectory(), statsSrc.isDirectory() ) );

    if( src.type === 'terminal' )
    info.checks.push( test.identical( fileRead( o.dst ), fileRead( o.src ) ) );
    else
    info.checks.push( test.identical( dirRead( o.dst ), dirRead( o.src ) ) );

    /* */

    checkIfPassed( info );
    table.push( info );
  })

  /* src present - dst present */

  combinations.forEach( ( src ) =>
  {
    combinations.forEach( ( dst ) =>
    {
      testRootDirectoryClean();

      if( src.level !== dst.level )
      return;

      var info =
      {
        n : ++n,
        src : src,
        dst : dst,
        checks : []
      };

      test.description = _.toStr( { src : src, dst : dst }, { levels : 2, wrap : 0 } );

      /* prepare to run filesCopy */

      o.src = srcPath;
      o.dst = dstPath;

      if( src.type === 'terminal' )
      o.src = _.pathJoin( srcPath, 'file.src' );

      if( dst.type === 'terminal' )
      o.dst = _.pathJoin( dstPath, 'file.dst' );

      o.src = prepareFile( o.src, src.type,src.linkage, src.level );
      o.dst = prepareFile( o.dst, dst.type,dst.linkage, dst.level );

      var options = _.mapSupplement( o, fixedOptions );

      /* */

      var statsSrcBefore = fileStats( o.src );
      var statsDstBefore = fileStats( o.dst );

      test.mustNotThrowError( () => _.fileProvider.filesCopy( options ) )

      var statsSrc = fileStats( o.src );
      var statsDst = fileStats( o.dst );

      /* check if src wasnt changed */

      info.checks.push( test.identical( _.objectIs( statsSrc ), true ) );
      info.checks.push( test.identical( statsSrc.size, statsSrcBefore.size ) );

      /* check if src was copied to dst */

      info.checks.push( test.identical( _.objectIs( statsDst ), true ) );
      info.checks.push( test.identical( statsDst.size, statsSrc.size ) );
      info.checks.push( test.identical( statsDst.isDirectory(), statsSrc.isDirectory() ) );

      if( src.type === 'terminal' )
      info.checks.push( test.identical( fileRead( o.dst ), fileRead( o.src ) ) );
      else
      info.checks.push( test.identical( dirRead( o.dst ), dirRead( o.src ) ) );

      /* */

      checkIfPassed( info );
      table.push( info );

    })
  })

  /* dst present - src missing */

  combinations.forEach( ( dst ) =>
  {
    testRootDirectoryClean();

    var info =
    {
      n : ++n,
      src : null,
      dst : dst,
      checks : []
    };

    test.description = _.toStr( { src : null, dst : dst }, { levels : 2, wrap : 0 } );

    /* prepare to run filesCopy */

    o.src = srcPath;
    o.dst = dstPath;

    // console.log( _.toStr( o, { levels : 3 } ) )

    if( dst.type === 'terminal' )
    o.dst = _.pathJoin( dstPath, 'file.dst' );

    o.dst = prepareFile( o.dst, dst.type, dst.linkage, dst.level );
    o.src = prepareFile( o.src, null, null, dst.level );

    var options = _.mapSupplement( o, fixedOptions );

    /* */

    var statsDstBefore = fileStats( o.dst );

    test.shouldThrowError( () => _.fileProvider.filesCopy( options ) )

    var statsSrc = fileStats( o.src );
    var statsDst = fileStats( o.dst );

    /* if allowDelete true, dst must be deleted */

    if( o.allowDelete )
    info.checks.push( test.identical( _.objectIs( statsDst ), false ) );
    else
    info.checks.push( test.identical( _.objectIs( statsDst ), true ) );

    if( statsDst )
    info.checks.push( test.identical( statsDst.size, statsDstBefore.size ) );

    /* check if src still not exists */

    info.checks.push( test.identical( _.objectIs( statsSrc ), false ) );

    /* */

    checkIfPassed( info );
    table.push( info );
  })

  /* both missing */

  levels.forEach( ( level ) =>
  {
    test.description = _.toStr( { src : null, dst : null }, { levels : 2, wrap : 0 } );

    var info =
    {
      n : ++n,
      level : level,
      src : null,
      dst : null,
      checks : []
    };

    testRootDirectoryClean();

    o.src = srcPath;
    o.dst = dstPath;

    o.src = prepareFile( o.src, null, null, level );
    o.dst = prepareFile( o.dst, null, null, level );

    var options = _.mapSupplement( o, fixedOptions );
    test.shouldThrowError( () => _.fileProvider.filesCopy( options ) );

    info.checks.push( test.shouldBe( !fileStats( o.src ) ) );
    info.checks.push( test.shouldBe( !fileStats( o.dst ) ) );

    checkIfPassed( info );
    table.push( info );
  })

  //

  drawInfo( table );
}

// --
// proto
// --

var Self =
{

  name : 'FilesCopy',
  // verbosity : 0,
  silencing : 1,

  onSuiteBegin : testDirMake,
  onSuiteEnd : testDirClean,

  tests :
  {
    filesCopy : filesCopy,
  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

})();
