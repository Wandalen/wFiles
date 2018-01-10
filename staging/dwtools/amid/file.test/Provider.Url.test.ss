( function _FileProvider_Url_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = wTools;
var Parent = wTests[ 'FileProvider' ];
var HardDrive = _.FileProvider.HardDrive();

_.assert( Parent );

//

function testDirMake( test )
{
  var self = this;
  self.testRootDirectory = _.dirTempMake( _.pathJoin( __dirname, '../..'  ) );
}

//

function testDirClean()
{
  var self = this;
  HardDrive.fileDelete( self.testRootDirectory );
}

//

function fileRead( test )
{
  var con = new wConsequence().give()

  .doThen( () =>
  {
    test.description = 'unavailbe path';

    var o = { filePath : this.testFile + 'xxx', sync : 0 };
    var got = this.provider.fileRead( o );
    return test.shouldThrowError( got );
  })

  .doThen( () =>
  {
    test.description = 'get a avaible path';

    var o = { filePath : this.testFile, sync : 0 };
    return this.provider.fileRead( o )
    .doThen( ( err, got ) =>
    {
      test.shouldBe( _.strHas( got, '# wTools' ) )
    })
  })

  .doThen( () =>
  {
    test.description = 'get a avaible path';

    var url = 'https://www.npmjs.com/search?q=wTools'
    var o = { filePath : url, sync : 0 };
    return this.provider.fileRead( o )
    .doThen( ( err, got ) =>
    {
      test.shouldBe( _.strBegins( got, '<!DOCTYPE' ) )
    })
  })

  return con;
}

//

function fileCopyToHardDrive( test )
{
  var filePath = _.pathJoin( this.testRootDirectory, test.name, _.pathName( this.testFile ) );
  var con = new wConsequence().give()

  //

  .doThen( () =>
  {
    test.description = 'unavailable url';
    var o =
    {
      url : 'abc',
      filePath : filePath,
    }
    var got = this.provider.fileCopyToHardDrive( o );
    return test.shouldThrowError( got );
  })

  //

  .doThen( () =>
  {
    test.description = 'save file from the url to a hard drive';
    var o =
    {
      url : this.testFile,
      filePath : filePath,
    }
    return this.provider.fileCopyToHardDrive( o )
    .doThen( ( err, got ) =>
    {
      var file = HardDrive.fileRead( got );

      o =
      {
        filePath : this.testFile,
        sync : 0
      }

      return this.provider.fileRead( o )
      .doThen( ( err, got ) => test.identical( got, file ) )
    })
  })

  return con;
}


// --
// proto
// --

var Proto =
{

  name : 'FileProvider.BackUrl',
  silencing : 1,
  abstract : 0,

  onSuitBegin : testDirMake,
  onSuitEnd : testDirClean,

  context :
  {
    provider : _.FileProvider.UrlBack(),
    testFile : 'https://raw.githubusercontent.com/Wandalen/wTools/master/README.md',
  },

  tests :
  {
    fileRead : fileRead,
    fileCopyToHardDrive : fileCopyToHardDrive
  },

}

//

// debugger;
// if( typeof module !== 'undefined' )
// var Self = new wTestSuite( Parent ).extendBy( Proto );

var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

if( 0 )
if( isBrowser )
{
  Self = new wTestSuite( Parent ).extendBy( Self );
  _.Tester.test( Self.name );
}

})( );
