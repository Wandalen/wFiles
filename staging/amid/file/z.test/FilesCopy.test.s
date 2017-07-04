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
  var linkage = [ 'ordinary', 'soft', 'text' ];
  var levels = 1;

  var counter = 0;
  var currentLevel = null;
  var info;
  var kindOfSrc = null;
  var kindOfDst = null;
  var linkSrc = null;
  var linkDst = null;
  var presenceOfSrc, presenceOfDst;

  var report = [];
  var got;

  //

  function prepareCaseInfo()
  {
    var info =
    {
      presenceOfSrc : presenceOfSrc,
      kindOfSrc : null,
      linkageOfSrc : null,
      presenceOfDst : presenceOfDst,
      kindOfDst : null,
      linkageOfDst : null
    };

    var description = ` level : ${currentLevel}, `;

    if( presenceOfSrc === 'present' )
    {
      info.kindOfSrc = kindOfSrc;
      info.linkageOfSrc = linkSrc;
      description += `${kindOfSrc} x ${linkSrc} -> `;
    }

    if( presenceOfSrc === 'missing' )
    description += 'src missing -> ';

    if( presenceOfDst === 'present' )
    {
      info.kindOfDst = kindOfDst;
      info.linkageOfDst = linkDst;
      description += ` ${kindOfDst} x ${linkDst}`;
    }

    if( presenceOfDst === 'missing' )
    description += ' dst missing';

    test.description = description;

    counter++;
    logger.log( 'Case : ' + counter );

    report.push( [ counter + description ] )

    logger.log( _.toStr( info, { levels : 2 } ) );
  }

  //

  function prepareFile( kind, path, fileName, link )
  {
    var pathDir = path;

    if( kind === 'terminal' || kind === 'directory' )
    {
      path = _.pathJoin( path, fileName );
      fileMake( path );

      if( kind === 'directory' )
      path = pathDir;
    }

    if( kind === 'empty directory'  )
    {
      _.fileProvider.directoryMake( path );
      path = pathDir;
    }

    if( link === 'soft' )
    {
      _.fileProvider.linkSoft( path + '.soft', path )
      path += '.soft';
    }

    if( link === 'text' )
    {
      _.fileProvider.fileWrite( path + '.txt', 'link ' + path );
      path += '.txt';
    }

    return path;
  }

  //

  function checkDst()
  {
    var src = o.src;
    var dst = o.dst;

    if( linkSrc === 'text' )
    src = _.pathResolveTextLink( src );

    if( linkDst === 'text' )
    dst = _.pathResolveTextLink( dst );

    if( !_.objectIs( fileStats( dst ) ) )
    {
      test.identical( 0, 1 )
      _.errLog( _.toStr( got, { levels : 3 } ) );
    }
    else
    {
      if( kindOfSrc === 'terminal' )
      test.identical( fileRead( dst ), fileRead( src ) );

      if( kindOfSrc === 'directory' )
      test.contain( dirRead( dst ), dirRead( src ) );

      if( kindOfSrc === 'empty directory' )
      test.identical( dirRead( dst ), [] );
    }

    _.fileProvider.fileDelete( o.dst );
  }

  //

  function testDst()
  {
    for( var k = 0; k < presenceOfFile.length; k++ )
    {
      presenceOfDst = presenceOfFile[ k ];

      if( presenceOfDst === 'present' )
      {
        for( var m = 0; m < typeOfFiles.length; m++ )
        {
          kindOfDst= typeOfFiles[ m ];

          for( var n = 0; n < linkage.length; n++ )
          {
            o.dst = pathDst;

            _.fileProvider.fileDelete( o.dst );

            linkDst = linkage[ n ];

            var fileNameDst = 'file.dst';

            o.dst = prepareFile( kindOfDst, o.dst, fileNameDst, linkDst  );

            prepareCaseInfo();

            if( presenceOfSrc === 'missing' )
            {
              test.shouldThrowError( () => _.fileProvider.filesCopy( o ) );
              continue;
            }

            try
            {
              got = _.fileProvider.filesCopy( o );
            }
            catch ( err )
            {
              test.identical( 0, 1 )
              _.errLog( err );
            }

            checkDst();
          }
        }
      }

      if( presenceOfDst === 'missing' )
      {
        _.fileProvider.fileDelete( o.dst );

        prepareCaseInfo();

        if( presenceOfSrc === 'missing' )
        {
          test.shouldThrowError( () => _.fileProvider.filesCopy( o ) );
          continue;
        }

        got = _.fileProvider.filesCopy( o );

        checkDst();
      }
    }
  }

  //

  for( var level = 0; level < levels; level++ )
  {
    o.src = pathSrc;

    currentLevel = level;

    if( level > 0  )
    {
      for( var l = 1 ; l <= level; l++ )
      o.src = _.pathJoin( o.src, 'level' + l );
    }

    var pathSrcLevels = o.src;

    for( var i = 0; i < presenceOfFile.length; i++ )
    {
      presenceOfSrc = presenceOfFile[ i ];

      if( presenceOfSrc === 'present' )
      {
        for( var t = 0; t < typeOfFiles.length; t++ )
        {
          kindOfSrc = typeOfFiles[ t ];

          for( var l = 0; l < linkage.length; l++ )
          {
            cleanTestDir();

            linkSrc = linkage[ l ];

            o.src = pathSrcLevels;

            var fileNameSrc= 'file.src';

            o.src = prepareFile( kindOfSrc, o.src, fileNameSrc, linkSrc  );

            testDst();
          }
        }
      }

      if( presenceOfSrc === 'missing' )
      {
        cleanTestDir();
        o.src = _.pathJoin( pathSrcLevels, 'file.src' );
        o.dst = pathDst;

        var path = o.src
        for( var k = currentLevel ; k >= 0; k-- )
        path = _.pathDir( path );

        _.fileProvider.directoryMake( path );

        testDst();
      }
    }
  }

  /* report */

  logger.log( 'Report : ', _.toStr( report, { levels : 3, wrap : 0, multiline : 1 } ));
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
