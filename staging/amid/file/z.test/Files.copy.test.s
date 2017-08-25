( function _Files_copy_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  try
  {
    require( '../../../abase/wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  require( '../FileMid.s' );

  _.include( 'wTesting' );

  // var rootDir = _.pathResolve( __dirname + '/../../../../tmp.tmp'  );

}

var _ = wTools;
var Parent = wTools.Tester;

//

var testDir = _.pathResolve( __dirname, '../../../../tmp.tmp/filesCopy' );
var pathDst, pathSrc;

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
var testDirClean = () => _.fileProvider.fileDelete( testDir );
var fileMake = ( path ) => _.fileProvider.fileWrite( path, path );
var fileStats = ( path ) =>
{
  path = _.pathResolveTextLink( path, true );
  return _.fileProvider.fileStat( path );
}

pathDst = _.pathJoin( testDir, 'dst' );
pathSrc = _.pathJoin( testDir, 'src' );

var filePathSrc = _.pathJoin( pathSrc, 'file.src' );
var filePathDst = _.pathJoin( pathDst, 'file.dst' );
var filePathSoftSrc = _.pathJoin( pathSrc, 'file.soft.src' );
var filePathSoftDst = _.pathJoin( pathDst, 'file.soft.dst' );

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

  var Table = require( 'cli-table2' );
  var o =
  {
  	head : [ "#", 'level', 'src-type','src-link','dst-type', 'dst-link', 'passed' ],
  	colWidths : [ 5 ],
  	rowAligns : null,
  	colAligns : null,
  	style:
  	{
  	 compact : true,
  	 'padding-left': 0,
  	 'padding-right': 0
  	},
  }

  o.rowAligns = _.arrayFill({ times : o.head.length, value : 'center' });
  o.colAligns = o.rowAligns;

  /**/

  var table = new Table( o );
  table.push.apply( table, t );
  console.log( table.toString() );
}

//

// function filesCopy( test )
// {

//   var cases = [];

//   function compareChecks( info )
//   {
//     info.allChecksPassed = true;
//     for( var i = 0; i < info.checks.length; i++ )
//     if( !info.checks[ i ].res )
//     {
//       info.allChecksPassed = false;
//       break;
//     }
//   }

//   /* Map of test cases
//       * level : 0, 1, 2
//     (
//       presence of file : missing, present
//       +
//       if present
//       (
//         * kind of file : empty directory, no empty directory, terminal
//         * linkage of file : ordinary, soft, text
//       )
//     )
//     ^ where file : src, dst
//     3 * ( 1 + 3 * 3  ) ^ 2 = 3 * 10 ^ 2 = 3 * 100 = 300
//   */

//   //

//   var fixedDefaults =
//   {
//     allowDelete : 0,
//     allowWrite : 0,
//     allowRewrite : 0,
//     allowRewriteFileByDir : 0,
//   }

//   var defaultCases =
//   [
//     {
//       o : { dst : pathDst, src : pathSrc },
//       shouldThrowError : true,
//     },
//     {
//       o : { dst : pathDst, src : filePathSoftSrc },
//       pre : function ()
//       {
//         _.fileProvider.fileWrite( filePathSrc, 'src' );
//         _.fileProvider.linkSoft( filePathSoftSrc, filePathSrc );
//       },
//       shouldThrowError : true,
//     },

//   ]

//   //

//   var fixedOptions =
//   {
//     allowDelete : 1,
//     allowWrite : 1,
//     allowRewrite : 1,
//     allowRewriteFileByDir : 1,
//     recursive : 1,
//     resolvingSoftLink : 1,
//     resolvingTextLink : 1
//   }

//   var o =
//   {
//     dst : null,
//     src : null
//   }

//   _.mapSupplement( o, fixedOptions );

//   var typeOfFiles = [ 'terminal', 'empty directory', 'directory' ];
//   var linkage = [ 'ordinary', 'soft', 'text' ];
//   var levels = 1;



//   /* src is present -> dst present/missing */

//   for( var k = 0 ; k < linkage.length ; k++ )
//   {
//     var linkSrc = linkage[ k ];

//     for( var i = 0; i < typeOfFiles.length; i++ )
//     {
//       for( var l = 0 ; l < levels ; l++ )
//       {
//         testDirClean();

//         var kindOfSrc = typeOfFiles[ i ];

//         var info =
//         {
//           level : l,
//           presenceOfSrc : 'present',
//           kindOfSrc : kindOfSrc,
//           linkageOfSrc : linkSrc,
//           direction : 'src -> dst',
//         };

//         o.src = pathSrc;

//         if( kindOfSrc === 'terminal' )
//         {
//           o.src = _.pathJoin( pathSrc, 'file.src' );
//           prepareFile( o.src, kindOfSrc, linkSrc, l );
//         }

//         if( kindOfSrc === 'directory' || kindOfSrc === 'empty directory' )
//         {
//           o.src = pathSrc;
//           prepareFile( o.src, kindOfSrc, linkSrc, l );
//         }

//         /* dst is present */

//         for( var x = 0; x < linkage.length; x++ )
//         {
//           var linkDst = linkage[ x ];
//           for( var j = 0; j < typeOfFiles.length; j++ )
//           {
//             _.fileProvider.fileDelete( pathDst );

//             var kindOfDst = typeOfFiles[ j ];

//             info.presenceOfDst = 'present';
//             info.kindOfDst = kindOfDst;
//             info.linkageOfDst = linkDst;
//             info.options = o;
//             delete info.allChecksPassed;
//             delete info.checks;

//             logger.log( _.toStr( info, { levels : 2 } ) );

//             info.checks = [];

//             var description =
//             'level : ' + l
//             + ' linkage : ' + linkSrc + ' ' + kindOfSrc
//             + ' -> '
//             + 'linkage : ' + linkDst + ' ' + kindOfDst;
//             test.description = description;

//             if( kindOfDst === 'terminal' )
//             {
//               o.dst = _.pathJoin( pathDst, 'file.dst' );
//               prepareFile( o.dst, kindOfDst, linkDst );
//             }
//             if( kindOfDst === 'directory' || kindOfDst === 'empty directory' )
//             {
//               debugger
//               o.dst = pathDst;
//               prepareFile( o.dst, kindOfDst, linkDst );
//             }

//             var _srcPath = o.src;

//             if( linkSrc === 'text' )
//             _srcPath = _.pathResolveTextLink( _srcPath );

//             var src = fileStats( _srcPath );
//             var srcFiles = dirRead( _srcPath );
//             var dstFiles = dirRead( o.dst );

//             // if( linkSrc === 'soft' && linkDst === 'ordinary' )
//             // {
//             //   test.shouldThrowError( () => _.fileProvider.filesCopy( o ) )
//             //   .got( ( err, got ) =>
//             //   {
//             //     info.checks.push
//             //     ({
//             //       name : 'soft -> ordinary shouldThrowError',
//             //       res : !_.errIs( err )
//             //     });
//             //   })
//             //   // console.log( _.toStr( got, { levels : 3 } ) );
//             //   compareChecks( info );
//             //   cases.push( info );
//             //   continue;
//             // }
//             // else
//             // {

//               if( linkDst ==='text' )
//               var resolvedDst = _.pathResolveTextLink( o.dst );

//               var got = _.fileProvider.filesCopy( o );

//               if( linkSrc === 'text' )
//               o.src = _.pathResolveTextLink( o.src );

//               if( linkDst ==='text' && kindOfSrc === 'terminal' )
//               o.dst = resolvedDst;

//             // }

//             test.description = description + ', check if src not changed ';
//             /* check if nothing removed from src */
//             var res = test.identical( dirRead( o.src ), srcFiles );
//             info.checks.push({ name : 'check if nothing removed from src', res : res });

//             // if( kindOfSrc === 'empty directory' )
//             // {
//             //   /* check if nothing changed in dst */
//             //   var res = test.identical( dirRead( o.dst ), dstFiles );
//             //   info.checks.push({ name : 'check if nothing changed in dst', res : res });
//             //   compareChecks( info );
//             //   cases.push( info );
//             //   continue;
//             // }
//             if( kindOfSrc === 'empty directory' )
//             {
//               /* dst will be rewritten */
//               if( linkDst === 'text' )
//               o.dst = _.pathResolveTextLink( o.dst );
//               var res = test.identical( dirRead( o.dst ), dirRead( o.src ) );
//               console.log( o.dst )
//               info.checks.push({ name : 'check if dst in rewritten by src', res : res });
//               compareChecks( info );
//               cases.push( info );
//               continue;
//             }

//             test.description = description + ', check if files from src was copied to dst ';

//             debugger;
//             if( kindOfSrc !== 'terminal' &&  kindOfSrc !== 'empty directory' )
//             {
//               if( linkDst === 'text' )
//               o.dst = _.pathResolveTextLink( o.dst );

//               info.checks.push
//               ({
//                 name : 'check if files from src was copied to dst',
//                 res : test.identical( dirRead( o.dst ), srcFiles )
//               });
//             }

//             var dst = fileStats( o.dst );

//             info.checks.push({ name : 'dst exists', res : true });

//             if( !_.objectIs( dst ) )
//             {
//               //dst not exists
//               info.checks[ info.checks.length - 1 ].res = false;
//               _.errLog
//               ( o.dst,
//                 'action : ' + got[ 0 ].action
//                 + ' ' + _.strShort( got[ 0 ].src.real )
//                 + ' -> ' + _.strShort( got[ 0 ].dst.real )
//               );
//               test.identical( 0, 1 );
//               compareChecks( info );
//               cases.push( info );
//               continue;
//             }

//             info.checks.push
//             ({
//               name : 'src.size === dst.size',
//               res : test.identical( src.size, dst.size )
//             });

//             info.checks.push
//             ({
//               name : 'src.isDirectory === dst.isDirectory',
//               res : test.identical( src.isDirectory(), dst.isDirectory() )
//             });

//             compareChecks( info );
//             cases.push( info );
//           }
//         }

//         /* dst is missing */

//         info.presenceOfDst = 'missing';
//         info.kindOfDst = null;
//         info.linkageOfDst = null;
//         info.options = o;
//         delete info.allChecksPassed;
//         delete info.checks;

//         logger.log( _.toStr( info, { levels : 2 } ) );

//         info.checks = [];

//         test.description = 'level : ' + l + ' linkage : ' + linkSrc + ' ' + kindOfSrc + ' dst is missing';

//         _.fileProvider.fileDelete( pathDst );

//         o.dst = pathDst;

//         // if( linkSrc === 'soft' )
//         // {
//         //   test.shouldThrowError( () => _.fileProvider.filesCopy( o ) )
//         //   .got( ( err, got ) =>
//         //   {
//         //     info.checks.push
//         //     ({
//         //       name : 'soft -> missing shouldThrowError',
//         //       res : !_.errIs( err )
//         //     });
//         //   })
//         //   compareChecks( info );
//         //   cases.push( info );
//         //   continue;
//         // }

//         var got = _.fileProvider.filesCopy( o );

//         var dst = fileStats( o.dst );
//         var src = fileStats( o.src );
//         info.checks.push
//         ({
//           name : 'src exists',
//           res : test.identical( _.objectIs( src ), true )
//         })
//         info.checks.push
//         ({
//           name : 'dst exists',
//           res : test.identical( _.objectIs( dst ), true )
//         })
//         if( !_.objectIs( dst ) )
//         {
//           test.identical( 0, 1 );
//           _.errLog( 'action : ' + got[ 0 ].action );
//           compareChecks( info );
//           cases.push( info );
//           continue;
//         }

//         info.checks.push
//         ({
//           name : 'src.size === dst.size',
//           res : test.identical( dst.size, src.size )
//         });
//         info.checks.push
//         ({
//           name : 'src.isDirectory === dst.isDirectory',
//           res : test.identical( dst.isDirectory(), src.isDirectory() )
//         });

//         if( info.kindOfSrc === 'terminal' )
//         {
//           info.checks.push
//           ({
//             name : 'files are equal',
//             res : test.identical( fileRead( o.src ), fileRead( o.dst ) )
//           });
//         }
//         else
//         info.checks.push
//         ({
//           name : 'both paths contains same files',
//           res : test.identical( dirRead( o.dst ), dirRead( o.src ) )
//         });

//         compareChecks( info );
//         cases.push( info );
//       }
//     }
//   }

//   //

//   test.description = 'default options';

//   for( var i = 0 ; i < defaultCases.length ; i++ )
//   {
//     var _case = defaultCases[ i ];
//     _.mapSupplement( _case.o, fixedDefaults );

//     testDirClean();

//     if( _case.pre )
//     _case.pre();

//     var dstBefore = _.fileProvider.directoryRead( _case.o.dst );
//     var srcBefore = _.fileProvider.directoryRead( _case.o.src );

//     if( _case.shouldThrowError )
//     test.shouldThrowError( () => _.fileProvider.filesCopy( _case.o ) );
//     else
//     {
//       var got = _.fileProvider.filesCopy( _case.o );
//       test.shouldBe( _.arrayLike( got ) );
//       test.identical( got.length, 1 );
//       test.shouldBe( _.objectIs( got[ 0 ] ) );
//     }

//     var dstAfter = _.fileProvider.directoryRead( _case.o.dst );
//     var srcAfter = _.fileProvider.directoryRead( _case.o.src );

//     test.identical( dstBefore, dstAfter );
//     test.identical( srcBefore, srcAfter );

//   }

//   /* */

//   var n = 1;
//   cases.forEach( ( info ) =>
//   {
//     console.log( '#' + n++ );
//     console.log
//     ({
//       'Level' : info.level,
//       'presenceOfSrc' : info.presenceOfSrc,
//       'kindOfSrc' : info.kindOfSrc,
//       'linkageOfSrc' : info.linkageOfSrc,
//       'presenceOfDst' : info.presenceOfDst,
//       'kindOfDst' : info.kindOfDst,
//       'linkageOfDst' : info.linkageOfDst,
//       'allChecksPassed' : info.allChecksPassed
//     });
//     console.log( 'Cheks : ', _.toStr( info.checks, { levels : 3 } ) );
//   });

// }

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
    dst : pathDst,
    src : pathSrc
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
    testDirClean();

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

    o.src = pathSrc;
    o.dst = pathDst;

    if( src.type === 'terminal' )
    o.src = _.pathJoin( pathSrc, 'file.src' );

    o.src = prepareFile( o.src, src.type,src.linkage, src.level );
    o.dst = prepareFile( o.dst, null, null, src.level );

    var options = _.mapSupplement( o, fixedOptions );

    /* */

    var statsSrcBefore = fileStats( o.src );

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
      testDirClean();

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

      o.src = pathSrc;
      o.dst = pathDst;

      if( src.type === 'terminal' )
      o.src = _.pathJoin( pathSrc, 'file.src' );

      if( dst.type === 'terminal' )
      o.dst = _.pathJoin( pathDst, 'file.dst' );

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
    testDirClean();

    var info =
    {
      n : ++n,
      src : null,
      dst : dst,
      checks : []
    };

    test.description = _.toStr( { src : null, dst : dst }, { levels : 2, wrap : 0 } );

    /* prepare to run filesCopy */

    o.src = pathSrc;
    o.dst = pathDst;

    // console.log( _.toStr( o, { levels : 3 } ) )

    if( dst.type === 'terminal' )
    o.dst = _.pathJoin( pathDst, 'file.dst' );

    o.dst = prepareFile( o.dst, dst.type, dst.linkage, dst.level );
    o.src = prepareFile( o.src, null, null, dst.level );

    var options = _.mapSupplement( o, fixedOptions );

    /* */

    var statsDstBefore = fileStats( o.dst );

    test.shouldThrowError( () => _.fileProvider.filesCopy( options ) )

    var statsSrc = fileStats( o.src );
    var statsDst = fileStats( o.dst );

    /* check if dst wasnt changed */

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

    testDirClean();

    o.src = pathSrc;
    o.dst = pathDst;

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

  // name : 'FilesCopy',
  // verbosity : 0,
  silencing : 1,

  tests :
  {
    filesCopy : filesCopy,
  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

})();
