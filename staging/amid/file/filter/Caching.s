( function _Caching_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../aprovider/Abstract.s' );

}

wTools.FileFilter = wTools.FileFilter || Object.create( null );
if( wTools.FileFilter.Caching )
return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
var Default = _.FileProvider.Default;
var Parent = null;
var Self = function wFileFilterCaching( o )
{
  if( !( this instanceof Self ) )
  return Self.prototype.init.apply( this,arguments );
  throw _.err( 'Call wFileFilterCaching without new please' );
}

Self.nameShort = 'Caching';

//

function init( o )
{

  var self = _.instanceFilterInit
  ({
    constructor : Self,
    parent : Parent,
    extend : Extend,
    args : arguments,
  });

  // x
  //
  // var self = Object.create( null );
  //
  // _.instanceInit( self,Self.prototype );
  //
  // if( o )
  // Self.prototype.copyCustom.call( self,
  // {
  //   proto : Self.prototype,
  //   src : o,
  //   technique : 'object',
  // });
  //
  // if( !self.original )
  // self.original = _.FileProvider.Default();
  //
  // _.mapExtend( self,Extend );
  //
  // Object.setPrototypeOf( self,self.original );
  // Object.preventExtensions( self );

  return self;
}

//

function fileStat( o )
{
  var self = this; 

  if( !self.cachingStats )
  return self.original.fileStat( o );

  // var original = self.original.fileStat;

  // var o = _._fileOptionsGet.apply( original,arguments );
  // var filePath = o;

  // debugger;

  if( self._cacheStats[ o ] !== undefined )
  {
    // if( o.sync )
    return self._cacheStats[ o ];
    // else
    // return new wConsequence().give( result );
  }
  else
  {

    if( _.strIs( o ) )
    {
      o = _.pathResolve( o );
      if( self._cacheStats[ o ] !== undefined )
      return  self._cacheStats[ o ];
    }
    else if( _.objectIs( o ) )
    {
      // o = _.routineOptions( fileStat,o )
      // o = _.pathResolve( o );
      if( o.sync === undefined )
      o.sync = 1;

      o.filePath = _.pathResolve( o.filePath );
      if( self._cacheStats[ o.filePath ] )
      {
        if( o.sync )
        return self._cacheStats[ o.filePath ];
        else
        return wConsequence().give( self._cacheStats[ o.filePath ] );
      }
    }

    // console.log( 'fileStat' );
    var stat = self.original.fileStat( o );

    // console.log( o );

    if( _.strIs( o ) )
    self._cacheStats[ o ] = stat;
    else
    {
      if( o.sync )
      self._cacheStats[ o.filePath ] = stat;
      else
      stat.got( function( err, got )
      {
        self._cacheStats[ o.filePath ] = got;
        stat.give( err, got );
      });
    }

    // console.log( 'self._cache',self._cache );

    return stat;

    // if( o.sync )
    // {
    //   self._cache[ filePath ] = stat;
    //   return stat;
    // }
    // else
    // {
    //   return stat.doThen( function( err, got )
    //   {
    //     if( err )
    //     throw err;
    //     self._cache[ filePath ] = got;
    //     return got;
    //   })
    // }
  }
}

fileStat.defaults = {};
fileStat.defaults.__proto__ = Abstract.prototype.fileStat.defaults;

//

function directoryRead( o )
{
  var self = this;

  if( !self.cachingDirs )
  return self.original.directoryRead( o );

  // var original = self.original.directoryRead;

  // var o = _._fileOptionsGet.apply( original,arguments );
  // var filePath = o;

  // debugger;

  if( self._cacheDir[ o ] !== undefined )
  {
    // if( o.sync )
    return self._cacheDir[ o ];
    // else
    // return new wConsequence().give( result );
  }
  else
  {

    if( _.strIs( o ) )
    {
      o = _.pathResolve( o );
      if( self._cacheDir[ o ] !== undefined )
      return  self._cacheDir[ o ];
    }
    else if( _.objectIs( o ) )
    {
      o = _.routineOptions( directoryRead,o )
      // o = _.pathResolve( o );
      o.filePath = _.pathResolve( o.filePath );
      if( self._cacheDir[ o.filePath ] )
      {
        if( o.sync )
        return self._cacheDir[ o.filePath ];
        else
        return wConsequence().give( self._cacheDir[ o.filePath ] );
      }
    }

    // console.log( 'directoryRead' );
    var files = self.original.directoryRead( o );

    // console.log( o );

    if( _.strIs( o ) )
    self._cacheDir[ o ] = files;
    else
    {
      if( o.sync )
      self._cacheDir[ o.filePath ] = files;
      else
      files.doThen( function( err, got )
      {
        self._cacheDir[ o.filePath ] = got;
        if( err )
        throw err;
        return got;
      });
    }

    // console.log( 'self._cache',self._cache );

    return files;

    // if( o.sync )
    // {
    //   self._cache[ filePath ] = stat;
    //   return stat;
    // }
    // else
    // {
    //   return stat.doThen( function( err, got )
    //   {
    //     if( err )
    //     throw err;
    //     self._cache[ filePath ] = got;
    //     return got;
    //   })
    // }
  }
}

directoryRead.defaults = {};
directoryRead.defaults.__proto__ = Abstract.prototype.directoryRead.defaults;

//

function fileRecord( filePath, o )
{
  var self = this;

  if( !self.cachingRecord )
  return _.FileRecord( filePath, o );

  var path = filePath;
  var record = _.FileRecord._fileRecordAdjust( path, o );

  if( self._cacheRecord[ record.absolute ] !== undefined )
  {
    return self._cacheRecord[ record.absolute ];
  }

  var record = _.FileRecord( filePath, o );
  self._cacheRecord[ record.absolute ] = record;
  return record;
}

fileRecord.defaults = {};
fileRecord.defaults.__proto__ = Abstract.prototype.fileRecord.defaults;


// --
// relationship
// --

var Composes =
{
  original : null,
  cachingDirs : 1,
  cachingStats : 1,
  cachingRecord : 1
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
  _cacheStats : Object.create( null ),
  _cacheDir : Object.create( null ),
  _cacheRecord : Object.create( null ),
}

// --
// prototype
// --

var Extend =
{
  fileStat : fileStat,
  directoryRead : directoryRead,
  fileRecord : fileRecord
}

//

var Proto =
{

  init : init,

  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.mapExtend( Proto,Extend );

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

// wCopyable.mixin( Self );

//

_.FileFilter.Caching = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
