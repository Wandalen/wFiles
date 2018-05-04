( function _mSecondaryMixin_s_() {

'use strict'; /* ddd */

if( typeof module !== 'undefined' )
{

  var _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../FileMid.s' );

  // if( !_global_.wTools.FileProvider.Partial )
  // require( './aPartial.s' );

}

var _ = _global_.wTools;
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

    // if( o.sync )
    // readOptions.returnRead = true;

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
  var con = new _.Consequence();

  _.assert( !o.onProgress,'not implemented' );

  var read = [];
  var errs = [];
  var err = null;

  var _filesReadEnd = o._filesReadEnd;
  delete o._filesReadEnd;

  var _optionsForFileRead = o._optionsForFileRead;
  delete o._filesReadEnd;

  /* exec */

  for( var p = 0 ; p < o.paths.length ; p++ ) ( function( p )
  {

    con.choke();

    var readOptions = _optionsForFileRead( o.paths[ p ] );

    wConsequence.from( self.fileRead( readOptions ) ).got( function filesReadFileEnd( _err,arg )
    {

      if( _err || arg === undefined || arg === null )
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

  // debugger;
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

//

function filesFindText( o )
{
  var self = this;
  var result = [];

  _.routineOptions( filesFindText,o );
  _.assert( arguments.length === 1 );

  var options = _.mapExtend( null,o );

  o.ins = _.arrayAs( o.ins );
  for( var i = 0 ; i < o.ins.length ; i++ )
  if( o.toleratingText )
  o.ins[ i ] = _.strToRegexpTolerating( o.ins[ i ] );
  else
  o.ins[ i ] = _.strToRegexp( o.ins[ i ] );

  delete options.ins;
  delete options.toleratingText;
  delete options.determiningLineNumber;

  _.arrayAppend( options.onUp,function( record )
  {
    var read = record.fileProvider.fileRead( record.absolute );

    var matches = _.strFind
    ({
      src : read,
      ins : o.ins,
      determiningLineNumber : o.determiningLineNumber,
      toleratingText : 0,
    });

    for( var m = 0 ; m < matches.length ; m++ )
    {
      var match = matches[ m ];
      match.file = record;
      result.push( match );
    }

    return false;
  });

  var records = self.filesFind( options );

  return result;
}

filesFindText.defaults =
{
  ins : null,
  toleratingText : 0,
  determiningLineNumber : 1,
}

filesFindText.defaults.__proto__ = Find.prototype.filesFind.defaults;

var having = filesFindText.having = Object.create( Find.prototype.filesFind.having );

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


  // files read

  filesRead : filesRead,
  _filesReadAsync : _filesReadAsync,
  _filesReadSync : _filesReadSync,


  // etc

  filesAreUpToDate : filesAreUpToDate,
  filesAreUpToDate2 : filesAreUpToDate2,

  filesFindText : filesFindText,


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

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
