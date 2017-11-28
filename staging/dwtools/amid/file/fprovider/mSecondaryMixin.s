( function _mSecondaryMixin_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileMid.s' );

  // if( !wTools.FileProvider.Partial )
  // require( './aPartial.s' );

}

var _ = wTools;
var FileRecord = _.FileRecord;
var Abstract = _.FileProvider.Abstract;
var Partial = _.FileProvider.Partial;
var Find = _.FileProvider.Find;

_.assert( FileRecord );
_.assert( Abstract );
_.assert( Partial );
_.assert( Find );

//

function _mixin( cls )
{

  var dstProto = cls.prototype;

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( cls ) );

  _.mixinApply
  ({
    dstProto : dstProto,
    descriptor : Self,
  });

}

// --
// filesTree
// --

function filesTreeWrite( o )
{
  var self = this;

  _.routineOptions( filesTreeWrite,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );

  if( o.verbosity )
  logger.log( 'filesTreeWrite to ' + o.filePath );

  /* */

  var stat = null;
  function handleWritten( filePath )
  {
    if( !o.allowWrite )
    return;
    if( !o.sameTime )
    return;
    if( !stat )
    stat = self.fileStat( filePath );
    else
    self.fileTimeSet( filePath, stat.atime, stat.mtime );
  }

  /* */

  function writeSoftLink( filePath,filesTree,exists )
  {

    var defaults =
    {
      softLink : null,
      absolute : null,
      terminating : null,
    };

    _.assert( _.strIs( filePath ) );
    _.assert( _.strIs( filesTree.softLink ) );
    _.assertMapHasOnly( filesTree,defaults );

    var terminating = filesTree.terminating || o.terminatingSoftLinks;

    if( o.allowWrite && !exists )
    {
      var contentPath = filesTree.softLink;
      if( o.absolutePathForLink || filesTree.absolute )
      contentPath = _.urlResolve( filePath,'..',filesTree.hardLink );
      filePath = self.localFromUrl( filePath );
      if( terminating )
      self.fileCopy( filePath,contentPath );
      else
      self.linkSoft( filePath,contentPath );
    }

    handleWritten( filePath );
  }

  /* */

  function writeHardLink( filePath,filesTree,exists )
  {

    var defaults =
    {
      hardLink : null,
      absolute : null,
      terminating : null,
    };

    _.assert( _.strIs( filePath ) );
    _.assert( _.strIs( filesTree.hardLink ) );
    _.assertMapHasOnly( filesTree,defaults );

    var terminating = filesTree.terminating || o.terminatingHardLinks;

    if( o.allowWrite && !exists )
    {
      var contentPath = filesTree.hardLink;
      if( o.absolutePathForLink || filesTree.absolute )
      contentPath = _.urlResolve( filePath,'..',filesTree.hardLink );
      contentPath = self.localFromUrl( contentPath );
      if( terminating )
      self.fileCopy( filePath,contentPath );
      else
      self.linkHard( filePath,contentPath );
    }

    handleWritten( filePath );
  }

  /* */

  function write( filePath,filesTree )
  {

    _.assert( _.strIs( filePath ) );
    _.assert( _.strIs( filesTree ) || _.objectIs( filesTree ) || _.arrayIs( filesTree ) );

    var exists = self.fileStat( filePath );
    if( o.allowDelete && exists )
    {
      self.fileDelete({ filePath : filePath, force : 1 });
      exists = false;
    }

    if( _.strIs( filesTree ) )
    {
      if( o.allowWrite && !exists )
      self.fileWrite( filePath,filesTree );
      handleWritten( filePath );
    }
    else if( _.objectIs( filesTree ) )
    {
      if( o.allowWrite && !exists )
      self.directoryMake({ filePath : filePath, force : 1 });
      handleWritten( filePath );
      for( var t in filesTree )
      {
        write( _.pathJoin( filePath,t ),filesTree[ t ] );
      }
    }
    else if( _.arrayIs( filesTree ) )
    {
      _.assert( filesTree.length === 1,'Dont know how to interpret tree' );
      filesTree = filesTree[ 0 ];

      if( filesTree.softLink )
      writeSoftLink( filePath,filesTree,exists );
      else if( filesTree.hardLink )
      writeHardLink( filePath,filesTree,exists );
      else throw _.err( 'unknown kind of file linking',filesTree );
    }

  }

  /* */

  write( o.filePath,o.filesTree );

}

filesTreeWrite.defaults =
{
  filesTree : null,
  filePath : null,
  sameTime : 0,
  absolutePathForLink : 0,
  allowWrite : 1,
  allowDelete : 0,
  verbosity : 0,
  terminatingSoftLinks : 0,
  terminatingHardLinks : 0,
}

var having = filesTreeRead.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.bare = 0;

//

/** usage

    var treeWriten = _.filesTreeRead
    ({
      filePath : dir,
      readingTerminals : 0,
    });

    logger.log( 'treeWriten :',_.toStr( treeWriten,{ levels : 99 } ) );

*/

function filesTreeRead( o )
{
  var self = this;
  var result = Object.create( null );
  var hereStr = '.';

  if( _.strIs( o ) )
  o = { glob : o };

  _.routineOptions( filesTreeRead,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.glob ) );

  // o.outputFormat = 'record';

  if( o.verbosity )
  logger.log( 'filesTreeRead from ' + o.glob );

  /* */

  o.onUp = _.arrayPrepend( _.arrayAs( o.onUp ), function( record )
  {
    var element;
    _.assert( record.stat,'file does not exists',record.absolute );
    var isDir = record.stat.isDirectory();

    /* */

    if( isDir )
    {
      element = Object.create( null );
    }
    else
    {
      if( o.readingTerminals === 'hardLink' )
      {
        element = [{ hardLink : self.urlFromLocal( record.absolute ), absolute : 1 }];
        if( o.delayedLinksTermination )
        element[ 0 ].terminating = 1;
      }
      else if( o.readingTerminals === 'softLink' )
      {
        element = [{ softLink : self.urlFromLocal( record.absolute ), absolute : 1 }];
        if( o.delayedLinksTermination )
        element[ 0 ].terminating = 1;
      }
      else if( o.readingTerminals )
      {
        _.assert( _.boolLike( o.readingTerminals ),'unknown value of { o.readingTerminals }',_.strQuote( o.readingTerminals ) );
        element = self.fileReadSync( record.absolute );
      }
      else
      {
        element = null;
      }
    }

    if( !isDir && o.onFileTerminal )
    {
      element = o.onFileTerminal( element,record,o );
    }

    if( isDir && o.onFileDir )
    {
      element = o.onFileDir( element,record,o );
    }

    /* */

    var path = record.relative;

    /* removes leading './' characher */

    if( path.length > 2 )
    path = _.pathUndot( path );

    if( o.asFlatMap )
    {
      result[ record.absolute ] = element;
    }
    else
    {
      if( path !== hereStr )
      _.entitySelectSet
      ({
        container : result,
        query : path,
        delimeter : o.delimeter,
        set : element,
      });
      else
      result = element;
    }

  });

  /* */

  // pathRegexpMakeSafe
  // self.resolvingSoftLink = 1;

  self.fieldSet( 'resolvingSoftLink',1 );
  var found = self.filesGlob( _.mapScreen( self.filesGlob.defaults,o ) );
  self.fieldReset( 'resolvingSoftLink',1 );

  return result;
}

filesTreeRead.defaults =
{

  filePath : null,
  relative : null,

  // safe : 1,
  recursive : 1,
  readingTerminals : 1,
  delayedLinksTermination : 0,
  ignoreNonexistent : 0,
  includingTerminals : 1,
  includingDirectories : 1,
  asFlatMap : 0,
  strict : 1,

  result : [],
  orderingExclusion : [],
  sortWithArray : null,

  verbosity : 0,

  delimeter : '/',

  onRecord : [],
  onUp : [],
  onDown : [],
  onFileTerminal : null,
  onFileDir : null,

  maskAll : _.pathRegexpMakeSafe ? _.pathRegexpMakeSafe() : null,

}

filesTreeRead.defaults.__proto__ = Find.prototype._filesMaskAdjust.defaults;

var having = filesTreeRead.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

// --
// files read
// --

function filesRead( o )
{
  var self = this;

  /* options */

  if( _.arrayIs( o ) )
  o = { paths : o };

  if( o.preset )
  {
    _.assert( filesRead.presets[ o.preset ],'unknown preset',o.preset );
    _.mapSupplementAppending( o,filesRead.presets[ o.preset ] );
  }

  _.routineOptions( filesRead,o );
  _.assert( arguments.length === 1 );
  _.assert( _.arrayIs( o.paths ) || _.objectIs( o.paths ) || _.strIs( o.paths ) );

  o.onBegin = o.onBegin ? _.arrayAs( o.onBegin ) : [];
  o.onEnd = o.onEnd ? _.arrayAs( o.onEnd ) : [];
  o.onProgress = o.onProgress ? _.arrayAs( o.onProgress ) : [];

  var onBegin = o.onBegin;
  var onEnd = o.onEnd;
  var onProgress = o.onProgress;

  delete o.onBegin;
  delete o.onEnd;
  delete o.onProgress;

  if( Config.debug )
  {
    for( var i = 0 ; i < onBegin.length ; i++ )
    _.assert( onBegin[ i ].length === 1 );
    for( var i = 0 ; i < onEnd.length ; i++ )
    _.assert( onEnd[ i ].length === 1 );
    for( var i = 0 ; i < onProgress.length ; i++ )
    _.assert( onProgress[ i ].length === 1 );
  }

  /* paths */

  if( _.objectIs( o.paths ) )
  {
    var _paths = [];
    for( var p in o.paths )
    _paths.push({ filePath : o.paths[ p ], name : p });
    o.paths = _paths;
  }

  o.paths = _.arrayAs( o.paths );

  /* result */

  var result = Object.create( null );
  result.options = o;

  /* */

  function _filesReadBegin()
  {
    if( !onBegin.length )
    return;
    debugger;
    _.routinesCall( self,onBegin,[ result ] );
  }

  /* */

  function _filesReadEnd( errs, read )
  {
    var err;
    if( errs.length )
    {
      err = _.err.apply( _,errs );
    }

    if( o.map === 'name' )
    {
      var read2 = {};
      for( var p = 0 ; p < o.paths.length ; p++ )
      read2[ o.paths[ p ].name ] = read[ p ];
      read = read2;
    }
    else if( o.map )
    throw _.err( 'unknown map : ' + o.map );

    result.read = read;
    result.data = read;
    result.errs = errs;
    result.err = err;

    if( onEnd.length )
    {
      _.routinesCall( self,onEnd,[ result ] );
    }

    return result;
  }

  /* */

  function _optionsForFileRead( filePath )
  {
    var readOptions = _.mapScreen( self.fileRead.defaults,o );
    readOptions.onEnd = o.onEach;

    if( _.objectIs( filePath ) )
    _.mapExtend( readOptions,filePath );
    else
    readOptions.filePath = filePath;

    if( o.sync )
    readOptions.returnRead = true;

    return readOptions;
  }

  o._filesReadEnd = _filesReadEnd;
  o._optionsForFileRead = _optionsForFileRead;

  /* begin */

  _filesReadBegin();

  if( o.sync )
  {
    return self._filesReadSync( o );
  }
  else
  {
    return self._filesReadAsync( o );
  }

}

filesRead.defaults =
{
  paths : null,
  onEach : null,
  map : '',
  sync : 1,
  preset : null,
}

filesRead.defaults.__proto__ = Partial.prototype.fileRead.defaults;

filesRead.presets = {};

filesRead.presets.js =
{
  onEnd : function format( o )
  {
    var prefix = '// ======================================\n( function() {\n';
    var postfix = '\n})();\n';
    // var prefix = '\n';
    // var postfix = '\n';
    _.assert( _.arrayIs( o.data ) );
    if( o.data.length > 1 )
    o.data = prefix + o.data.join( postfix + prefix ) + postfix;
    else
    o.data = o.data[ 0 ];
  }
}

var having = filesRead.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

function _filesReadSync( o )
{
  var self = this;

  _.assert( !o.onProgress,'not implemented' );

  var read = [];
  var errs = [];

  var _filesReadEnd = o._filesReadEnd;
  delete o._filesReadEnd;

  var _optionsForFileRead = o._optionsForFileRead;
  delete o._optionsForFileRead;

  // var onBegin = o.onBegin;
  // var onEnd = o.onEnd;
  // var onProgress = o.onProgress;
  //
  // delete o.onBegin;
  // delete o.onEnd;
  // delete o.onProgress;
  //
  // /* begin */
  //
  // if( onBegin )
  // onBegin({ options : o });

  /* exec */

  for( var p = 0 ; p < o.paths.length ; p++ )
  {
    var readOptions = _optionsForFileRead( o.paths[ p ] );

    // var read;

    try
    {
      read[ p ] = self.fileRead( readOptions );
      // result[ p ] = read;
    }
    catch( err )
    {
      if( err || read === undefined )
      {
        debugger;
        errs[ p ] = _.err( 'Cant read : ' + _.toStr( readOptions.filePath ) + '\n', ( err || 'unknown reason' ) );
        if( o.throwing )
        throw errs[ p ];
      }
    }
  }

  /* end */

  var result = _filesReadEnd( errs, read );

  // var r = resultEnd.result;
  // var err = resultEnd.err;
  // if( onEnd )
  // onEnd( err, r );

  /* */

  return result;
}

//

function _filesReadAsync( o )
{
  var self = this;
  var con = new wConsequence();

  _.assert( !o.onProgress,'not implemented' );

  var read = [];
  var errs = [];
  var err = null;

  var _filesReadEnd = o._filesReadEnd;
  delete o._filesReadEnd;

  var _optionsForFileRead = o._optionsForFileRead;
  delete o._filesReadEnd;

  // var onBegin = o.onBegin;
  // var onEnd = o.onEnd;
  // var onProgress = o.onProgress;
  //
  // delete o.onBegin;
  // delete o.onEnd;
  // delete o.onProgress;
  //
  // /* begin */
  //
  // if( onBegin )
  // wConsequence.give( onBegin,{ options : o } );

  /* exec */

  for( var p = 0 ; p < o.paths.length ; p++ ) ( function( p )
  {

    con.choke();

    var readOptions = _optionsForFileRead( o.paths[ p ] );

    wConsequence.from( self.fileRead( readOptions ) ).got( function filesReadFileEnd( _err,arg )
    {

      if( _err || arg === undefined )
      {
        err = _.errAttend( 'Cant read : ' + _.toStr( readOptions.filePath ) + '\n', ( _err || 'unknown reason' ) );
        errs[ p ] = err;
      }
      else
      {
        read[ p ] = arg;
      }

      con.give();

    });

  })( p );

  /* end */

  con.give().got( function filesReadEnd()
  {
    var result = _filesReadEnd( errs, read );

    // var resultEnd = _filesReadEnd( errs, result );
    // var r = resultEnd.result;
    // var err = resultEnd.err;
    // if( onEnd )
    // wConsequence.give( onEnd , o.throwing ? err : null , r );

    con.give( o.throwing ? err : null , result );
  });

  /* */

  return con;
}

// --
// etc
// --

function filesAreUpToDate( dst,src )
{
  var self = this;
  var odst = dst;
  var osrc = src;

  _.assert( arguments.length === 2 );

  // if( src.indexOf( 'Private.cpp' ) !== -1 )
  // console.log( 'src :',src );
  //
  // if( src.indexOf( 'Private.cpp' ) !== -1 )
  // debugger;

  /* */

  function _from( file )
  {
    if( _.fileStatIs( file ) )
    return  { stat : file };
    else if( _.strIs( file ) )
    return { stat : self.fileStat( file ) };
    else if( !_.objectIs( file ) )
    throw _.err( 'unknown descriptor of file' );
  }

  /* */

  function from( file )
  {
    if( _.arrayIs( file ) )
    {
      var result = [];
      for( var i = 0 ; i < file.length ; i++ )
      result[ i ] = _from( file[ i ] );
      return result;
    }
    return [ _from( file ) ];
  }

  /* */

  dst = from( dst );
  src = from( src );

  // logger.log( 'dst',dst[ 0 ] );
  // logger.log( 'src',src[ 0 ] );

  var dstMax = _.entityMax( dst, function( e ){ return e.stat ? e.stat.mtime : Infinity; } );
  var srcMax = _.entityMax( src, function( e ){ return e.stat ? e.stat.mtime : Infinity; } );

  // logger.log( 'dstMax.element.stat.mtime',dstMax.element.stat.mtime );
  // logger.log( 'srcMax.element.stat.mtime',srcMax.element.stat.mtime );

  if( !dstMax.element.stat )
  return false;

  if( !srcMax.element.stat )
  return false;

  if( dstMax.element.stat.mtime >= srcMax.element.stat.mtime )
  return true;
  else
  return false;

}

var having = filesAreUpToDate.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

/**
 * Returns true if any file from o.dst is newer than other any from o.src.
 * @example :
 * wTools.filesAreUpToDate2
 * ({
 *   src : [ 'foo/file1.txt', 'foo/file2.txt' ],
 *   dst : [ 'bar/file1.txt', 'bar/file2.txt' ],
 * });
 * @param {Object} o
 * @param {string[]} o.src array of paths
 * @param {Object} [o.srcOptions]
 * @param {string[]} o.dst array of paths
 * @param {Object} [o.dstOptions]
 * @param {boolean} [o.verbosity=true] turns on/off logging
 * @returns {boolean}
 * @throws {Error} If passed object has unexpected parameter.
 * @method filesAreUpToDate2
 * @memberof wTools
 */

function filesAreUpToDate2( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( !o.newer || _.dateIs( o.newer ) );
  _.routineOptions( filesAreUpToDate2,o );

  debugger;
  var srcFiles = self.fileRecordsFiltered( o.src );

  if( !srcFiles.length )
  {
    if( o.verbosity )
    logger.log( 'Nothing to parse' );
    return true;
  }

  var srcNewest = _.entityMax( srcFiles,function( file ){ return file.stat.mtime.getTime() } ).element;

  /* */

  var dstFiles = self.fileRecordsFiltered( o.dst );

  if( !dstFiles.length )
  {
    return false;
  }

  var dstOldest = _.entityMin( dstFiles,function( file ){ return file.stat.mtime.getTime() } ).element;

  /* */

  if( o.notOlder )
  {
    if( !( o.notOlder.getTime() <= dstOldest.stat.mtime.getTime() ) )
    return false;
  }

  if( srcNewest.stat.mtime.getTime() <= dstOldest.stat.mtime.getTime() )
  {

    if( o.verbosity )
    logger.log( 'Up to date' );
    return true;

  }

  return false;
}

filesAreUpToDate2.defaults =
{
  src : null,
  dst : null,
  verbosity : 1,
  notOlder : null,
}

var having = filesAreUpToDate2.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

// --
// config
// --

function fileConfigRead( o )
{

  var self = this;
  var o = o || Object.create( null );

  if( _.strIs( o ) )
  {
    o = { name : o };
  }

  if( o.pathDir === undefined )
  o.pathDir = _.pathNormalize( _.pathEffectiveMainDir() );

  if( o.result === undefined )
  o.result = Object.create( null );

  _.routineOptions( fileConfigRead,o );

  if( !o.name )
  {
    o.name = 'config';
    self._fileConfigRead( o );
    o.name = 'public';
    self._fileConfigRead( o );
    o.name = 'private';
    self._fileConfigRead( o );
  }
  else
  {
    self._fileConfigRead( o );
  }

  return o.result;
}

fileConfigRead.defaults =
{
  name : null,
  pathDir : null,
  result : null,
}

var having = fileConfigRead.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

function _fileConfigRead( o )
{

  var self = this;
  var read;

  if( o.name === undefined )
  o.name = 'config';

  var pathTerminal = _.pathJoin( o.pathDir,o.name );

  /**/

  if( typeof Coffee !== 'undefined' )
  {
    var fileName = pathTerminal + '.coffee';
    if( self.fileStat( fileName ) )
    {

      read = self.fileReadSync( fileName );
      read = Coffee.eval( read,
      {
        filename : fileName,
      });
      _.mapExtend( o.result,read );

    }
  }

  /**/

  var fileName = pathTerminal + '.json';
  if( self.fileStat( fileName ) )
  {

    read = self.fileReadSync( fileName );
    read = JSON.parse( read );
    _.mapExtend( o.result,read );

  }

  /**/

  var fileName = pathTerminal + '.s';
  if( self.fileStat( fileName ) )
  {

    debugger;
    read = self.fileReadSync( fileName );
    read = _.exec( read );
    _.mapExtend( o.result,read );

  }

  return o.result;
}

_fileConfigRead.defaults = fileConfigRead.defaults;

// --
// relationship
// --

var Composes =
{
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
}

// --
// prototype
// --

var Supplement =
{


  // filesTree

  filesTreeWrite : filesTreeWrite,
  filesTreeRead : filesTreeRead,


  // files read

  filesRead : filesRead,
  _filesReadAsync : _filesReadAsync,
  _filesReadSync : _filesReadSync,


  // etc

  filesAreUpToDate : filesAreUpToDate,
  filesAreUpToDate2 : filesAreUpToDate2,


  // config

  fileConfigRead : fileConfigRead,
  _fileConfigRead : _fileConfigRead,


  //

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

var Self =
{

  supplement : Supplement,

  name : 'wFilePorviderSecondaryMixin',
  nameShort : 'Secondary',
  _mixin : _mixin,

}

//

_.FileProvider = _.FileProvider || Object.create( null );
_.FileProvider[ Self.nameShort ] = _.mixinMake( Self );

if( typeof module !== 'undefined' )
module[ 'exports' ] = _.FileProvider[ Self.nameShort ];

})();
