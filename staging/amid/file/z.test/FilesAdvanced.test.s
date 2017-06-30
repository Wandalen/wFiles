( function _Files_Advanced_test_s_( ) {

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

}

//

var _ = wTools;
var Parent = wTools.Testing;
var rootDir = _.pathResolve( __dirname + '/../../../../tmp.tmp'  );

//

/* Map of test cases
    * level : 0, 1, 2
  (
    presence of file : missing, present
    +
    if present
    (
      * kind of file : empty directory, not empty directory, terminal
      * linkage of file : ordinary, softlink, textlink
    )
  )
  ^ where file : src, dst
  3 * ( 1 + 3 * 3  ) ^ 2 = 3 * 10 ^ 2 = 300
*/

/*
                  dst          kind of file x linkage of file
          src                  -----------------------------
kind of file x linkage of file |
                               |
                               |
                               |
                               |
                               |
*/

//

var testDir = _.pathResolve( __dirname, '../../../../tmp.tmp/filesCopy' );

var fileRead = ( path ) => _.fileProvider.fileRead( path );
var dirRead = ( path ) => _.fileProvider.directoryRead( path );
var cleanTestDir = () => _.fileProvider.fileDelete( testDir );
var fileMake = ( path ) => _.fileProvider.fileWrite( path, path );
var fileStats = ( path ) => _.fileProvider.fileStat( path );

var pathDst = _.pathJoin( testDir, 'dst' );
var pathSrc = _.pathJoin( testDir, 'src' );

var filePathSrc = _.pathJoin( pathSrc, 'file.src' );
var filePathDst = _.pathJoin( pathDst, 'file.dst' );
var filePathSoftSrc = _.pathJoin( pathSrc, 'file.soft.src' );
var filePathSoftDst = _.pathJoin( pathDst, 'file.soft.dst' );

//

function filesCopyDefaults( test )
{
  var fixedDefaults =
  {
    allowDelete : 0,
    allowWrite : 0,
    allowRewrite : 0,
    allowRewriteFileByDir : 0,
  }

  var defaultCases =
  [
    {
      o : { dst : pathDst, src : pathSrc },
      shouldThrowError : true,
    },
    {
      o : { dst : pathDst, src : filePathSoftSrc },
      pre : function ()
      {
        _.fileProvider.fileWrite( filePathSrc, 'src' );
        _.fileProvider.linkSoft( filePathSoftSrc, filePathSrc );
      },
      shouldThrowError : true,
    },

  ]

  //

  test.description = 'default options';

  var counter = 0;

  for( var i = 0; i < defaultCases.length; i++ )
  {
    var _case = defaultCases[ i ];
    _.mapSupplement( _case.o, fixedDefaults );

    counter++;
    logger.log( 'Case : ' + counter );

    cleanTestDir();

    if( _case.pre )
    _case.pre();

    var dstBefore = _.fileProvider.directoryRead( _case.o.dst );
    var srcBefore = _.fileProvider.directoryRead( _case.o.src );

    if( _case.shouldThrowError )
    test.shouldThrowError( () => _.fileProvider.filesCopy( _case.o ) );
    else
    {
      var got = _.fileProvider.filesCopy( _case.o );
      test.shouldBe( _.arrayLike( got ) );
      test.identical( got.length, 1 );
      test.shouldBe( _.objectIs( got[ 0 ] ) );
    }

    var dstAfter = _.fileProvider.directoryRead( _case.o.dst );
    var srcAfter = _.fileProvider.directoryRead( _case.o.src );

    test.identical( dstBefore, dstAfter );
    test.identical( srcBefore, srcAfter );

  }
}

//

function filesCopy( test )
{

  var fixedOptions =
  {
    allowDelete : 1,
    allowWrite : 1,
    allowRewrite : 1,
    allowRewriteFileByDir : 1,
    recursive : 1,
    usingLinking : 1,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }

  var o =
  {
    dst : null,
    src : null
  };

  _.mapSupplement( o, fixedOptions );

  var typeOfFiles = [ 'terminal', 'empty directory', 'directory' ];
  var presenceOfFile = [ 'missing', 'present' ]
  var linkage = [ 'ordinary', 'soft' ];
  var levels = 1;

  var counter = 0;
  var info;
  var kindOfSrc, kindOfDst;
  var linkSrc, linkDst;
  var presenceOfSrc, presenceOfDst;

  var report = [];

  //

  function dstIsPresent()
  {
    for( var x = 0; x < linkage.length; x++ )
    {
      linkDst = linkage[ x ];
      for( var j = 0; j < typeOfFiles.length; j++ )
      {
        _.fileProvider.fileDelete( pathDst );

        kindOfDst = typeOfFiles[ j ];

        info.presenceOfDst = 'present';
        info.kindOfDst = kindOfDst;
        info.linkageOfDst = linkDst;


        counter++;
        logger.log( 'Case : ' + counter );

        report.push( [ kindOfSrc + ' x ' + linkSrc, kindOfDst + ' x ' + linkDst, counter ] )

        logger.log( _.toStr( info, { levels : 2 } ) );

        var description =
        ' linkage : ' + linkSrc + ' ' + kindOfSrc
        + ' -> '
        + 'linkage : ' + linkDst + ' ' + kindOfDst;
        test.description = description;

        o.dst = pathDst;

        if( kindOfDst === 'terminal' || kindOfDst === 'directory' )
        {
          var fileNameDst= 'file.dst';

          o.dst = _.pathJoin( o.dst, fileNameDst );
          fileMake( o.dst );

          if( kindOfDst === 'directory' )
          o.dst = pathDst;
        }

        if( kindOfDst === 'empty directory'  )
        {
          _.fileProvider.directoryMake( o.dst );
          o.dst = pathDst;
        }

        if( linkDst === 'soft' )
        {
          _.fileProvider.linkSoft( o.dst + '.soft', o.dst )
          o.dst += '.soft';
        }

        var src = fileStats( o.src );
        var srcFiles = dirRead( o.src );
        var dstFiles = dirRead( o.dst );

        // if( linkSrc === 'soft'  )
        // {
        //   if( linkDst === 'ordinary' )
        //   {
        //     test.shouldThrowError( () => _.fileProvider.filesCopy( o ) )
        //     // console.log( _.toStr( got, { levels : 3 } ) );
        //     continue;
        //   }
        // }
        // else
        var got;
        try
        {
          got = _.fileProvider.filesCopy( o );
        }
        catch ( err )
        {
          test.identical( 0, 1 )
          _.errLog( err );
        }

        test.description = description + ', check if src not changed ';
        /* check if nothing removed from src */
        test.identical( dirRead( o.src ), srcFiles );

        if( kindOfSrc === 'empty directory' )
        {
          /* check if nothing changed in dst */
          test.identical( dirRead( o.dst ), dstFiles );
          continue;
        }

        test.description = description + ', check if files from src was copied to dst ';

        if( kindOfSrc !== 'terminal' &&  kindOfSrc !== 'empty directory' )
        test.identical( dirRead( o.dst ), srcFiles );

        var dst = fileStats( o.dst );

        if( !_.objectIs( dst ) )
        {
          _.errLog
          (
            // 'action : ' + got[ 0 ].action
            // + ' ' + _.strShort( got[ 0 ].src.real )
            // + ' -> ' + _.strShort( got[ 0 ].dst.real )
            _.toStr( got[ 0 ], { levels : 3 } )
          );
          test.identical( 0, 1 );
          continue;
        }

        test.identical( src.size, dst.size );
        test.identical( src.isDirectory(), src.isDirectory() );
      }
    }
  }

  //

  function dstIsMissing()
  {
    counter += 1;
    logger.log( 'Case : ' + counter );

    report.push( [ kindOfSrc + ' x ' + linkSrc, 'missing', counter ] )

    info.presenceOfDst = 'missing';
    info.kindOfDst = null;
    info.linkageOfDst = null;
    logger.log( _.toStr( info, { levels : 2 } ) );

    test.description = ' linkage : ' + linkSrc + ' ' + kindOfSrc + ' dst is missing';

    _.fileProvider.fileDelete( pathDst );

    o.dst = pathDst;

    // if( linkSrc === 'soft' )
    // {
    //   test.shouldThrowError( () => _.fileProvider.filesCopy( o ) );
    //   continue;
    // }

    var got = _.fileProvider.filesCopy( o );

    var dst = fileStats( o.dst );
    var src = fileStats( o.src );
    test.identical( _.objectIs( src ), true );
    test.identical( _.objectIs( dst ), true );
    if( !_.objectIs( dst ) )
    {
      test.identical( 0, 1 );
      _.errLog( 'action : ' + got[ 0 ].action );
      // return;
    }
    else
    {
      test.identical( dst.size, src.size );
      test.identical( dst.isDirectory(), src.isDirectory() );
      test.identical( dirRead( o.dst ), dirRead( o.src ) );
    }


  }

  //

  function runTestCases()
  {
    for( var l = 0 ; l < levels ; l++ )
    {
      for( var i = 0 ; i < presenceOfFile.length ; i++ )
      {
        cleanTestDir();

        presenceOfSrc = presenceOfFile[ i ];

        o.src = pathSrc;

        if( l > 0  )
        {
          for( var j = 1 ; j <= l; j++ )
          o.src = _.pathJoin( o.src, 'level' + j );
        }

        info =
        {
          level : l,
          presenceOfSrc : presenceOfSrc,
        }

        if( presenceOfSrc === 'present' )
        {
          if( kindOfSrc === 'terminal' || kindOfSrc === 'directory' )
          {
            var fileNameSrc = 'file.src';

            o.src = _.pathJoin( o.src, fileNameSrc );
            fileMake( o.src );

            if( kindOfSrc === 'directory' )
            o.src = pathSrc;
          }

          if( kindOfSrc === 'empty directory'  )
          {
            _.fileProvider.directoryMake( o.src );
            o.src = pathSrc;
          }

          if( linkSrc === 'soft' )
          {
            _.fileProvider.linkSoft( o.src + '.soft', o.src )
            o.src += '.soft';
          }

          info.kindOfSrc = kindOfSrc;
          info.linkageOfSrc = linkSrc;

          /* dst is present */

          dstIsPresent();

          /* dst is missing */

          dstIsMissing( kindOfSrc, linkSrc );
        }

        if( presenceOfSrc === 'missing' )
        {
          o.src = _.pathJoin( o.src, 'file.src' );

          var path = o.src
          for( var k = l ; k >= 0; k-- )
          path = _.pathDir( path );

          _.fileProvider.directoryMake( path );

          test.description = 'src missing';

          counter++;
          logger.log( 'Case #:' + counter );

          report.push( [ 'missing', 'missing', counter ] )

          logger.log( _.toStr( info, { levels : 2 } ) );
          test.shouldThrowError( () => _.fileProvider.filesCopy( o ) );
        }
      }
    }
  }

  /* src is present -> dst present/missing */

  for( var k = 0; k < linkage.length; k++ )
  {
    linkSrc = linkage[ k ];
    for( var i = 0; i < typeOfFiles.length; i++ )
    {
      kindOfSrc = typeOfFiles[ i ];
      runTestCases();
    }
  }

  for( var i = 0; i < report.length; i++ )
  {
    console.log( ` #${ report[ i ][ 2 ] }  ` + ' | ', `src :  ${ report[ i ][ 0 ] }  `, ' | ', ` dst : ${ report[ i ][ 1 ] }`  );
  }


}

// --
// proto
// --

var Self =
{

  name : 'FilesAdvancedTest',
  // verbosity : 0,

  tests :
  {
    // filesCopyDefaults : filesCopyDefaults,
    filesCopy : filesCopy,
  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

})();
