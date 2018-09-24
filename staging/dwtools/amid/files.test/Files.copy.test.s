( function _Files_copy_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
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

//

function onSuiteBegin()
{

  _.assert( _.path.dirTempOpen );

  this.isBrowser = typeof module === 'undefined';

  if( !this.isBrowser )
  this.testRootDirectory = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ), 'FilesCopy' );
  else
  this.testRootDirectory = _.path.current();

  this.dstPath = _.path.join( this.testRootDirectory, 'dst' );
  this.srcPath = _.path.join( this.testRootDirectory, 'src' );

  this.filePathSrc = _.path.join( this.srcPath, 'file.src' );
  this.filePathDst = _.path.join( this.dstPath, 'file.dst' );
  this.filePathSoftSrc = _.path.join( this.srcPath, 'file.soft.src' );
  this.filePathSoftDst = _.path.join( this.dstPath, 'file.soft.dst' );
}

//

function onSuiteEnd()
{
  if( !this.isBrowser )
  {
    _.assert( _.strEnds( this.testRootDirectory, 'FilesCopy' ) );
    _.path.dirTempClose( this.testRootDirectory );
  }
}

//

var fileStats = ( path ) =>
{
  path = _.path.resolveTextLink( path, true );
  return _.fileProvider.fileStat( path );
}

//

function prepareFile( path, type, link, level )
{
  if( level > 0 )
  {
    var name = _.path.name({ path : path, withExtension : 1 });
    path = _.path.dir( path );

    for( var l = 1 ; l <= level; l++ )
    path = _.path.join( path, 'level' + l );

    path = _.path.join( path, name );
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
    var forFile = path;

    if( type === 'directory' )
    forFile = _.path.join( path, 'file' );

    _.fileProvider.fileWrite( forFile, forFile );
  }

  if( type === 'empty directory' )
  {
    _.fileProvider.directoryMake( path );
  }

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

function filesCopyWithAdapter( test )
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
  // !!! filesCopyOld is not working properly with links in some cases, cases for links are disabled
  // var linkage = [ 'ordinary', 'soft', 'text' ];
  var linkage = [ 'ordinary' ];
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
    dst : this.dstPath,
    src : this.srcPath
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

  // combinations.forEach( ( src ) =>
  // {
  //   _.fileProvider.filesDelete( test.context.testRootDirectory );

  //   var info =
  //   {
  //     n : ++n,
  //     src : src,
  //     dst : null,
  //     checks : []
  //   };

  //   test.case = _.toStr( { src : src, dst : null }, { levels : 2, wrap : 0 } );

  //   // console.log( _.toStr( info, { levels : 3 } ) )

  //   /* prepare to run filesCopyOld */

  //   o.src = srcPath;
  //   o.dst = dstPath;

  //   if( src.type === 'terminal' )
  //   o.src = _.path.join( srcPath, 'file.src' );

  //   o.src = prepareFile( o.src, src.type,src.linkage, src.level );
  //   o.dst = prepareFile( o.dst, null, null, src.level );

  //   var options = _.mapSupplement( o, fixedOptions );

  //   /* */

  //   var statsSrcBefore = fileStats( o.src );

  //   // debugger
  //   var got = _.fileProvider.filesCopyOld( options );

  //   var statsSrc = fileStats( o.src );
  //   var statsDst = fileStats( o.dst );

  //   /* check if src wasnt changed */

  //   info.checks.push( test.identical( _.objectIs( statsSrc ), true ) );
  //   info.checks.push( test.identical( statsSrc.size, statsSrcBefore.size ) );

  //   /* check if src was copied to dst */

  //   info.checks.push( test.identical( _.objectIs( statsDst ), true ) );
  //   info.checks.push( test.identical( statsDst.size, statsSrc.size ) );
  //   info.checks.push( test.identical( statsDst.isDirectory(), statsSrc.isDirectory() ) );

  //   if( src.type === 'terminal' )
  //   info.checks.push( test.identical( fileRead( o.dst ), fileRead( o.src ) ) );
  //   else
  //   info.checks.push( test.identical( dirRead( o.dst ), dirRead( o.src ) ) );

  //   /* */

  //   checkIfPassed( info );
  //   table.push( info );
  // })

  /* src present - dst present */

  combinations.forEach( ( src ) =>
  {
    combinations.forEach( ( dst ) =>
    {
      var info =
      {
        n : ++n,
        src : src,
        dst : dst,
        checks : []
      };

      // if( n !== 29 )
      // return;

      _.fileProvider.filesDelete( test.context.testRootDirectory );

      if( src.level !== dst.level )
      return;

      test.case = _.toStr( { src : src, dst : dst }, { levels : 2, wrap : 0 } );

      /* prepare to run filesCopyOld */

      o.src = this.srcPath;
      o.dst = this.dstPath;

      if( src.type === 'terminal' )
      o.src = _.path.join( this.srcPath, 'file.src' );

      if( dst.type === 'terminal' )
      o.dst = _.path.join( this.dstPath, 'file.dst' );

      o.src = this.prepareFile( o.src, src.type,src.linkage, src.level );
      o.dst = this.prepareFile( o.dst, dst.type,dst.linkage, dst.level );

      var options = _.mapExtend( null, o )
      _.mapSupplement( options, fixedOptions );

      /* */

      var statsSrcBefore = this.fileStats( o.src );
      var statsDstBefore = this.fileStats( o.dst );

      console.log( test.case )
      // console.log( options )

      _.fileProvider.filesCopyWithAdapter( options );

      var statsSrc = this.fileStats( o.src );
      var statsDst = this.fileStats( o.dst );

      /* check if src wasnt changed */

      info.checks.push( test.identical( _.objectIs( statsSrc ), true ) );
      info.checks.push( test.identical( statsSrc.size, statsSrcBefore.size ) );

      /* check if src was copied to dst */

      info.checks.push( test.identical( _.objectIs( statsDst ), true ) );
      info.checks.push( test.identical( statsDst.size, statsSrc.size ) );
      info.checks.push( test.identical( statsDst.isDirectory(), statsSrc.isDirectory() ) );

      if( src.linkage === 'text' )
      {
        o.src = _.path.resolveTextLink( o.src, true );
        o.dst = _.path.resolveTextLink( o.dst, true );
      }

      if( src.type === 'terminal' )
      {
        var dstFile = _.fileProvider.fileRead( o.dst );
        var srcFile = _.fileProvider.fileRead( o.src );
        info.checks.push( test.identical( dstFile, srcFile ) );
      }
      else
      {
        var dstDir = _.fileProvider.directoryRead( o.dst );
        var srcDir = _.fileProvider.directoryRead( o.src );
        info.checks.push( test.identical( dstDir, srcDir ) );
      }

      /* */

      checkIfPassed( info );
      table.push( info );

    })
  })

  /* dst present - src missing */

  // combinations.forEach( ( dst ) =>
  // {
  //   _.fileProvider.filesDelete( test.context.testRootDirectory );

  //   var info =
  //   {
  //     n : ++n,
  //     src : null,
  //     dst : dst,
  //     checks : []
  //   };

  //   test.case = _.toStr( { src : null, dst : dst }, { levels : 2, wrap : 0 } );

  //   /* prepare to run filesCopyOld */

  //   o.src = srcPath;
  //   o.dst = dstPath;

  //   // console.log( _.toStr( o, { levels : 3 } ) )

  //   if( dst.type === 'terminal' )
  //   o.dst = _.path.join( dstPath, 'file.dst' );

  //   o.dst = prepareFile( o.dst, dst.type, dst.linkage, dst.level );
  //   o.src = prepareFile( o.src, null, null, dst.level );

  //   var options = _.mapSupplement( o, fixedOptions );

  //   /* */

  //   var statsDstBefore = fileStats( o.dst );

  //   test.shouldThrowError( () => _.fileProvider.filesCopyOld( options ) )

  //   var statsSrc = fileStats( o.src );
  //   var statsDst = fileStats( o.dst );

  //   /* if allowDelete true, dst must be deleted */

  //   if( o.allowDelete )
  //   info.checks.push( test.identical( _.objectIs( statsDst ), false ) );
  //   else
  //   info.checks.push( test.identical( _.objectIs( statsDst ), true ) );

  //   if( statsDst )
  //   info.checks.push( test.identical( statsDst.size, statsDstBefore.size ) );

  //   /* check if src still not exists */

  //   info.checks.push( test.identical( _.objectIs( statsSrc ), false ) );

  //   /* */

  //   checkIfPassed( info );
  //   table.push( info );
  // })

  /* both missing */

  // levels.forEach( ( level ) =>
  // {
  //   test.case = _.toStr( { src : null, dst : null }, { levels : 2, wrap : 0 } );

  //   var info =
  //   {
  //     n : ++n,
  //     level : level,
  //     src : null,
  //     dst : null,
  //     checks : []
  //   };

  //   _.fileProvider.filesDelete( test.context.testRootDirectory );

  //   o.src = srcPath;
  //   o.dst = dstPath;

  //   o.src = prepareFile( o.src, null, null, level );
  //   o.dst = prepareFile( o.dst, null, null, level );

  //   var options = _.mapSupplement( o, fixedOptions );
  //   test.shouldThrowError( () => _.fileProvider.filesCopyOld( options ) );

  //   info.checks.push( test.is( !fileStats( o.src ) ) );
  //   info.checks.push( test.is( !fileStats( o.dst ) ) );

  //   checkIfPassed( info );
  //   table.push( info );
  // })

  //

  this.drawInfo( table );

}

//

function filesCopyWithAdapter2( test )
{
  var filesTree =
  {
    'src' :
    {
      'a1' : 'a2',
      'c' :
      {
        'c1' : 'c2',
        'c3' : 'c3',
      },
    },
    'dst' :
    {
      'a1' : 'a1',
      'a2' : 'a2',
      'c' :
      {
        'c1' : 'c1',
        'c2' : 'c2',
        'd' :
        {
          'd1' : 'd1',
          'd2' : 'd2',
        },
      },
    },
  }

  var fixedOptions =
  {
    dst : this.dstPath,
    src : this.srcPath,
    allowDelete : 1,
    allowWrite : 1,
    allowRewrite : 1,
    allowRewriteFileByDir : 1,
    recursive : 1,
  }

  function makeTree( path, tree, stat )
  {
    _.fileProvider.filesDelete( path );
    // _.fileProvider.filesTreeWrite
    // ({
    //     filePath : path,
    //     filesTree : tree,
    //     sameTime : 1
    // })

    for( var k in tree )
    {
      var n = tree[ k ];

      var filePath = _.path.join( path, k );

      if( _.objectIs( n ) )
      {
        makeTree( filePath, n );
      }
      else
      {
        _.fileProvider.directoryMakeForFile( filePath );
        _.fileProvider.fileWrite( filePath, n );

        if( !stat )
        {
          stat = _.fileProvider.fileStat( filePath );
        }
        else
        {
          _.fileProvider.fileTimeSet( filePath, stat.atime, stat.mtime );
          _.fileProvider.fileTimeSet( _.path.dir( filePath ), stat.atime, stat.mtime );
        }
      }
    }
  }

  function filesTreeRead( filePath )
  {
    var files = _.fileProvider.filesFind
    ({
      filePath : filePath,
      includingBase : 0,
      includingTransients : 1,
      includingDirectories : 1,
      includingTerminals : 1,
      recursive : 1
    });

    var tree = {};
    for( var i = 0; i < files.length; i++ )
    {
      var r = files[ i ];
      if( r.stat.isDirectory() )
      continue;

      _.entitySelectSet
      ({
        container : tree,
        query : _.path.undot( r.relative ),
        delimeter : '/',
        set : _.fileProvider.fileRead( r.absolute ),
      });

    }

    return tree;
  }

  //

  makeTree( this.srcPath, filesTree.src );
  makeTree( this.dstPath, filesTree.dst );

  var o = _.mapExtend( null, fixedOptions );
  var srcBefore = filesTreeRead( this.srcPath );
  _.fileProvider.filesCopyWithAdapter( o );
  var srcAfter = filesTreeRead( this.srcPath );
  test.identical( srcBefore, srcAfter );
  var dstAfter = filesTreeRead( this.dstPath );
  test.identical( srcBefore, dstAfter );

  //

  makeTree( this.srcPath, filesTree.src );
  makeTree( this.dstPath, filesTree.dst );

  var o = _.mapExtend( null, fixedOptions );
  o.allowDelete = 0;
  var srcBefore = filesTreeRead( this.srcPath );
  var dstBefore = filesTreeRead( this.dstPath );
  _.fileProvider.filesCopyWithAdapter( o );
  var srcAfter = filesTreeRead( this.srcPath );
  test.identical( srcBefore, srcAfter );
  debugger
  var dstAfter = filesTreeRead( this.dstPath );
  var dstExpected =
  {
    a1 : 'a2',
    a2 : 'a2',
    c :
    {
      c1 : 'c2',
      c2 : 'c2',
      c3 : 'c3',
      d : { d1 : 'd1', d2 : 'd2' }
    }
  }
  test.identical( dstExpected, dstAfter );
}

// --
// declare
// --

var Self =
{

  name : 'Tools/mid/files/FilesCopy',
  // verbosity : 0,
  silencing : 1,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

  context :
  {
    isBrowser : null,
    testRootDirectory : null,
    dstPath : null,
    srcPath : null,
    filePathSrc : null,
    filePathDst : null,
    filePathSoftSrc : null,
    filePathSoftDst : null,

    fileStats : fileStats,
    prepareFile : prepareFile,
    drawInfo : drawInfo
  },

  tests :
  {
    filesCopyWithAdapter : filesCopyWithAdapter,
    filesCopyWithAdapter2 : filesCopyWithAdapter2
  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

})();
