( function _FileFilter_Archive_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  try
  {
    require( '../../../Base.s' );
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
var Parent = wTools.Tester;
var provider = _.FileFilter.Archive();

var testDir = _.fileProvider.pathNativize( _.pathResolve( __dirname + '/../../../../tmp.tmp/Filter.Archive' ) );

function flatMapFromTree( tree, currentPath, paths )
{
  if( paths === undefined )
  {
    paths = Object.create( null );
  }

  if( !paths[ currentPath ] )
  paths[ currentPath ] = Object.create( null );

  for( var k in tree )
  {
    if( _.objectIs( tree[ k ] ) )
    {
      paths[ _.pathResolve( currentPath, k ) ] = Object.create( null );

      flatMapFromTree( tree[ k ], _.pathJoin( currentPath, k ), paths );
    }
    else
    paths[ _.pathResolve( currentPath, k ) ] = tree[ k ];
  }

  return paths;
}

//

function linkWorks( paths )
{
  var dir = _.pathCommon( paths );
  var tree = provider.filesTreeRead({ glob : dir, asFlatMap : 1 });
  for( var i = 1; i <= paths.length - 1; i++ )
  {
    if( tree[ paths[ 0 ] ] !== tree[ paths[ i ] ] )
    return false;
  }

  return true;
}

//

function archive( test )
{
  test.description = 'multilevel files tree';

  /* prepare tree */

  var filesTree =
  {
    a  :
    {
      b  :
      {
        c  :
        {
          d :
          {
            a  : '1',
            b  : '2',
            c  : '3'
          },
        },
      },
    },
  }

  _.fileProvider.fileDelete( testDir );
  _.fileProvider.filesTreeWrite
  ({
    filesTree : filesTree,
    filePath : testDir
  });

  var provider = _.FileFilter.Archive();
  provider.archive.trackPath = testDir;
  provider.archive.verbosity = 0;
  provider.archive.fileMapAutosaving = 1;
  provider.archive.archiveUpdateFileMap();

  /* check if map contains expected files */

  var flatMap = flatMapFromTree( filesTree, provider.archive.trackPath );
  var got = _.mapOwnKeys( provider.archive.fileMap );
  var expected = _.mapOwnKeys( flatMap );
  test.shouldBe( _.arraySetIdentical( got, expected ) );

  /* check if each file from map has some info inside */

  var allFilesHaveInfo = true;
  got.forEach( ( path ) =>
  {
    var info = provider.archive.fileMap[ path ];
    allFilesHaveInfo &= _.mapOwnKeys( info ).length > 0;
  });
  test.shouldBe( allFilesHaveInfo );

  /* check how archive saves fileMap of disk */

  var archivePath = _.pathJoin( provider.archive.trackPath, provider.archive.archiveFileName );
  var savedOnDisk = !!provider.fileStat( archivePath );
  test.shouldBe( savedOnDisk );
  var arcive = provider.fileReadJson( archivePath );
  test.identical( arcive, provider.archive.fileMap );
}

//

function linkage( test )
{
  provider = _.FileFilter.Archive();
  provider.archive.trackPath = testDir;
  provider.archive.verbosity = 0;
  provider.archive.fileMapAutosaving = 0;
  provider.archive.trackingHardLinks = 1;

  //

  test.description = 'three files linked, second link will be broken';
  provider.fileDelete( testDir );
  var paths = [ 'a', 'b', 'c' ];
  paths.forEach( ( p, i ) =>
  {
    paths[ i ] = _.pathJoin( testDir, p );
    provider.fileWrite( paths[ i ], 'abc' );
  });
  provider.linkHard({ filePathes : paths });
  provider.archive.restoreLinksBegin();
  provider.fileTouch({ filePath : paths[ 0 ], purging : 1 });
  provider.fileWrite( paths[ 1 ], 'bcd' );
  test.identical( linkWorks( paths ), false );
  provider.archive.restoreLinksEnd();
  test.identical( linkWorks( paths ), true );

  //

  test.description = 'three files linked,all links will be broken';
  provider.fileDelete( testDir );
  var paths = [ 'a', 'b', 'c' ];
  paths.forEach( ( p, i ) =>
  {
    paths[ i ] = _.pathJoin( testDir, p );
    provider.fileWrite( paths[ i ], 'abc' );
  });
  provider.linkHard({ filePathes : paths });
  provider.archive.restoreLinksBegin();
  paths.forEach( ( p, i ) =>
  {
    provider.fileTouch({ filePath : p, purging : 1 });
    provider.fileWrite( p, '' + i );
  })
  test.identical( linkWorks( paths ), false );
  provider.archive.restoreLinksEnd();
  test.identical( linkWorks( paths ), true );

  //

  test.description = 'three files linked, size of first is changed after breaking the link'
  var paths = [ 'a', 'b', 'c' ];
  provider.fileDelete( testDir );
  paths.forEach( ( p, i ) =>
  {
    paths[ i ] = _.pathJoin( testDir, p );
    provider.fileWrite( paths[ i ], 'abc' );
  });
  provider.linkHard({ filePathes : paths });
  provider.archive.restoreLinksBegin();
  provider.fileTouch({ filePath : paths[ 0 ], purging : 1 });
  provider.fileWrite( paths[ 0 ], 'abcd' );
  test.identical( linkWorks( paths ), false );
  test.shouldThrowError( () => provider.archive.restoreLinksEnd() );

  //

  test.description = 'special case'
  var paths =
  [
    'a1','a2','a3',
    'b1','b2','b3','b4','b5',
    'c',
    'd'
  ];
  provider.fileDelete( testDir );
  paths.forEach( ( p, i ) =>
  {
    paths[ i ] = _.pathJoin( testDir, p );
    var data;
    if( i <= 2 )
    data = '3';
    else if( i <= 7 )
    data = '5'
    else
    data = '' + i;
    provider.fileWrite( paths[ i ], data );
  });

  /* make links and save info in archive */

  provider.linkHard({ filePathes : paths.slice( 0, 3 ) });
  provider.linkHard({ filePathes : paths.slice( 3, 8 ) });
  provider.archive.restoreLinksBegin();

  /* remove some links and check if they are broken */

  provider.fileTouch({ filePath : paths[ 0 ], purging : 1 });
  provider.fileTouch({ filePath : paths[ 3 ], purging : 1 });
  provider.fileWrite( paths[ 0 ], 'a' );
  provider.fileWrite( paths[ 3 ], 'b' );
  test.identical( linkWorks( paths.slice( 0, 3 ) ), false );
  test.identical( linkWorks( paths.slice( 3, 8 ) ), false );
  test.shouldBe( provider.fileRead( paths[ 8 ] ) !== provider.fileRead( paths[ 9 ] ) );

  /* restore links and check if they works now */

  provider.archive.restoreLinksEnd();
  test.identical( linkWorks( paths.slice( 0, 3 ) ), true );
  test.identical( linkWorks( paths.slice( 3, 8 ) ), true );
  test.shouldBe( provider.fileRead( paths[ 8 ] ) !== provider.fileRead( paths[ 9 ] ) );

  //

  test.description = 'three files linked, fourth is linked with the third file';
  provider.fileDelete( testDir );
  var paths = [ 'a', 'b', 'c' ];
  paths.forEach( ( p, i ) =>
  {
    paths[ i ] = _.pathJoin( testDir, p );
    provider.fileWrite( paths[ i ], 'abc' );
  });
  provider.linkHard({ filePathes : paths });

  /* linking fourth with second and saving info */

  var fourth = _.pathJoin( testDir, 'e' );
  provider.linkHard( fourth, paths[ paths.length - 1 ] );
  provider.archive.restoreLinksBegin();

  /*  breaking linkage and changing it content */

  provider.fileTouch({ filePath : paths[ 0 ], purging : 1 });
  provider.fileWrite( paths[ 0 ], 'bcd' );

  /*  checking if linkage is broken  */

  test.identical( linkWorks( paths ), false );
  test.shouldBe( provider.fileRead( paths[ 0 ] ) !== provider.fileRead( fourth ) );
  test.identical( provider.fileRead( paths[ paths.length - 1 ] ), provider.fileRead( fourth ) );

  /*  restoring linkage  */

  provider.archive.restoreLinksEnd();
  paths.push( fourth );
  test.identical( linkWorks( paths ), true );

  //


}

//

function experiment( test )
{
  provider = _.FileFilter.Archive();
  provider.archive.trackPath = testDir;
  provider.archive.verbosity = 0;
  provider.archive.fileMapAutosaving = 0;
  provider.archive.trackingHardLinks = 1;
  provider.resolvingSoftLink = 1;

  function linkWorks( paths )
  {
    var dir = _.pathCommon( paths );
    var tree = provider.filesTreeRead({ glob : dir, asFlatMap : 1 });
    for( var i = 1; i <= paths.length - 1; i++ )
    {
      if( tree[ paths[ 0 ] ] !== tree[ paths[ i ] ] )
      return false;
    }

    return true;
  }

  //

  test.description = 'three files linked, size of file is changed';
  var paths = [ 'a', 'b', 'c' ];
  provider.fileDelete( testDir );
  paths.forEach( ( p, i ) =>
  {
    paths[ i ] = _.pathJoin( testDir, p );
    provider.fileWrite( paths[ i ], 'abc' );
  });
  provider.linkHard({ filePathes : paths });
  provider.archive.restoreLinksBegin();
  provider.fileTouch({ filePath : paths[ 0 ], purging : 1 });
  /* changing size of a file */
  provider.fileWrite( paths[ 0 ], 'abcd' );
  provider.archive.restoreLinksEnd();
  /* checking if link was recovered but comparing content of a files */
  test.identical( linkWorks( paths ), true );

  //

  test.description = 'three files linked, changing content of a file, but saving size';
  var paths = [ 'a', 'b', 'c' ];
  provider.fileDelete( testDir );
  paths.forEach( ( p, i ) =>
  {
    paths[ i ] = _.pathJoin( testDir, p );
    provider.fileWrite( paths[ i ], 'abc' );
  });
  provider.linkHard({ filePathes : paths });
  provider.archive.restoreLinksBegin();
  provider.fileTouch({ filePath : paths[ 0 ], purging : 1 });
  /* changing size of a file */
  provider.fileWrite( paths[ 0 ], 'cad' );
  provider.archive.restoreLinksEnd();
  /* checking if link was recovered but comparing content of a files */
  test.identical( linkWorks( paths ), true );
}

// --
// proto
// --

var Self =
{

  name : 'FileFilter.Archive',
  silencing : 1,
  // verbosity : 10,

  tests :
  {
    archive : archive,
    linkage : linkage,
    experiment : experiment
  },

};


Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
