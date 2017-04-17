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

//

function _statUpdate( filePath )
{
  var self = this;

  var stat = self.original.fileStat( filePath );
  filePath = _.pathResolve( filePath );
  self._cacheStats[ filePath ] = stat;
}

//

function _dirUpdate( filePath, del )
{
  var self = this;

  filePath = _.pathResolve( filePath );
  var dirPath = _.pathDir( filePath );
  self._cacheDir[ dirPath ] = self.original.directoryRead( dirPath );
  self._cacheDir[ filePath ] = self.original.directoryRead( filePath );
}

//

function fileRead( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  var result = self.original.fileRead( o );

  if( !self.updateOnRead )
  return result;

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( )
    {
      if( self.cachingStats )
      self._statUpdate( o.filePath );
    });
  }
  else
  {
    if( self.cachingStats )
    self._statUpdate( o.filePath );
  }


  return result;
}

fileRead.defaults = {};
fileRead.defaults.__proto__ = Abstract.prototype.fileRead.defaults;

//

function fileHash( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  var result = self.original.fileHash( o );

  if( !self.updateOnRead )
  return result;

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( !_.isNaN( got ) )
      if( self.cachingStats )
      self._statUpdate( o.filePath );

      return got;
    });
  }
  else
  {
    if( !_.isNaN( result ) )
    if( self.cachingStats )
    self._statUpdate( o.filePath );
  }


  return result;
}

fileRead.defaults = {};
fileRead.defaults.__proto__ = Abstract.prototype.fileRead.defaults;

//

function fileWrite( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o = { filePath : arguments[ 0 ], data : arguments[ 1 ] };
  }

  var result = self.original.fileWrite( o );

  function _write()
  {
    if( self.cachingStats )
    self._statUpdate( o.filePath );
    if( self.cachingDirs )
    self._dirUpdate( o.filePath );
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      _write();
    });
  }
  else
  _write();

  return result;
}

fileWrite.defaults = {};
fileWrite.defaults.__proto__ = Abstract.prototype.fileWrite.defaults;

//

function fileTimeSet( o )
{
  var self = this;

  if( arguments.length === 3 )
  o =
  {
    filePath : arguments[ 0 ],
    atime : arguments[ 1 ],
    mtime : arguments[ 2 ],
  }

  var result = self.original.fileTimeSet( o );

  if( self.cachingStats )
  {
    var filePath = _.pathResolve( o.filePath );
    self._cacheStats[ filePath ].atime = o.atime;
    self._cacheStats[ filePath ].mtime = o.mtime;
  }

  return result;
}

fileTimeSet.defaults = {};
fileTimeSet.defaults.__proto__ = Abstract.prototype.fileTimeSet.defaults;

//

function fileDelete( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  var result = self.original.fileDelete( o );

  function _delete()
  {
    if( self.cachingStats )
    delete self._cacheStats[ _.pathResolve( o.filePath ) ];
    if( self.cachingDirs )
    delete self._cacheDir[ _.pathResolve( o.filePath ) ];
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      _delete();
    });
  }
  else
  {
    _delete();
  }
  return result;
}

fileDelete.defaults = {};
fileDelete.defaults.__proto__ = Abstract.prototype.fileDelete.defaults;

//

function directoryMake( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  var result = self.original.directoryMake( o );

  function _directoryMake()
  {
    if( self.cachingStats )
    self._statUpdate( o.filePath );
    if( self.cachingDirs )
    self._cacheDir[ _.pathResolve( o.filePath ) ] = self.original.directoryRead( o.filePath );
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      _directoryMake();
    });
  }
  else
  {
    _directoryMake();
  }

  return result;
}

directoryMake.defaults = {};
directoryMake.defaults.__proto__ = Abstract.prototype.directoryMake.defaults;

//

function fileRename( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }

  var result = self.original.fileRename( o );

  function _rename()
  {
    if( o.pathDst === o.pathSrc )
    return;

    if( self.cachingStats )
    {
      var src =  self.fileStat( o.pathSrc );
      self._cacheStats[ _.pathResolve( o.pathDst ) ] = src;
      delete self._cacheStats[ _.pathResolve( o.pathSrc ) ];
    }
    if( self.cachingDirs )
    {
      var pathSrc = _.pathResolve( o.pathSrc );
      delete self._cacheDir[ pathSrc ];
      self._dirUpdate( o.pathDst );
      var dirPath = _.pathDir( pathSrc );
      self._cacheDir[ dirPath ] = self.original.directoryRead( dirPath );
    }
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( got )
      _rename();
      return got;
    });
  }
  else if( result )
  _rename();

  return result;
}

fileRename.defaults = {};
fileRename.defaults.__proto__ = Abstract.prototype.fileRename.defaults;

//

function fileCopy( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }

  var result = self.original.fileCopy( o );

  function _copy()
  {
    if( o.pathDst === o.pathSrc )
    return;

    if( self.cachingStats )
    self._statUpdate( o.pathDst );

    if( self.cachingDirs )
    self._dirUpdate( o.pathDst );
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( got )
      _copy();
      return got;
    });
  }
  else if( result )
  _copy();

  return result;
}

fileCopy.defaults = {};
fileCopy.defaults.__proto__ = Abstract.prototype.fileCopy.defaults;

//

function linkSoft( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }

  var result = self.original.linkSoft( o );

  function _link()
  {
    if( o.pathDst === o.pathSrc )
    return;

    if( self.cachingStats )
    self._statUpdate( o.pathDst );
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( got )
      _link();
      return got;
    });
  }
  else if( result )
  _link();

  return result;
}

linkSoft.defaults = {};
linkSoft.defaults.__proto__ = Abstract.prototype.linkSoft.defaults;

//

function linkHard( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }

  var result = self.original.linkHard( o );

  function _link()
  {
    if( o.pathDst === o.pathSrc )
    return;

    if( self.cachingStats )
    self._statUpdate( o.pathDst );
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( got )
      _link();
      return got;
    });
  }
  else if( result )
  _link();

  return result;
}

linkHard.defaults = {};
linkHard.defaults.__proto__ = Abstract.prototype.linkHard.defaults;

//

function fileExchange( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }

  var pathSrc = o.pathSrc;
  var pathDst = o.pathDst;

  var result = self.original.fileExchange( o );

  function _exchange()
  {
    o.pathSrc = pathSrc;
    o.pathDst = pathDst;

    if( o.pathDst === o.pathSrc )
    return;

    if( self.cachingStats )
    {
      var src = self.fileStat( o.pathSrc );
      var dst = self.fileStat( o.pathDst );

      if( !src && !dst )
      return;

      if( !src && dst )
      {
        self._cacheStats[ _.pathResolve( o.pathSrc ) ] = dst;
        delete self._cacheStats[ _.pathResolve( o.pathDst ) ];
      }
      else if( src && !dst )
      {
        self._cacheStats[ _.pathResolve( o.pathDst ) ] = src;
        delete self._cacheStats[ _.pathResolve( o.pathSrc ) ];
      }
      else
      {
        self._cacheStats[ _.pathResolve( o.pathSrc ) ] = dst;
        self._cacheStats[ _.pathResolve( o.pathDst ) ] = src;
      }
    }
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( got )
      _exchange();
      return got;
    });
  }
  else if( result )
  _exchange();

  return result;
}

fileExchange.defaults = {};
fileExchange.defaults.__proto__ = Abstract.prototype.fileExchange.defaults;


// --
// relationship
// --

var Composes =
{
  original : null,
  cachingDirs : 1,
  cachingStats : 1,
  cachingRecord : 1,
  updateOnRead : 0
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
  fileRecord : fileRecord,

  fileRead : fileRead,

  fileHash : fileHash,

  fileWrite : fileWrite,

  fileTimeSet : fileTimeSet,

  fileDelete : fileDelete,

  directoryMake : directoryMake,

  fileRename : fileRename,
  fileCopy : fileCopy,
  linkSoft : linkSoft,
  linkHard : linkHard,

  fileExchange : fileExchange,

  _statUpdate : _statUpdate,
  _dirUpdate : _dirUpdate,
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
