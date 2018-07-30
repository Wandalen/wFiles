( function _mSecondaryMixin_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  var _global = _global_; var _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../UseMid.s' );

}

var _global = _global_; var _ = _global_.wTools;
var FileRecord = _.FileRecord;
var Abstract = _.FileProvider.Abstract;
var Partial = _.FileProvider.Partial;
var Find = _.FileProvider.Find;

var fileRead = Partial.prototype.fileRead;

_.assert( FileRecord );
_.assert( Abstract );
_.assert( Partial );
_.assert( Find );
_.assert( fileRead );

//

function onMixin( dstClass )
{

  var dstPrototype = dstClass.prototype;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.routineIs( dstClass ) );

  _.mixinApply( this, dstPrototype );
  // _.mixinApply
  // ({
  //   dstPrototype : dstPrototype,
  //   descriptor : Self,
  // });

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
  _.assert( arguments.length === 1, 'expects single argument' );
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

  function _filesReadEnd( errs, got )
  {
    var err;
    var errsArray = [];

    for( var k in errs )
    errsArray.push( errs[ k ] );

    if( errsArray.length )
    {
      errs.total = errsArray.length;
      err = _.err.apply( _,errsArray );
    }

    var read = got;
    // if( !o.returningRead )
    // debugger;
    if( !o.returningRead )
    read = _.entityMap( got,( e ) => e.result );

    if( o.map === 'name' )
    {

      var read2 = Object.create( null );
      for( var p = 0 ; p < o.paths.length ; p++ )
      read2[ o.paths[ p ].name ] = read[ p ];
      read = read2;

      var got2 = Object.create( null );
      for( var p = 0 ; p < o.paths.length ; p++ )
      got2[ o.paths[ p ].name ] = got[ p ];
      got = got2;

    }
    else if( o.map )
    _.assert( 0, 'unknown map : ' + o.map );

    // debugger;

    result.read = read;
    result.data = read;
    result.got = got;
    result.errs = errs;
    result.err = err;

    if( onEnd.length )
    {
      _.routinesCall( self,onEnd,[ result ] );
    }

    return result;
  }

  /* */

  function _optionsForFileRead( src )
  {
    var readOptions = _.mapOnly( o, self.fileRead.defaults );
    readOptions.onEnd = o.onEach;

    if( _.objectIs( src ) )
    {
      if( _.FileRecord && src instanceof _.FileRecord )
      readOptions.filePath = src.absolute;
      else
      _.mapExtend( readOptions,src );
    }
    else
    readOptions.filePath = src;

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

filesRead.defaults.__proto__ = fileRead.defaults;

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
  var errs = {};

  var _filesReadEnd = o._filesReadEnd;
  delete o._filesReadEnd;

  var _optionsForFileRead = o._optionsForFileRead;
  delete o._optionsForFileRead;

  var throwing = o.throwing;
  o.throwing = 1;

  /* exec */

  for( var p = 0 ; p < o.paths.length ; p++ )
  {
    var readOptions = _optionsForFileRead( o.paths[ p ] );

    try
    {
      read[ p ] = self.fileRead( readOptions );
    }
    catch( err )
    {

      if( throwing )
      throw err;

      errs[ p ] = err;
      read[ p ] = null;
    }
  }

  /* end */

  var result = _filesReadEnd( errs, read );

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
    con.give( o.throwing ? err : undefined , result );
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

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

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

  _.assert( arguments.length === 1, 'expects single argument' );
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

function systemBitrateTimeGet()
{
  var self = this;

  var result = 10;

  if( _.FileProvider.HardDrive && self instanceof _.FileProvider.HardDrive )
  {
    var testDir = _.dirTempMake( _.pathJoin( __dirname, '../../..'  ) );
    var tempFile = _.pathJoin( testDir, 'systemBitrateTimeGet' );
    self.fileWrite( tempFile, tempFile );
    var ostat = self.fileStat( tempFile );
    var mtime = new Date( ostat.mtime.getTime() );
    var ms = 500;
    mtime.setMilliseconds( ms );
    try
    {
      self.fileTimeSet( tempFile, ostat.atime, mtime );
      var stat = self.fileStat( tempFile );
      var diff = mtime.getTime() - stat.mtime.getTime();
      if( diff )
      {
        debugger
        result  = ( diff / 1000 ).toFixed() * 1000;
        _.assert( result );
      }
    }
    catch( err )
    {
      throw _.err( err );
    }
    finally
    {
      self.filesDelete( testDir );
      var statDir = self.fileStat( testDir );
      _.assert( !statDir );
    }
  }

  return result;
}

systemBitrateTimeGet.defaults =
{
}

var having = systemBitrateTimeGet.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.bare = 1;

// --
// top
// --

function filesFindText( o )
{
  var self = this;
  var result = [];

  _.routineOptions( filesFindText,o );
  _.assert( arguments.length === 1, 'expects single argument' );

  var options = _.mapExtend( null,o );

  o.ins = _.arrayAs( o.ins );
  // for( var i = 0 ; i < o.ins.length ; i++ )
  // debugger;
  o.ins = _.regexpsMaybeFrom
  ({
    srcStr : o.ins,
    stringWithRegexp : o.stringWithRegexp,
    toleratingSpaces : o.toleratingSpaces,
  });
  // debugger;

  delete options.ins;
  delete options.stringWithRegexp;
  delete options.toleratingSpaces;
  delete options.determiningLineNumber;

  options.onUp = _.arrayAppend( options.onUp, handleUp );

  var records = self.filesFind( options );

  return result;

  /* */

  function handleUp( record )
  {
    var read = record.context.fileProviderEffective.fileRead( record.absolute );

    var matches = _.strFind
    ({
      src : read,
      ins : o.ins,
      determiningLineNumber : o.determiningLineNumber,
      stringWithRegexp : 0,
      toleratingSpaces : 0,
    });

    for( var m = 0 ; m < matches.length ; m++ )
    {
      var match = matches[ m ];
      match.file = record;
      result.push( match );
    }

    return false;
  }

}

var defaults = filesFindText.defaults = Object.create( Find.prototype.filesFind.defaults );

defaults.ins = null;
defaults.stringWithRegexp = 0;
defaults.toleratingSpaces = 0;
defaults.determiningLineNumber = 1;

var having = filesFindText.having = Object.create( Find.prototype.filesFind.having );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//
//
// var execute = function( options )
// {
//   var options = options || Object.create( null );
//
//   options.maskAll = _.regexpMakeObject( options.maskAll || Object.create( null ),'includeAny' );
//   var excludeMask = _.regexpMakeObject
//   ({
//     excludeAny : [ 'node_modules','.unique','.git','.svn',/(^|\/)\.(?!$|\/)/,/\.\/file($|\/)/ ],
//     //excludeAny : [ 'node_modules','.unique','.git','.svn',/(^|\/)\.(?!$|\/)/,/(^|\/)file($|\/)/ ],
//   });
//   options.maskAll = _.RegexpObject.shrink( options.maskAll,excludeMask );
//   options.maskAll = _.regexpMakeSafe( options.maskAll );
//
// /*
//   options.maskTerminal = _.regexpMakeObject( options.maskTerminal || Object.create( null ),'includeAny' );
//   var excludeMask = _.regexpMakeObject
//   ({
//     excludeAny : [ 'node_modules','.unique','.git','.svn' ],
//   });
//   options.maskTerminal = _.RegexpObject.shrink( options.maskTerminal,excludeMask );
// */
//
//   if( options.recursive === undefined ) options.recursive = 1;
//   if( options.similarity === undefined ) options.similarity = 0.85;
//
// /*
//   if( options.maskDir === undefined ) options.maskDir =
//   {
//     excludeAny : [ '/ccompiler/contrib/','node_modules','.unique','.git','.svn',/(^|\/)\.(?!$|\/)/,/(^|\/)file($|\/)/],
//   };
// */
//
//   debugger;
//   options.onRecord = _.arrayAppend( options.onRecord || [],function(){
//
//     if( !this.stat )
//     logger.log( '-','cant read file:',this.relative );
//
//   });
//
//   var fileProvider = _.FileProvider.HardDrive();
//   var found = fileProvider.filesFindSameOld( options );
//
//   logger.log( 'options :' );
//   logger.log( _.toStr( options,{ levels : 3 }) );
//   logger.log( 'found.similar :',found.similar.length );
//
//   // same name
// /*
//   for( var s = 0 ; s < found.sameName.length ; s++ )
//   {
//     var files = found.sameName[ s ];
//
//     logger.logUp( 'Same name' )
//
//     for( var f = 0 ; f < files.length ; f++ )
//     logger.log( files[ f ].relative );
//
//     logger.logDown();
//
//   }
// */
//
//   // similar content
//
//   found.similar.sort( function( a,b ){ return a.similarity-b.similarity } );
//
//   for( var s = 0 ; s < found.similar.length ; s++ )
//   {
//     var similar = found.similar[ s ];
//
//     logger.logUp( 'Similar content( ',(similar.similarity*100).toFixed( 3 ),'% )' );
//     logger.log( similar.files[ 0 ].absolute );
//     logger.log( similar.files[ 1 ].absolute );
//     logger.logDown( '' );
//
//   }
//
//   // same
//
//   for( var s = 0 ; s < found.same.length ; s++ )
//   {
//
//     var files = found.same[ s ];
//     var base = _.entityMax( files, function( o ){ return o.stat.nlink; } ).element;
//
//     for( var f = 0 ; f < files.length ; f++ )
//     {
//
//       var file = files[ f ];
//       if( base === file ) continue;
//
//       var linked = fileProvider.filesLinked( base,file );
//       if( linked )
//       {
//         //console.log( '? was linked',base.absolute,'-',file.absolute );
//         continue;
//       }
//
//       logger.logUp( 'Same( not linked ):' );
//       for( var f = 0 ; f < files.length ; f++ )
//       {
//         var file = files[ f ];
//         logger.log( file.absolute );
//       }
//       logger.logDown( '' );
//
//       break;
//
//     }
//
//   }
//
//   // same content
//
//   for( var s = 0 ; s < found.sameContent.length ; s++ )
//   {
//     var files = found.sameContent[ s ];
//
//     var linked = fileProvider.filesLinked( base,file );
//     if( linked )
//     {
//       //console.log( '? was linked',base.absolute,'-',file.absolute );
//       continue;
//     }
//
//     logger.logUp( 'Same content( not linked )' );
//     for( var f = 0 ; f < files.length ; f++ )
//     logger.log( files[ f ].relative );
//     logger.logDown( '' );
//
//   }
//
//   return this;
// }

// --
// read
// --

function fileConfigRead2( o )
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

  _.routineOptions( fileConfigRead2,o );

  if( !o.name )
  {
    o.name = 'config';
    self._fileConfigRead2( o );
    o.name = 'public';
    self._fileConfigRead2( o );
    o.name = 'private';
    self._fileConfigRead2( o );
  }
  else
  {
    self._fileConfigRead2( o );
  }

  return o.result;
}

fileConfigRead2.defaults =
{
  name : null,
  pathDir : null,
  result : null,
}

var having = fileConfigRead2.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

function _fileConfigRead2( o )
{
  var self = this;
  var read;

  // _.include( 'wExecTools' );

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

_fileConfigRead2.defaults = fileConfigRead2.defaults;

//

function _fileConfigRead_body( o )
{
  var self = this;
  var result = null;

  _.assert( arguments.length === 1, 'expects single argument' );

  var exts = {};
  for( var e in fileRead.encoders )
  {
    var encoder = fileRead.encoders[ e ];
    if( encoder.exts )
    for( var s = 0 ; s < encoder.exts.length ; s++ )
    exts[ encoder.exts[ s ] ] = e;
  }

  _.assert( o.filePath );

  self.fieldSet({ throwing : 0 });

  for( var ext in exts )
  {
    var options = _.mapExtend( null,o );
    options.filePath = o.filePath + '.' + ext;
    options.encoding = exts[ ext ];
    options.throwing = 0;

    var result = self.fileRead( options );
    if( result !== null )
    break;
  }

  self.fieldReset({ throwing : 0 });

  if( result === null )
  {
    debugger;
    if( o.throwing )
    throw _.err( 'Cant read config at',o.filePath );
  }

  return result;
}

var defaults = _fileConfigRead_body.defaults = Object.create( fileRead.defaults );

defaults.encoding = null;
defaults.throwing = null;

var paths = _fileConfigRead_body.paths = Object.create( fileRead.paths );
var having = _fileConfigRead_body.having = Object.create( fileRead.having );

//

function fileConfigRead( o )
{
  var self = this;
  var o = self.fileConfigRead.pre.call( self,self.fileConfigRead,arguments );
  var result = self.fileConfigRead.body.call( self,o );
  return result;
}

fileConfigRead.pre = fileRead.pre;
fileConfigRead.body = _fileConfigRead_body;

var defaults = fileConfigRead.defaults = Object.create( _fileConfigRead_body.defaults );
var paths = fileConfigRead.paths = Object.create( _fileConfigRead_body.paths );
var having = fileConfigRead.having = Object.create( _fileConfigRead_body.having );

//

var TemplateTreeResolver;
function _fileCodeRead_body( o )
{
  var self = this;
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( o.sync,'not implemented' );

  var o2 = _.mapOnly( o, self.fileRead.defaults );
  var result = self.fileRead( o2 );

  if( o.name === null )
  o.name = _.strVarNameFor( _.pathNameWithExtension( o.filePath ) );

  if( o.wrapping )
  {

    if( _.TemplateTreeResolver )
    {
      var resolver = _.TemplateTreeResolver({ tree : o });
      o.prefix = resolver.resolve( o.prefix );
      o.postfix = resolver.resolve( o.postfix );
    }

    result = o.prefix + result + o.postfix;

  }

  if( o.routine )
  {
    result = _.routineMake({ code : result, name : o.name });
  }

  return result;
}

var defaults = _fileCodeRead_body.defaults = Object.create( fileRead.defaults );

defaults.encoding = 'utf8';
defaults.wrapping = 1;
defaults.routine = 0;
defaults.name = null;
defaults.prefix = '// ======================================\n( function {{name}}() {\n';
defaults.postfix = '\n})();\n';

var paths = _fileCodeRead_body.paths = Object.create( fileRead.paths );
var having = _fileCodeRead_body.having = Object.create( fileRead.having );

//

function fileCodeRead( o )
{
  var self = this;
  var o = self.fileCodeRead.pre.call( self,self.fileCodeRead,arguments );
  var result = self.fileCodeRead.body.call( self,o );
  return result;
}

fileCodeRead.pre = fileRead.pre;
fileCodeRead.body = _fileCodeRead_body;

var defaults = fileCodeRead.defaults = Object.create( _fileCodeRead_body.defaults );
var paths = fileCodeRead.paths = Object.create( _fileCodeRead_body.paths );
var having = fileCodeRead.having = Object.create( _fileCodeRead_body.having );

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
// define class
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

  systemBitrateTimeGet : systemBitrateTimeGet,

  // top


  // read

  fileConfigRead2 : fileConfigRead2,
  _fileConfigRead2 : _fileConfigRead2,

  _fileConfigRead_body : _fileConfigRead_body,
  fileConfigRead : fileConfigRead,

  _fileCodeRead_body : _fileCodeRead_body,
  fileCodeRead : fileCodeRead,


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
  shortName : 'Secondary',
  onMixin : onMixin,

}

//

_.FileProvider = _.FileProvider || Object.create( null );
_.FileProvider[ Self.shortName ] = _.mixinMake( Self );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
