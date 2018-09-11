( function _FileProvider_Url_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = _global_.wTools;
var Parent = wTests[ 'Tools/mid/files/fileProvider/Abstract' ];
var HardDrive = _.FileProvider.HardDrive();

_.assert( !!Parent );

//

function onSuiteBegin( test )
{
  var self = this;
  self.testRootDirectory = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ), 'Provider/Url' );
}

//

function onSuiteEnd()
{
  var self = this;
  _.assert( _.strEnds( self.testRootDirectory, 'Provider/Url' ) );
  _.path.dirTempClose( this.testRootDirectory );
}

//

function fileRead( test )
{
  var con = new _.Consequence().give()

  .doThen( () =>
  {
    test.case = 'unavailbe path';

    var o = { filePath : this.testFile + 'xxx', sync : 0 };
    var got = this.provider.fileRead( o );
    return test.shouldThrowError( got );
  })

  .doThen( () =>
  {
    test.case = 'get a avaible path';

    var o = { filePath : this.testFile, sync : 0 };
    return this.provider.fileRead( o )
    .doThen( ( err, got ) =>
    {
      test.is( _.strHas( got, '# wTools' ) )
    })
  })

  .doThen( () =>
  {
    test.case = 'get a avaible path';

    var url = 'https://www.npmjs.com/search?q=wTools'
    var o = { filePath : url, sync : 0 };
    return this.provider.fileRead( o )
    .doThen( ( err, got ) =>
    {
      test.is( _.strBegins( got, '<!DOCTYPE' ) )
    })
  })

  return con;
}

//

function fileCopyToHardDrive( test )
{
  var filePath = _.path.join( this.testRootDirectory, test.name, _.path.name( this.testFile ) );
  var con = new _.Consequence().give()

  //

  .doThen( () =>
  {
    test.case = 'unavailable url';
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
    test.case = 'save file from the url to a hard drive';
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
// declare
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/UrlServer',
  silencing : 1,
  abstract : 0,
  enabled : 0, // !!! experimental

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

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

// if( 0 )
// {
//   Self = new wTestSuite( Parent ).extendBy( Self );
//   _.Tester.test( Self.name );
// }

})( );
