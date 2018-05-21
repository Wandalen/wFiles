( function _mFindMixin_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  var _ = _global_.wTools;
  if( !_.FileProvider )
  require( '../FileMid.s' );

}

var _ = _global_.wTools;
var FileRecord = _.FileRecord;
var Abstract = _.FileProvider.Abstract;
var Partial = _.FileProvider.Partial;

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
// find
// --

function recordsOrder( records,orderingExclusion )
{

  _.assert( _.arrayIs( records ) );
  _.assert( arguments.length === 2 );

  if( !orderingExclusion.length )
  return records;

  var orderingExclusion = _.RegexpObject.order( orderingExclusion || [] );

  var removed = [];
  var result = [];
  for( var e = 0 ; e < orderingExclusion.length ; e++ )
  result[ e ] = [];

  for( var r = 0 ; r < records.length ; r++ )
  {
    var record = records[ r ];
    for( var e = 0 ; e < orderingExclusion.length ; e++ )
    {
      var mask = orderingExclusion[ e ];
      var match = mask.test( record.relative );
      if( match )
      {
        result[ e ].push( record );
        break;
      }
    }
    if( e === orderingExclusion.length )
    removed.push( record );
  }

  return _.arrayAppendArrays( [],result );
}

//

function _filesFindMasksSupplement( dst,src )
{
  _.assert( arguments.length === 2 );

  _.mapSupplement( dst,src );

  dst.maskDir = _.RegexpObject.shrink( null, dst.maskDir || Object.create( null ),src.maskDir || Object.create( null ) );
  dst.maskTerminal = _.RegexpObject.shrink( null, dst.maskTerminal || Object.create( null ),src.maskTerminal || Object.create( null ) );
  dst.maskAll = _.RegexpObject.shrink( null, dst.maskAll || Object.create( null ),src.maskAll || Object.create( null ) );

  return dst;
}

//

function __filesFindOptions( args, safe )
{
  var o;

  _.assert( arguments.length === 2 );
  _.assert( 1 <= args.length && args.length <= 3 );

  if( args.length === 1 && _.routineIs( args[ 0 ] ) )
  {

    o = o || Object.create( null );
    o.onUp = args[ 0 ];

  }
  else
  {

    if( _.objectIs( args[ 0 ] ) )
    {
      o = args[ 0 ];
    }
    else
    {
      o = { filePath : args[ 0 ] };
    }

    if( args[ 1 ] !== undefined && o.maskTerminal === undefined )
    o.maskTerminal = args[ 1 ];

  }

  if( safe )
  if( o.maskAll === undefined && o.maskTerminal === undefined && o.maskDir === undefined )
  o.maskAll = _.pathRegexpMakeSafe();

  return o;
}

//

function _filesFindPre( routine, args )
{
  var self = this;

  _.assert( arguments.length === 2 );
  _.assert( 1 <= args.length && args.length <= 3 );

  var o = self.__filesFindOptions( args, 1 );

  _.routineOptions( routine,o );
  self._providerOptions( o );

  // debugger;
  // self._filesFindGlobAdjust( o );
  // self._filesFindMasksAdjust( o );
  self._filesFilterForm( o );
  // debugger;

  return o;
}

//

function _filesFindGlobAdjust( o )
{
  var self = this;

  _.assert( o.glob === undefined );
  _.assert( !o.globOut );

  if( o.filePath )
  o.filePath = self.pathNormalize( o.filePath );

  if( o.basePath )
  o.basePath = self.pathNormalize( o.basePath );

  if( !o.globIn )
  return;

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( o ) );
  _.assert( _.strIs( o.globIn ) || _.arrayIs( o.globIn ) );
  _.assert( o.relative === undefined );

  o.globIn = self.pathsNormalize( o.globIn );

  function pathFromGlob( globIn )
  {
    var result;
    _.assert( _.strIs( globIn ) );
    var i = globIn.search( /[^\\\/]*?(\*\*|\?|\*|\[.*\]|\{.*\}+(?![^[]*\]))[^\\\/]*/ );
    if( i === -1 )
    result = globIn;
    else
    result = self.pathNormalize( globIn.substr( 0,i ) );
    if( !result )
    result = _.pathRealMainDir();
    return result;
  }

  if( !o.filePath )
  {
    if( _.arrayIs( o.globIn ) )
    o.filePath = _.entityFilter( o.globIn,( globIn ) => pathFromGlob( globIn ) );
    else
    o.filePath = pathFromGlob( o.globIn );
  }

  if( !o.basePath )
  {
    if( _.arrayIs( o.filePath ) )
    o.basePath = _.pathCommon( o.filePath );
    else
    o.basePath = o.filePath;
  }

  _.assert( _.strIs( o.filePath ) || _.strsAre( o.filePath ) );

  function globAdjust( globIn )
  {

    var basePath = _.strAppendOnce( o.basePath,'/' );
    if( !_.strBegins( globIn,basePath ) )
    basePath = o.basePath;

    if( _.strBegins( globIn,basePath ) )
    {
      globIn = globIn.substr( basePath.length, globIn.length );
    }

    return globIn;
  }

  if( _.arrayIs( o.globIn ) )
  o.globOut = _.entityFilter( o.globIn,( globIn ) => globAdjust( globIn ) );
  else
  o.globOut = globAdjust( o.globIn );

  o.globIn = null;

}

//

function _filesFindMasksAdjust( o )
{
  var self = this;

  if( o.filePath )
  o.filePath = self.pathNormalize( o.filePath );

  if( o.basePath )
  o.basePath = self.pathNormalize( o.basePath );

  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o ) );
  _.assert( o.glob === undefined );

  o.maskAll = _.regexpMakeObject( o.maskAll || Object.create( null ),'includeAny' );
  o.maskTerminal = _.regexpMakeObject( o.maskTerminal || Object.create( null ),'includeAny' );
  o.maskDir = _.regexpMakeObject( o.maskDir || Object.create( null ),'includeAny' );

  if( o.hasExtension )
  {
    _.assert( _.strIs( o.hasExtension ) || _.strsAre( o.hasExtension ) );

    o.hasExtension = _.arrayAs( o.hasExtension );
    o.hasExtension = new RegExp( '^\\.\\/.+\\.(' + _.regexpEscape( o.hasExtension ).join( '|' ) + ')$', 'i' );

    _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.hasExtension } );
    o.hasExtension = null;
  }

  if( o.begins )
  {
    _.assert( _.strIs( o.begins ) || _.strsAre( o.begins ) );

    o.begins = _.arrayAs( o.begins );
    o.begins = new RegExp( '^(\\.\\/)?(' + _.regexpEscape( o.begins ).join( '|' ) + ')' );

    o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.begins } );
    o.begins = null;
  }

  if( o.ends )
  {
    _.assert( _.strIs( o.ends ) || _.strsAre( o.ends ) );

    o.ends = _.arrayAs( o.ends );
    o.ends = new RegExp( '(' + _.regexpEscape( o.ends ).join( '|' ) + ')$' );

    o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.ends } );
    o.ends = null;
  }

  /* */

  if( o.globOut )
  {
    // var globRegexp = _.regexpForGlob( o.globOut );
    var globRegexp = _.regexpForGlob2( o.globOut );
    o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : globRegexp } );
  }
  o.globOut = null;
  delete o.globOut;

  /* */

  if( o.notOlder )
  _.assert( _.numberIs( o.notOlder ) );

  if( o.notNewer )
  _.assert( _.numberIs( o.notNewer ) );

  return o;
}

_filesFindMasksAdjust.defaults =
{

  hasExtension : null,
  begins : null,
  ends : null,
  globIn : null,

  maskAll : null,
  maskTerminal : null,
  maskDir : null,

  notOlder : null,
  notNewer : null,
  notOlderAge : null,
  notNewerAge : null,

}

//

function _filesFilterForm( o )
{
  var self = this;

  if( o.filter && o.filter.formed )
  {
    debugger;
    _.assertMapHasNone( o,_filesFilterForm.defaults );
    debugger;
    return o;
  }

  var fo = _.mapScreen( _filesFilterForm.defaults,o );
  _.mapDelete( o,_filesFilterForm.defaults );

  if( o.filter )
  o.filter.copy( fo );
  else
  o.filter = _.FileRecordFilter( fo );

  _.assert( o.filter.fileProvider === null || o.filter.fileProvider === self );

  if( o.filePath )
  o.filePath = self.pathsNormalize( o.filePath );
  if( o.basePath )
  o.basePath = self.pathsNormalize( o.basePath );

  o.filter.fileProvider = self;
  o.filter.filePath = o.filePath;
  o.filter.basePath = o.basePath;

  o.filter.form();

  o.filePath = o.filter.filePath;
  o.basePath = o.filter.basePath;

  _.assert( arguments.length === 1 );

  return o;
}

_.assert( _.FileRecordFilter.prototype.Composes );
_filesFilterForm.defaults = Object.create( _.FileRecordFilter.prototype.Composes );

// --
//
// --

function _filesFindFast( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assertMapHasAll( o,_filesFindFast.defaults );
  _.assertMapHasOnly( o,_filesFindFast.defaults );
  _.assert( _.strIs( o.filePath ),'expects string { filePath }' );
  _.assert( _.arrayIs( o.onUp ) );
  _.assert( _.arrayIs( o.onDown ) );
  _.assert( o.fileProvider === undefined );
  _.assert( self.pathIsNormalized( o.filePath ) );

  var result = o.result = o.result || [];

  if( o.basePath === undefined || o.basePath === null )
  o.basePath = o.filePath;

  if( !o.fileProviderEffective )
  if( _.urlIsGlobal( o.filePath ) )
  {
    debugger;
    o.fileProviderEffective = self.providerForPath( o.filePath );
    _.assert( o.fileProviderEffective );
    o.filePath = o.fileProviderEffective.localFromUrl( o.filePath );
  }
  else
  {
    o.fileProviderEffective = self;
  }

  Object.freeze( o );

  _.assert( !_.urlIsGlobal( o.filePath ) );

  if( o.ignoringNonexistent )
  if( !self.fileStat( o.filePath ) )
  return result;

  var resultAdd = resultAdd_functor( o );
  forPath( o.filePath,o,true );

  /* */

  function handleUp( record )
  {
    _.assert( _.arrayIs( o.onUp ) );

    for( var i = 0 ; i < o.onUp.length ; i++ )
    {
      var routine = o.onUp[ i ];
      var record = routine.call( self,record,o );
      _.assert( record !== undefined );
      if( record === false )
      return false;
    }

    return record;
  }

  /* add result */

  function resultAdd_functor( o )
  {
    var resultAdd;

    if( o.outputFormat === 'absolute' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1 );
      // if( record instanceof _.FileRecord )
      // if( _.arrayLeftIndexOf( o.result,record.absolute ) >= 0 )
      // {
      //   debugger;
      //   return;
      // }
      o.result.push( record.absolute );
    }
    else if( o.outputFormat === 'relative' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1 );
      // if( record instanceof _.FileRecord )
      // if( _.arrayLeftIndexOf( o.result,record.relative ) >= 0 )
      // {
      //   debugger;
      //   return;
      // }
      o.result.push( record.relative );
    }
    else if( o.outputFormat === 'record' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1 );
      // if( record instanceof _.FileRecord )
      // if( _.arrayLeftIndexOf( o.result,record.absolute,function( e ){ return e.absolute; } ) >= 0 )
      // {
      //   debugger;
      //   return;
      // }
      o.result.push( record );
    }
    else if( o.outputFormat === 'nothing' )
    resultAdd = function( record )
    {
    }
    else _.assert( 0,'unexpected output format :',o.outputFormat );

    return resultAdd;
  }

  /* */

  function forPath( filePath,o,isBase )
  {
    var dir = filePath;

    _.assert( o.basePath );
    var recordContext = _.FileRecordContext.tollerantMake( o,{ fileProvider : self } );
    _.assert( recordContext.dir === null );
    var record = self.fileRecord( filePath,recordContext );

    forFile( record,o,isBase );
  }

  /* */

  function forFile( record,o,isBase )
  {

    if( record._isDir() )
    forDirectory( record,o,isBase )
    else
    forTerminal( record,o,isBase )
  }

  /* */

  function forDirectory( dirRecord,o,isBase )
  {

    if( !dirRecord._isDir() )
    return;
    if( !dirRecord.inclusion )
    return;

    var files = o.fileProviderEffective.directoryRead({ filePath : dirRecord.absolute, outputFormat : 'absolute' });
    // var files = o.fileProviderEffective.directoryRead({ filePath : dirRecord.real, outputFormat : 'absolute' });

    if( o.ignoringNonexistent )
    if( files === null )
    files = [];

    var recordContext = dirRecord.context;
    files = self.fileRecords( files,recordContext );

    if( o.includingDirectories )
    if( o.includingBase || !isBase )
    {
      dirRecord = handleUp( dirRecord );

      if( dirRecord === false )
      return false;

      resultAdd( dirRecord );
    }

    /* terminals */

    if( o.recursive || isBase )
    if( o.includingTerminals )
    for( var f = 0 ; f < files.length ; f++ )
    {
      var fileRecord = files[ f ];
      forTerminal( fileRecord,o );
    }

    /* dirs */

    if( o.recursive || isBase )
    for( var f = 0 ; f < files.length ; f++ )
    {
      var subdirRecord = files[ f ];
      forDirectory( subdirRecord,o );
    }

    /* */

    if( o.includingDirectories )
    if( o.includingBase || !isBase )
    _.routinesCall( self,o.onDown,[ dirRecord,o ] );

  }

  /* */

  function forTerminal( record,o,isBase )
  {

    if( !o.includingTerminals )
    return;
    if( record._isDir() )
    return;
    if( !record.inclusion )
    return;
    if( !o.includingBase && isBase )
    return;

    record = handleUp( record );

    if( record === false )
    return false;

    resultAdd( record );

    _.routinesCall( self,o.onDown,[ record,o ] );

  }

  return result;
}

_filesFindFast.defaults =
{

  filePath : null,
  basePath : null,

  ignoringNonexistent : 0,
  includingTerminals : 1,
  includingDirectories : 0,
  includingBase : 1,

  recursive : 0,
  resolvingSoftLink : 1,
  resolvingTextLink : 0,

  outputFormat : 'record',
  result : [],

  onUp : [],
  onDown : [],

  fileProviderEffective : null,
  filter : null,

}

// _filesFindFast.defaults.__proto__ = _filesFilterForm.defaults;

_filesFindFast.paths =
{
  filePath : null,
  basePath : null,
}

var having = _filesFindFast.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

function _filesFindBody( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  if( !o.filePath )
  _.assert( o.globIn );

  if( !_.arrayIs( o.onUp ) )
  o.onUp = o.onUp ? [ o.onUp ] : [];
  if( !_.arrayIs( o.onDown ) )
  o.onDown = o.onDown ? [ o.onDown ] : [];

  _.assert( o.filePath,'filesFind :','expects "filePath"' );

  var time;
  if( o.verbosity >= 2 )
  time = _.timeNow();

  if( o.verbosity >= 3 )
  logger.log( 'filesFind',_.toStr( o,{ levels : 2 } ) );

  if( o.fileProvider === null )
  o.fileProvider = self;

  o.filePath = _.arrayAs( o.filePath );

  o.result = o.result || [];

  /* find for several pathes */

  function forPaths( paths,o )
  {

    if( _.strIs( paths ) )
    paths = [ paths ];
    paths = _.arrayUnique( paths );

    _.assert( _.arrayIs( paths ),'expects string or array' );

    for( var p = 0 ; p < paths.length ; p++ )
    {
      var filePath = paths[ p ];
      var options = Object.assign( Object.create( null ),o );

      delete options.orderingExclusion;
      delete options.sortingWithArray;
      delete options.verbosity;
      options.filePath = filePath;

      self._filesFindFast( options );

    }

  }

  /* find files in order */

  _.assert( !o.orderingExclusion.length || o.orderingExclusion.length === 0 || o.outputFormat === 'record' );

  forPaths( o.filePath,_.mapExtend( null,o ) );

  o.result = self.recordsOrder( o.result, o.orderingExclusion );

  // var orderingExclusion = _.RegexpObject.order( o.orderingExclusion || [] );
  // if( !orderingExclusion.length )
  // {
  //   forPaths( o.filePath,_.mapExtend( null,o ) );
  // }
  // else
  // {
  //   var maskTerminal = o.maskTerminal;
  //   for( var e = 0 ; e < orderingExclusion.length ; e++ )
  //   {
  //     o.maskTerminal = _.RegexpObject.shrink( Object.create( null ),maskTerminal,orderingExclusion[ e ] );
  //     forPaths( o.filePath,_.mapExtend( null,o ) );
  //   }
  // }

  /* sort */

  if( o.sortingWithArray )
  {

    _.assert( _.arrayIs( o.sortingWithArray ) );

    if( o.outputFormat === 'record' )
    o.result.sort( function( a,b )
    {
      return _.regexpArrayIndex( o.sortingWithArray,a.relative ) - _.regexpArrayIndex( o.sortingWithArray,b.relative );
    })
    else
    o.result.sort( function( a,b )
    {
      return _.regexpArrayIndex( o.sortingWithArray,a ) - _.regexpArrayIndex( o.sortingWithArray,b );
    });

  }

  /* timing */

  if( o.verbosity >= 2 )
  logger.log( _.timeSpent( 'filesFind ' + o.result.length + ' files at ' + o.filePath + ' in',time ) );

  return o.result;
}

var defaults = _filesFindBody.defaults = Object.create( _filesFindFast.defaults );

defaults.orderingExclusion = [];
defaults.sortingWithArray = null;
defaults.verbosity = null;

_.mapExtend( _filesFindBody.defaults, _filesFilterForm.defaults );

var paths = _filesFindBody.paths = Object.create( _filesFindFast.paths );
var having = _filesFindBody.having = Object.create( _filesFindFast.having );

//

function filesFind()
{
  var self = this;

  var o = self._filesFindPre( filesFind,arguments );

  self._filesFindBody( o );

  return o.result;
}

filesFind.pre = _filesFindPre;
filesFind.body = _filesFindBody;

var defaults = filesFind.defaults = Object.create( _filesFindBody.defaults );
var paths = filesFind.paths = Object.create( _filesFindBody.paths );
var having = filesFind.having = Object.create( _filesFindBody.having );

//

function filesFindRecursive( o )
{
  var self = this;

  var o = self.__filesFindOptions( arguments,1 );

  _.routineOptions( filesFindRecursive,o );

  return self.filesFind( o );
}

var defaults = filesFindRecursive.defaults = Object.create( filesFind.defaults )

defaults.filePath = '/';
defaults.recursive = 1;
defaults.includingDirectories = 1;
defaults.includingTerminals = 1;

var paths = filesFindRecursive.paths = Object.create( filesFind.paths );
var having = filesFindRecursive.having = Object.create( filesFind.having );

//

function filesGlob( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { globIn : o }

  if( o.outputFormat === undefined )
  o.outputFormat = 'absolute';

  if( o.recursive === undefined )
  o.recursive = 1;

  if( !o.globIn )
  o.globIn = o.recursive ? '**' : '*';

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( o ) );
  _.assert( _.strIs( o.globIn ) || _.arrayIs( o.globIn ) );

  var result = self.filesFind( o );

  return result;
}

var defaults = filesGlob.defaults = Object.create( filesFind.defaults )
var paths = filesGlob.paths = Object.create( filesFind.paths );
var having = filesGlob.having = Object.create( filesFind.having );

// --
// difference
// --

function filesFindDifference( dst,src,o )
{
  var self = this;
  // var providerIsHub = _.FileProvider.Hub && self instanceof _.FileProvider.Hub;

  /* options */

  if( _.objectIs( dst ) )
  {
    o = dst;
    dst = o.dst;
    src = o.src;
  }

  var self = this;
  var o = ( o || Object.create( null ) );
  o.dst = dst;
  o.src = src;

  _.assert( arguments.length === 1 || arguments.length === 3 );
  _.routineOptions( filesFindDifference,o );
  self._providerOptions( o );
  self._filesFindGlobAdjust( o );
  self._filesFindMasksAdjust( o );

  _.strIs( o.dst );
  _.strIs( o.src );

  var ext = o.ext;
  var result = o.result = o.result || [];

  if( o.read !== undefined || o.hash !== undefined || o.latters !== undefined )
  throw _.err( 'such options are deprecated',_.toStr( o ) );

  /* */

  function resultAdd_functor( o )
  {
    var resultAdd;

    if( o.outputFormat === 'absolute' )
    resultAdd = function( record )
    {
      o.result.push([ record.src.absolute,record.dst.absolute ]);
    }
    else if( o.outputFormat === 'relative' )
    resultAdd = function( record )
    {
      o.result.push([ record.src.relative,record.dst.relative ]);
    }
    else if( o.outputFormat === 'record' )
    resultAdd = function( record )
    {
      o.result.push( record );
    }
    else if( o.outputFormat === 'nothing' )
    resultAdd = function( record )
    {
    }
    else throw _.err( 'unexpected output format :',o.outputFormat );

    return resultAdd;
  }

  var resultAdd = resultAdd_functor( o );

  /* safety */

  o.dst = self.pathNormalize( o.dst );
  o.src = self.pathNormalize( o.src );

  if( o.src !== o.dst && _.strBegins( o.src,o.dst ) )
  {
    debugger;
    throw _.err( 'Overwrite of itself','\nsrc :',o.src,'\ndst :',o.dst )
  }

  if( o.src !== o.dst && _.strBegins( o.dst,o.src ) )
  {
    var exclude = '^' + o.dst.substr( o.src.length+1 ) + '($|\/)';
    _.RegexpObject.shrink( o.maskAll,{ excludeAny : new RegExp( exclude ) } );
  }

  /* dst */

  var dstOptions =
  {
    dir : dst,
    basePath : dst,
    fileProvider : self,
    strict : 0,
  }

  if( dstOptions.fileProvider.providerForPath )
  {
    dstOptions.fileProvider = dstOptions.fileProvider.providerForPath( dst );
    dstOptions.dir = dstOptions.fileProvider.localFromUrl( dstOptions.dir );
    dstOptions.basePath = dstOptions.fileProvider.localFromUrl( dstOptions.basePath );
  }

  dstOptions = _.FileRecordContext.tollerantMake( o,dstOptions );

  /* src */

  var srcOptions =
  {
    dir : src,
    basePath : src,
    fileProvider : self,
    strict : 0,
  }

  if( srcOptions.fileProvider.providerForPath )
  {
    srcOptions.fileProvider = srcOptions.fileProvider.providerForPath( src );
    srcOptions.dir = srcOptions.fileProvider.localFromUrl( srcOptions.dir );
    srcOptions.basePath = srcOptions.fileProvider.localFromUrl( srcOptions.basePath );
  }

  srcOptions = _.FileRecordContext.tollerantMake( o,srcOptions );

  /* src file */

  function srcFile( dstOptions,srcOptions,file )
  {

    var srcRecord = new FileRecord( file,_.FileRecordContext( srcOptions ) );
    srcRecord.side = 'src';

    if( srcRecord._isDir() )
    return;
    if( !srcRecord.inclusion )
    return;

    var dstRecord = new FileRecord( file,_.FileRecordContext( dstOptions ) );
    dstRecord.side = 'dst';
    if( _.strIs( ext ) && !dstRecord._isDir() )
    {
      dstRecord.absolute = _.pathChangeExt( dstRecord.absolute,ext );
      dstRecord.relative = _.pathChangeExt( dstRecord.relative,ext );
    }

    var record =
    {
      relative : srcRecord.relative,
      dst : dstRecord,
      src : srcRecord,
      newer : srcRecord,
      older : null,
    }

    _.assert( srcRecord.stat,'cant get stat of',srcRecord.absolute );

    if( dstRecord.stat )
    {

      if( srcRecord.hash === undefined )
      if( srcRecord.stat.size > o.maxSize )
      srcRecord.hash = NaN;

      if( dstRecord.hash === undefined )
      if( dstRecord.stat.size > o.maxSize )
      dstRecord.hash = NaN;

      if( !dstRecord._isDir() )
      {
        record.same = self.filesSame( dstRecord, srcRecord, o.usingTiming );
        record.link = self.filesAreHardLinked( dstRecord.absolute, srcRecord.absolute );
      }
      else
      {
        record.same = false;
        record.link = false;
      }

      record.newer = _.filesNewer( dstRecord, srcRecord );
      record.older = _.filesOlder( dstRecord, srcRecord );

    }

    _.routinesCallUntilFalse( o,o.onUp,[ record ] );
    resultAdd( record );
    _.routinesCall( self,o.onDown,[ record ] );

  }

  /* src directory */

  function srcDir( dstOptions,srcOptions,file,recursive )
  {

    var srcRecord = new FileRecord( file,srcOptions );
    srcRecord.side = 'src';

    if( !srcRecord._isDir() )
    return;
    if( !srcRecord.inclusion )
    return;

    var dstRecord = new FileRecord( file,dstOptions );
    dstRecord.side = 'dst';

    /**/

    if( o.includingDirectories )
    {

      var record =
      {
        relative : srcRecord.relative,
        dst : dstRecord,
        src : srcRecord,
        newer : srcRecord,
        older : null,
      }

      if( dstRecord.stat )
      {
        record.newer = _.filesNewer( dstRecord, srcRecord );
        record.older = _.filesOlder( dstRecord, srcRecord );
        if( !dstRecord._isDir() )
        record.same = false;
      }

      _.routinesCallUntilFalse( o,o.onUp,[ record ] );
      resultAdd( record );

    }

    if( o.recursive && recursive )
    {

      _.assert( dstOptions instanceof _.FileRecordContext );
      _.assert( srcOptions instanceof _.FileRecordContext );

      var dstOptionsSub = _.FileRecordContext.tollerantMake( dstOptions,{ dir : dstRecord.absolute } );
      var srcOptionsSub = _.FileRecordContext.tollerantMake( srcOptions,{ dir : srcRecord.absolute } );

      filesFindDifferenceAct( dstOptionsSub,srcOptionsSub );
    }

    if( o.includingDirectories )
    _.routinesCall( self,o.onDown,[ record ] );

  }

  /* dst file */

  function dstFile( dstOptions,srcOptions,file )
  {
    var srcRecord = new FileRecord( file,srcOptions );
    srcRecord.side = 'src';
    var dstRecord = new FileRecord( file,dstOptions );
    dstRecord.side = 'dst';
    if( ext !== undefined && ext !== null && !dstRecord._isDir() )
    {
      dstRecord.absolute = _.pathChangeExt( dstRecord.absolute,ext );
      dstRecord.relative = _.pathChangeExt( dstRecord.relative,ext );
    }

    if( dstRecord._isDir() )
    return;

    var check = false;
    check = check || !srcRecord.inclusion;
    check = check || !srcRecord.stat;

    if( !check )
    return;

    var record =
    {
      relative : srcRecord.relative,
      dst : dstRecord,
      src : srcRecord,
      del : true,
      newer : dstRecord,
      older : null,
    };

    delete srcRecord.stat;

    _.routinesCallUntilFalse( o,o.onUp,[ record ] );
    resultAdd( record );
    _.routinesCall( self,o.onDown,[ record ] );

  }

  /* dst directory */

  function dstDir( dstOptions,srcOptions,file,recursive )
  {

    var srcRecord = new FileRecord( file,srcOptions );
    srcRecord.side = 'src';
    var dstRecord = new FileRecord( file,dstOptions );
    dstRecord.side = 'dst';

    if( !dstRecord._isDir() )
    return;

    var check = false;
    check = check || !srcRecord.inclusion;
    check = check || !srcRecord.stat;
    check = check || !srcRecord._isDir();

    if( !check )
    return;

    if( o.includingDirectories && ( !srcRecord.inclusion || !srcRecord.stat ) )
    {

      var record =
      {
        relative : srcRecord.relative,
        dst : dstRecord,
        src : srcRecord,
        del : true,
        newer : dstRecord,
        older : null,
      };

      _.routinesCallUntilFalse( o,o.onUp,[ record ] );
      resultAdd( record );

    }

    if( o.recursive && recursive )
    {

      var found = self.filesFind
      ({
        includingDirectories : o.includingDirectories,
        includingTerminals : o.includingTerminals,
        filePath : dstRecord.absolute,
        outputFormat : 'record',
        recursive : 1,
      })

      _.assert( srcOptions instanceof _.FileRecordContext );
      var srcOptions = _.FileRecordContext.tollerantMake( srcOptions,{ dir : null } );

      if( found.length && found[ 0 ].absolute === dstRecord.absolute )
      found.splice( 0, 1 );

      for( var fo = 0 ; fo < found.length ; fo++ )
      {
        var dstRecord = new FileRecord( found[ fo ].absolute,dstOptions );
        dstRecord.side = 'dst';
        var srcRecord = new FileRecord( dstRecord.relative,srcOptions );
        srcRecord.side = 'src';
        var rec =
        {
          relative : srcRecord.relative,
          dst : dstRecord,
          src : srcRecord,
          del : true,
          newer : dstRecord,
          older : null,
        }

        found[ fo ] = rec;
        _.routinesCallUntilFalse( o,o.onUp,[ rec ] );
        resultAdd( rec );
      }

      if( o.onDown.length )
      for( var fo = found.length-1 ; fo >= 0 ; fo-- )
      {
        _.routinesCall( self,o.onDown,[ found[ fo ] ] );
      }

    }

    if( record )
    _.routinesCall( self,o.onDown,[ record ] );

  }

  /* act */

  function filesFindDifferenceAct( dstOptions,srcOptions )
  {

    /* dst */

    var dstRecord = new FileRecord( dstOptions.dir,dstOptions );
    if( o.investigateDestination )
    if( dstRecord.stat && dstRecord.stat.isDirectory() )
    {

      var files = self.directoryRead( dstRecord.absoluteEffective );
      if( !files )
      debugger;

      if( o.includingTerminals )
      for( var f = 0 ; f < files.length ; f++ )
      dstFile( dstOptions,srcOptions,files[ f ] );

      for( var f = 0 ; f < files.length ; f++ )
      dstDir( dstOptions,srcOptions,files[ f ],1 );

    }

    /* src */

    var srcRecord = new FileRecord( srcOptions.dir,srcOptions );
    if( srcRecord.stat && srcRecord.stat.isDirectory() )
    {

      var files = self.directoryRead( srcRecord.absoluteEffective );
      if( !files )
      debugger;

      if( o.includingTerminals )
      for( var f = 0 ; f < files.length ; f++ )
      srcFile( dstOptions,srcOptions,files[ f ] );

      for( var f = 0 ; f < files.length ; f++ )
      srcDir( dstOptions,srcOptions,files[ f ],1 );

    }

  }

  /* launch */

  dstFile( dstOptions,srcOptions,'.' );
  dstDir( dstOptions,srcOptions,'.',1 );

  srcFile( dstOptions,srcOptions,'.' );
  srcDir( dstOptions,srcOptions,'.',1 );

  return result;
}

filesFindDifference.defaults =
{
  outputFormat : 'record',
  ext : null,
  investigateDestination : 1,

  maxSize : 1 << 21,
  usingTime : 1,
  recursive : 0,

  includingTerminals : 1,
  includingDirectories : 1,

  resolvingSoftLink : 0,
  resolvingTextLink : 0,

  filter : null,
  result : null,
  src : null,
  dst : null,

  onUp : [],
  onDown : [],
}

filesFindDifference.defaults.__proto__ = _filesFindMasksAdjust.defaults

var paths = filesFindDifference.paths = Object.create( null );

paths.src = null;
paths.dst = null;

var having = filesFindDifference.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

/*

* level : 0, 1, 2
(
  presence : missing, present
  +
  if present
  (
    * kind of file : directory, terminal
    * linkage of file : ordinary, soft
  )
)

^ where file : src, dst

3 * ( 1 + 2 * 2  ) ^ 2 = 3 * 9 ^ 2 = 81

*/

function filesCopy( o )
{
  var self = this;
  var providerIsHub = _.FileProvider.Hub && self instanceof _.FileProvider.Hub;

  if( arguments.length === 2 )
  o = { dst : arguments[ 0 ] , src : arguments[ 1 ] }

  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( !o.allowDelete && o.investigateDestination === undefined )
  o.investigateDestination = 0;

  if( o.allowRewrite === undefined )
  o.allowRewrite = filesCopy.defaults.allowRewrite;

  if( o.allowRewrite && o.allowWrite === undefined )
  o.allowWrite = 1;

  if( o.allowRewrite && o.allowRewriteFileByDir === undefined  )
  o.allowRewriteFileByDir = true;

  _.routineOptions( filesCopy,o );
  self._providerOptions( o );
  // debugger;
  // o = self._filesFindPre( filesCopy,[ o ] );
  // debugger;

  var includingDirectories = o.includingDirectories !== undefined ? o.includingDirectories : 1;
  var onUp = _.arrayAs( o.onUp );
  var onDown = _.arrayAs( o.onDown );
  var directories = Object.create( null );

  /* safe */

  if( self.safe )
  if( o.removingSource && ( !o.allowWrite || !o.allowRewrite ) )
  throw _.err( 'not safe removingSource:1 with allowWrite:0 or allowRewrite:0' );

  /* make dir */

  var dirname = _.pathDir( o.dst );

  if( self.safe )
  if( !_.pathIsSafe( dirname ) )
  throw _.err( dirname,'Unsafe to use :',dirname );

  o.filter = _.FileRecordFilter.tollerantMake( o,{ fileProvider : self } ).form();
  var recordDir = self.fileRecord( dirname,{ filter : o.filter } );
  var rewriteDir = recordDir.stat && !recordDir.stat.isDirectory();
  if( rewriteDir )
  if( o.allowRewrite )
  {

    debugger;
    throw _.err( 'not tested' );
    if( o.verbosity )
    logger.log( '- rewritten file by directory :',dirname );
    self.fileDelete({ filePath : filePath });
    self.directoryMake({ filePath : dirname, force : 1 });

  }
  else
  {
    throw _.err( 'cant rewrite',dirname );
  }

  /* on up */

  function handleUp( record )
  {

    /* same */

    if( o.tryingPreserve )
    if( record.same && record.link == o.linking )
    {
      record.action = 'same';
      record.allowed = true;
    }

    /* delete redundant */

    if( record.del )
    {

      if( record.dst && record.dst.stat )
      {
        if( o.allowDelete )
        {
          record.action = 'deleted';
          record.allowed = true;

        }
        else
        {
          record.action = 'deleted';
          record.allowed = false;

        }
      }
      else
      {
        record.action = 'ignored';
        record.allowed = false;
      }

      return;
    }

    /* preserve directory */

    if( !record.action )
    {

      /*if( o.tryingPreserve )*/
      if( record.src.stat && record.dst.stat )
      if( record.src.stat.isDirectory() && record.dst.stat.isDirectory() )
      {
        directories[ record.dst.absolute ] = true;
        record.action = 'directory preserved';
        record.allowed = true;
        if( o.preservingTime )
        self.fileTimeSet( record.dst.absoluteEffective, record.src.stat );
      }

    }

    /* rewrite */

    if( !record.action )
    {

      var rewriteFile = !!record.dst.stat;

      if( rewriteFile )
      {

        if( !o.allowRewriteFileByDir && record.src.stat && record.src.stat.isDirectory() )
        rewriteFile = false;

        if( rewriteFile && o.allowRewrite && o.allowWrite )
        {
          rewriteFile = record.dst.real + '.' + _.idWithDate() + '.back' ;
          self.fileRename
          ({
            dstPath : rewriteFile,
            srcPath : record.dst.real,
            verbosity : 0,
          });
          delete record.dst.stat;
        }
        else
        {
          rewriteFile = false;
          record.action = 'cant rewrite';
          record.allowed = false;
          if( o.verbosity )
          logger.log( '? cant rewrite :',record.dst.absolute );
        }

      }

    }

    /* new directory */

    if( !record.action && record.src.stat && record.src.stat.isDirectory() )
    {

      directories[ record.dst.absolute ] = true;
      record.action = 'directory new';
      record.allowed = false;
      if( o.allowWrite )
      {
        self.directoryMake({ filePath : record.dst.absoluteEffective, force : 1 });
        if( o.preservingTime )
        self.fileTimeSet( record.dst.absoluteEffective, record.src.stat );
        record.allowed = true;
      }

    }

    /* directory for dst */

    if( !record.action && record.src.stat && record.src.stat.isFile() )
    {
      directories[ record.dst.dir ] = true;

      if( !record.dst.stat && !self.fileStat( record.dst.dir ) )
      {
        if( o.allowWrite )
        {
          if( providerIsHub )
          self.directoryMake( record.dst.fileProvider.urlFromLocal( record.dst.dir ) );
          else
          self.directoryMake( record.dst.dir );

          if( o.preservingTime )
          {
            if( providerIsHub )
            self.fileTimeSet( record.dst.fileProvider.urlFromLocal( record.dst.dir ), record.src.stat );
            else
            self.fileTimeSet( record.dst.dir, record.src.stat );
          }

          record.allowed = true;
        }
        else
        directories[ record.dst.dir ] = false;
      }
    }

    /* unknown */

    if( !record.action && record.src.stat && !record.src.stat.isFile() )
    {
      throw _.err( 'unknown kind of source : it is unsafe to proceed :\n' + _.fileReport( record.src ) + '\n' );
    }

    /* is write possible */

    if( !record.action )
    {

      if( !directories[ record.dst.dir ] )
      {
        record.action = 'cant rewrite';
        record.allowed = false;
        return;
      }

    }

    /* write */

    if( !record.action )
    {

      if( o.linking )
      {

        record.action = 'linked';
        record.allowed = false;

        if( o.allowWrite )
        {
          record.allowed = true;
          self.linkHard({ dstPath : record.dst.absolute, srcPath : record.src.real, sync : 1, verbosity : o.verbosity });
        }

      }
      else
      {

        record.action = 'copied';
        record.allowed = false;

        if( o.allowWrite )
        {
          record.allowed = true;
          if( o.resolvingTextLink )
          record.dst.real = _.pathResolveTextLink( record.dst.real, true );

          if( o.verbosity )
          debugger;
          if( o.verbosity )
          logger.log( '+ ' + record.action + ' :',record.dst.real );

          self.fileCopy( record.dst.absoluteEffective,record.src.absoluteEffective );

          if( o.preservingTime )
          {
            self.fileTimeSet( record.dst.absoluteEffective, record.src.stat );
          }
        }

      }

    }

    /* rewrite */

    if( rewriteFile && o.allowRewrite )
    {
      self.filesDelete
      ({
        filePath : rewriteFile,
        throwing : 1,
      });
    }

    /* callback */

    if( !includingDirectories && record.src.stat && record.src.stat.isDirectory() )
    return;

    _.routinesCallUntilFalse( o,onUp,[ record ] );

  }

  /* on down */

  function handleDown( record )
  {

    _.assert( record.action !== 'linked' || !record.del );

    /* delete redundant */

    if( record.action === 'deleted' )
    {
      if( record.allowed )
      {
        if( o.verbosity )
        logger.log( '- deleted :',record.dst.real );
        self.filesDelete({ filePath : record.dst.real, throwing : 0 });
        delete record.dst.stat;
      }
      else
      {
        if( o.verbosity && !o.silentPreserve )
        logger.log( '? not deleted :',record.dst.absolute );
      }
    }

    /* remove source */

    var removingSource = false;
    removingSource = removingSource || o.removingSource;
    removingSource = removingSource || ( o.removingSourceTerminals && !record.src._isDir() );

    if( removingSource && record.src.stat && record.src.inclusion )
    {
      if( o.verbosity )
      logger.log( '- removed-source :',record.src.real );
      self.fileDelete( record.src.real );
      delete record.src.stat;
    }

    /* callback */

    if( !includingDirectories && record.src._isDir() )
    return;

    _.routinesCall( self,onDown,[ record ] );

  }

  /* launch */

  try
  {

    var findOptions = _.mapScreen( filesFindDifference.defaults,o );
    findOptions.onUp = handleUp;
    findOptions.onDown = handleDown;
    findOptions.includingDirectories = true;

    var records = self.filesFindDifference( o.dst,o.src,findOptions );

    if( o.verbosity )
    if( !records.length && o.outputFormat !== 'nothing' )
    logger.log( '? copy :', 'nothing was copied :',o.dst,'<-',o.src );

    if( !includingDirectories )
    {
      records = records.filter( function( e )
      {
        if( e.src.stat && e.src._isDir() )
        return false;

        if( e.src.stat && !e.src._isDir() )
        return true;

        if( e.dst.stat && e.dst._isDir() )
        return false;

        return true;
      });
    }

  }
  catch( err )
  {
    debugger;
    throw _.err( 'filesCopy( ',_.toStr( o ),' )','\n',err );
  }

  return records;
}

var defaults = filesCopy.defaults = Object.create( filesFindDifference.defaults );

defaults.verbosity = 1;
defaults.linking = 0;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

defaults.removingSource = 0;
defaults.removingSourceTerminals = 0;

defaults.recursive = 1;
defaults.allowDelete = 0;
defaults.allowWrite = 0;
defaults.allowRewrite = 1;
defaults.allowRewriteFileByDir = 0;

defaults.tryingPreserve = 1;
defaults.silentPreserve = 1;
defaults.preservingTime = 1;

var paths = filesCopy.paths = Object.create( filesFindDifference.paths );
var having = filesCopy.having = Object.create( filesFindDifference.having );

//

function _filesMovePre( routine,args )
{
  var self = this;

  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 || args.length === 2 );

  var o = args[ 0 ]
  if( args.length === 2 )
  o = { dstPath : args[ 0 ] , srcPath : args[ 1 ] }

  _.routineOptions( routine,o );
  self._providerOptions( o );

  if( !_.arrayIs( o.onUp ) )
  o.onUp = o.onUp ? [ o.onUp ] : [];
  if( !_.arrayIs( o.onDown ) )
  o.onDown = o.onDown ? [ o.onDown ] : [];

  _.assert( o.onDstName === null || _.routineIs( o.onDstName ) );

  if( !o.srcProvider )
  o.srcProvider = self;
  if( !o.dstProvider )
  o.dstProvider = self;

  o.srcPath = self.pathNormalize( o.srcPath );
  o.dstPath = self.pathNormalize( o.dstPath );

  if( o.filter )
  o.filter = self.fileRecordFilter( o.filter );
  if( o.srcFilter )
  o.srcFilter = self.fileRecordFilter( o.srcFilter );
  if( o.dstFilter )
  o.dstFilter = self.fileRecordFilter( o.dstFilter );

  if( !o.srcFilter )
  o.srcFilter = o.filter;
  else if( o.filter && o.filter !== o.srcFilter )
  o.srcFilter.shrink( o.filter );

  if( !o.dstFilter )
  o.dstFilter = o.filter;
  else if( o.filter && o.filter !== o.dstFilter )
  o.dstFilter.shrink( o.filter );

  if( !o.srcFilter )
  o.srcFilter = _.FileRecordFilter();
  if( !o.dstFilter )
  o.dstFilter = _.FileRecordFilter();

  if( !o.srcFilter.formed )
  {
    o.srcFilter.filePath = o.srcPath;
    o.srcFilter.fileProvider = o.srcProvider;
    o.srcFilter.form();
    o.srcPath = o.srcFilter.filePath;
  }
  if( !o.dstFilter.formed )
  {
    o.dstFilter.filePath = o.dstPath;
    o.dstFilter.fileProvider = o.dstProvider;
    o.dstFilter.form();
    o.dstPath = o.dstFilter.filePath;
  }

  // self._filesFindPre( o );
  // self._filesFindGlobAdjust( o );
  // self._filesFindMasksAdjust( o );

  return o;
}

//

function _filesMoveFastBody( o )
{
  var self = this;

  _.assert( self.pathIsNormalized( o.srcPath ) );
  _.assert( self.pathIsNormalized( o.dstPath ) );

  if( o.result === null )
  o.result = [];

  if( o.includingDst === null || o.includingDst === undefined )
  o.includingDst = 0;

  var resultAdd = resultAdd_functor( o );

  _.assert( arguments.length === 1 || arguments.length === 2 );

  /* add result */

  function resultAdd_functor( o )
  {
    var resultAdd;

    if( o.outputFormat === 'src.absolute' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1 );
      o.result.push( record.src.absolute );
    }
    else if( o.outputFormat === 'src.relative' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1 );
      o.result.push( record.src.relative );
    }
    else if( o.outputFormat === 'dst.absolute' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1 );
      o.result.push( record.dst.absolute );
    }
    else if( o.outputFormat === 'dst.relative' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1 );
      o.result.push( record.dst.relative );
    }
    else if( o.outputFormat === 'record' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1 );
      o.result.push( record );
    }
    else if( o.outputFormat === 'nothing' )
    resultAdd = function( record )
    {
    }
    else _.assert( 0,'unexpected output format :',o.outputFormat );

    return resultAdd;
  }

  /* */

  function recordMake( dstRecord,srcRecord,effectiveRecord )
  {
    var record = Object.create( null )
    record.dst = dstRecord;
    record.src = srcRecord;
    record.effective = effectiveRecord;
    record.upToDate = 0;
    return record;
  }

  /* */

  function handleUp( record,op,isDst )
  {

    if( !o.includingDst && isDst )
    return record;

    if( !o.includingDirectories && record.effective._isDir() )
    return record;

    if( !o.includingTerminals && !record.effective._isDir() )
    return record;

    _.assert( _.arrayIs( o.onUp ) );
    _.assert( arguments.length === 3 );

    for( var i = 0 ; i < o.onUp.length ; i++ )
    {
      var routine = o.onUp[ i ];
      var record = routine.call( self,record,o );
      _.assert( record !== undefined );
      if( record === false )
      return false;
    }

    return record;
  }

  /* */

  function handleDown( record,isDst )
  {
    _.assert( _.arrayIs( o.onDown ) );
    _.assert( record.dst && record.src );

    if( !o.includingDst && isDst )
    return record;

    if( !o.includingDirectories && record.effective._isDir() )
    return record;

    if( !o.includingTerminals && !record.effective._isDir() )
    return record;

    _.routinesCall( self,o.onDown,[ record,o ] );
  }

  /* */

  function handleDstUpDeleting( dstRecord,op )
  {
    var srcRecord = self.fileRecord( dstRecord.relative,srcRecordContext );
    var record = recordMake( dstRecord,srcRecord,dstRecord );
    record.dstAction = 'deleting';
    record = handleUp( record,op,1 );
    if( record === false )
    return false;
    resultAdd( record );
    return record;
  }

  /* */

  function handleDstUpRewriting( dstRecord,op )
  {
    var srcRecord = self.fileRecord( dstRecord.relative,srcRecordContext );
    var record = recordMake( dstRecord,srcRecord,dstRecord );
    record.dstAction = 'rewriting';
    record = handleUp( record,op,1 );
    if( record === false )
    return false;
    resultAdd( record );
    return record;
  }

  /* */

  function handleDstDown( record,op )
  {
    handleDown( record,1 );
  }

  /* */

  function handleSrcUp( srcRecord,op )
  {
    var relative = srcRecord.relative;
    if( o.onDstName )
    relative = o.onDstName.call( self,relative,dstRecordContext,op,o );

    var dstRecord = self.fileRecord( relative,dstRecordContext );
    var record = recordMake( dstRecord,srcRecord,srcRecord );

    if( o.filesGraph )
    {
      if( record.dst.absolute === o.dstPath )
      {
        o.filesGraph.dstPath = o.dstPath;
        o.filesGraph.srcPath = o.srcPath;
        o.filesGraph.actionBegin( o.dstPath + ' <- ' + o.srcPath );
        // o.filesGraph.storageLoad( record.dst );
      }
      if( !record.src._isDir() )
      {
        o.filesGraph.filesUpdate( record.dst );
        o.filesGraph.filesUpdate( record.src );
        if( o.filesGraph.fileIsUpToDate( record.dst ) )
        record.upToDate = 1;
      }
    }

    record = handleUp( record,op,0 );
    if( record === false )
    return false;
    resultAdd( record );

    if( o.includingDst )
    if( record.dst._isDir() && !record.src._isDir() )
    {
      var dstOptions2 = _.mapExtend( null,dstOptions );
      dstOptions2.filePath = record.dst.absolute;
      dstOptions2.onUp = [ handleDstUpRewriting ];
      self._filesFindFast( dstOptions2 );
    }

    return record;
  }

  /* */

  function handleSrcDown( record,t )
  {

    if( o.filesGraph && !record.src._isDir() && !record.upToDate )
    {
      debugger;
      record.dst.restat();
      o.filesGraph.dependencyAdd( record.dst, record.src );
    }

    if( o.includingDst )
    if( record.dst._isDir() && record.src._isDir() )
    {
      var dstFiles = o.dstProvider.directoryRead({ filePath : record.dst.absolute, basePath : dstOptions.basePath });
      var srcFiles = o.srcProvider.directoryRead({ filePath : record.src.absolute, basePath : srcOptions.basePath });
      _.arrayRemoveArrayOnce( dstFiles,srcFiles );
      for( var f = 0 ; f < dstFiles.length ; f++ )
      {
        var dstOptions2 = _.mapExtend( null,dstOptions );
        dstOptions2.filePath = dstFiles[ f ];
        dstOptions2.onUp = [ handleDstUpDeleting ];
        self._filesFindFast( dstOptions2 );
      }
    }

    handleDown( record,0 );

    if( o.filesGraph )
    {
      if( record.dst.absolute === o.dstPath )
      o.filesGraph.actionEnd();
    }

  }

  /* */

  var o2 =
  {
    basePath : o.srcPath,
    fileProvider : self,
    fileProviderEffective : o.srcProvider,
    filter : o.srcFilter,
  }
  var srcRecordContext = _.FileRecordContext.tollerantMake( o,o2 );
  var srcOptions = _.mapScreen( self._filesFindFast.defaults,o );
  srcOptions.includingDirectories = 1;
  srcOptions.includingTerminals = 1;
  srcOptions.includingBase = 1;
  srcOptions.filter = o.srcFilter;
  srcOptions.filePath = o.srcPath;
  srcOptions.basePath = o.srcPath;
  srcOptions.result = null;
  srcOptions.fileProviderEffective = o.srcProvider;
  _.mapSupplement( srcOptions,self._filesFindFast.defaults );

  /* */

  var o2 =
  {
    basePath : o.dstPath,
    fileProvider : self,
    fileProviderEffective : o.dstProvider,
    filter : o.dstFilter,
  }
  var dstRecordContext = _.FileRecordContext.tollerantMake( o,o2 );
  var dstOptions = _.mapExtend( null,srcOptions );
  dstOptions.filter = o.dstFilter;
  dstOptions.filePath = o.dstPath;
  dstOptions.basePath = o.dstPath;
  dstOptions.includingTerminals = 1;
  dstOptions.includingDirectories = 1;
  dstOptions.includingBase = 1;
  dstOptions.recursive = 1;
  dstOptions.fileProviderEffective = o.dstProvider;

  /* */

  srcOptions.onDown = [ handleSrcDown ];
  srcOptions.onUp = [ handleSrcUp ];
  dstOptions.onDown = [ handleDstDown ];

  /* */

  self._filesFindFast( srcOptions );

  return o.result;
}

var defaults = _filesMoveFastBody.defaults = Object.create( null );

defaults.srcPath = null;
defaults.dstPath = null;

defaults.srcProvider = null;
defaults.dstProvider = null;

defaults.filesGraph = null;
defaults.filter = null;
defaults.srcFilter = null;
defaults.dstFilter = null;

defaults.result = null;
defaults.outputFormat = 'record';

defaults.ignoringNonexistent = 0;
defaults.includingTerminals = 1;
defaults.includingDirectories = 1;
defaults.includingBase = 1;
defaults.includingDst = null;

defaults.recursive = 1;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

defaults.onUp = null;
defaults.onDown = null;
defaults.onDstName = null;

var paths = _filesMoveFastBody.paths = Object.create( null );

paths.srcPath = null;
paths.dstPath = null;

var having = _filesMoveFastBody.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

function filesMoveFast( o )
{
  var self = this;
  var o = self._filesMovePre( filesMoveFast,arguments );
  return self._filesMoveFastBody( o );
}

filesMoveFast.pre = _filesMovePre;
filesMoveFast.body = _filesMoveFastBody;

var defaults = filesMoveFast.defaults = Object.create( _filesMoveFastBody );
var paths = filesMoveFast.paths = Object.create( _filesMoveFastBody );
var having = filesMoveFast.having = Object.create( _filesMoveFastBody );

//

function _filesMoveBody( o )
{
  var self = this;

  if( o.includingDst === null || o.includingDst === undefined )
  o.includingDst = o.dstDeleting;

  _.assert( arguments.length === 1 );
  _.assert( !o.dstDeleting || o.includingDst );
  _.assert( _.arrayHas( [ 'fileCopy','hardlink','softlink','nop' ], o.linking ), 'unknown kind of linking', o.linking );

  /* */

  function terminalPreserved( record )
  {
    _.assert( !record.action );
    record.action = 'terminalPreserved';
    return record;
  }

  /* */

  function upToDate( record )
  {
    _.assert( !record.action );
    record.action = 'upToDate';
    return record;
  }

  /* */

  function notAllowed( record,_continue )
  {
    _.assert( !record.action );
    _.assert( arguments.length === 2 );
    record.action = 'notAllowed';
    if( _continue )
    return record;
    else
    return false;
  }

  /* */

  function canLink( record )
  {
    if( !o.preservingSame )
    return true;

    if( o.linking === 'fileCopy' )
    {
      if( self.filesAreSame( record.dst, record.src ) )
      {
        // record.action = 'terminalPreserved';
        return false;
      }
    }

    return true;
  }

  /* */

  function link( record )
  {
    _.assert( !record.action );
    _.assert( !record.upToDate );
    _.assert( o.writing );

    if( o.linking === 'hardlink' )
    {
      /* qqq : should not change any time of file if linked */
      self.linkHard( record.dst.absoluteEffective, record.src.absoluteEffective );
      record.action = o.linking;
    }
    else if( o.linking === 'softlink' )
    {
      /* qqq : should not change any time of file if linked */
      self.linkSoft( record.dst.absoluteEffective, record.src.absoluteEffective );
      record.action = o.linking;
    }
    else if( o.linking === 'fileCopy' )
    {
      self.fileCopy( record.dst.absoluteEffective, record.src.absoluteEffective );
      record.action = o.linking;
    }
    else if( o.linking === 'nop' )
    {
      record.action = o.linking;
    }
    else _.assert( 0 );

  }

  /* */

  function handleUp( record,op )
  {

    // if( _.strEnds( record.src.relative,'dir1' ) || _.strEnds( record.src.relative,'dir4' ) )
    // debugger;

    if( !record.src.stat )
    {
      return record;
    }
    else if( record.src._isDir() )
    {

      if( !record.dst.stat )
      {
        if( !o.writing )
        return notAllowed( record,true );
        o.dstProvider.directoryMake( record.dst.absolute );
        record.action = 'directoryMake';
      }
      else if( record.dst._isDir() )
      {
        record.action = 'directoryPreserve';
      }
      else
      {
        if( !o.dstRewritingByDistinct || !o.dstRewriting )
        return notAllowed( record,false );
        if( !o.writing )
        return notAllowed( record,true );

        o.dstProvider.fileDelete( record.dst.absolute );
        o.dstProvider.directoryMake( record.dst.absolute );
        record.action = 'directoryMake';
      }

    }
    else
    {

      if( !record.dst.stat )
      {
        if( !o.writing )
        return notAllowed( record,true );
        if( record.upToDate )
        return upToDate( record );
        if( !canLink( record ) )
        return terminalPreserved( record );
        link( record );
      }
      else if( record.dst._isDir() )
      {
        if( !o.dstRewritingByDistinct || !o.dstRewriting )
        return notAllowed( record,false );
        if( !o.writing )
        return notAllowed( record,true );
        return record;
      }
      else
      {
        if( !o.dstRewriting )
        return notAllowed( record,false );
        if( !o.writing )
        return notAllowed( record,true );
        if( record.upToDate )
        return upToDate( record );
        if( !canLink( record ) )
        return terminalPreserved( record );
        o.dstProvider.fileDelete( record.dst.absolute );
        link( record );
      }

    }

    if( o.preservingTime )
    o.dstProvider.fileTimeSet( record.dst.absoluteEffective, record.src.stat );

    return record;
  }

  /* */

  function handleDown( record,op )
  {

    // if( _.strEnds( record.src.relative,'dir1' ) || _.strEnds( record.src.relative,'dir4' ) )
    // debugger;

    if( !record.src.stat )
    {
      _.assert( record.dst.stat );

      if( !o.writing )
      return record;
      if( record.dstAction === 'deleting' && !o.dstDeleting )
      return record;
      if( record.dstAction === 'rewriting' && !o.dstRewriting )
      return record;

      record.dstAction = null;
      record.action = 'fileDelete';
      o.dstProvider.fileDelete( record.dst.absolute );

    }
    else if( record.src._isDir() )
    {

      if( !record.dst.stat )
      {
      }
      else if( record.dst._isDir() )
      {
      }
      else
      {
        if( record.dstAction === 'rewriting' && !o.dstRewriting )
        return record;
        record.dstAction = null;
        _.assert( record.action );
      }

    }
    else
    {

      if( !record.dst.stat )
      {
      }
      else if( record.dst._isDir() )
      {

        if( !o.dstRewritingByDistinct || !o.dstRewriting )
        return false;

        if( !o.writing )
        return record;

        if( !canLink( record ) )
        return terminalPreserved( record );

        record.dstAction = null;

        if( o.includingDst )
        o.dstProvider.fileDelete( record.dst.absolute );
        else
        o.dstProvider.filesDelete( record.dst.absolute );

        link( record );

      }
      else
      {
      }

    }

    _.assert( !record.dstAction );
    _.assert( record.action );

    if( o.srcDeleting && o.writing )
    {

      if( !record.src.stat )
      {
      }
      else if( record.src._isDir() )
      {
        if( record.action === 'directoryMake' || record.action === 'directoryPreserve' )
        if( !o.srcProvider.directoryRead( record.src.absolute ).length )
        o.srcProvider.fileDelete( record.src.absolute );
      }
      else
      {
        if( record.action === 'linkHard' || record.action === 'fileCopy' )
        o.srcProvider.fileDelete( record.src.absolute );
      }

    }

    return record;
  }

  /* */

  o.onUp = _.arrayPrepend( o.onUp || [],handleUp );
  o.onDown = _.arrayPrepend( o.onDown || [],handleDown );

  var result = self._filesMoveFastBody( _.mapScreen( self._filesMoveFastBody.defaults,o ) );

  return result;
}

var defaults = _filesMoveBody.defaults = Object.create( _filesMoveFastBody.defaults );

defaults.linking = 'fileCopy';
defaults.srcDeleting = 0;
defaults.dstDeleting = 0;
defaults.writing = 1;
defaults.dstRewriting = 1;
defaults.dstRewritingByDistinct = 1;
defaults.preservingTime = 0;
defaults.preservingSame = 0;

defaults.orderingExclusion = [];
defaults.sortingWithArray = null;

var paths = _filesMoveBody.paths = Object.create( _filesMoveFastBody.paths );
var having = _filesMoveBody.having = Object.create( _filesMoveFastBody.having );

//

function filesMove( o )
{
  var self = this;
  var o = self._filesMovePre( filesMove,arguments );
  var result = self._filesMoveBody( o );
  return result;
}

filesMove.pre = _filesMovePre;
filesMove.body = _filesMoveBody;

var defaults = filesMove.defaults = Object.create( _filesMoveBody.defaults );
var paths = filesMove.paths = Object.create( _filesMoveBody.paths );
var having = filesMove.having = Object.create( _filesMoveBody.having );

// --
// same
// --

function filesFindSame()
{
  var self = this;
  var o = self._filesFindPre( filesFindSame,arguments );

  // _filesFindMasksAdjust( o );
  //
  // _.routineOptions( filesFindSame,o );
  // self._providerOptions( o );

  if( !o.filePath )
  throw _.err( 'filesFindSame :','expects "o.filePath"' );

  /* output format */

  o.outputFormat = 'record';

  /* result */

  var result = o.result;
  _.assert( _.objectIs( result ) );

  if( !result.sameContent && o.usingContentComparing ) result.sameContent = [];
  if( !result.sameName && o.usingSameNameCollecting ) result.sameName = [];
  if( !result.linked && o.usingLinkedCollecting ) result.linked = []
  if( !result.similar && o.similarity ) result.similar = [];

  /* time */

  var time;
  if( o.usingTiming )
  time = _.timeNow();

  /* find */

  var findOptions = _.mapScreen( filesFind.defaults,o );
  findOptions.outputFormat = 'record';
  findOptions.result = [];
  findOptions.strict = 0;
  result.unique = self.filesFind( findOptions );

  /* adjust found */

  for( var f1 = 0 ; f1 < result.unique.length ; f1++ )
  {

    var file1 = result.unique[ f1 ];

    if( !file1.stat )
    {
      console.warn( 'WARN : cant read : ' + file1.absolute );
      continue;
    }

    if( o.usingContentComparing )
    if( file1.hash === undefined )
    {
      if( file1.stat.size > o.maxSize )
      file1.hash = NaN;
    }

  }

  /* link */

  function checkLink()
  {

    if( self.filesAreHardLinked( file1.absolute,file2.absolute ) )
    {
      file2._linked = 1;
      if( o.usingLinkedCollecting )
      linkedRecord.push( file2 );
      return true;
    }

    return false;
  }

  /* content */

  function checkContent()
  {

    // if( file1.absolute.indexOf( 'NameTools.s' ) !== -1 && file2.absolute.indexOf( 'NameTools.s' ) !== -1 )
    // debugger;

    var same = false;
    if( o.usingContentComparing )
    same = self.filesSame( file1,file2,o.usingTiming );
    if( same )
    {

      if( o.usingTakingNameIntoAccountComparingContent && file1.file !== file2.file )
      return false;

      if( !file2._haveSameContent )
      {
        file2._haveSameContent = 1;
        sameContentRecord.push( file2 );
        return true;
      }

    }

    return false;
  }

  /* similarity */

  function checkSimilarity()
  {

    if( o.similarity )
    if( file1.stat.size <= o.lattersFileSizeLimit && file1.stat.size <= o.lattersFileSizeLimit )
    if( Math.min( file1.stat.size,file2.stat.size ) / Math.max( file1.stat.size,file2.stat.size ) >= o.similarity )
    {
      var similarity = _.filesSimilarity({ src1 : file1, src2 : file2 });
      if( similarity >= o.similarity )
      {
        /*var similarity = _.filesSimilarity({ src1 : file1, src2 : file2 });*/
        result.similar.push({ files : [ file1,file2 ], similarity : similarity });
        return true;
      }
    }

    return false;
  }

  /* name */

  function checkName()
  {

    if( o.usingSameNameCollecting )
    if( file1.file === file2.file && !file2._haveSameName )
    {
      file2._haveSameName = 1;
      sameNameRecord.push( file2 );
      return true;
    }

    return false;
  }

  /* compare */

  var sameNameRecord, sameContentRecord, linkedRecord;
  for( var f1 = 0 ; f1 < result.unique.length ; f1++ )
  {

    var file1 = result.unique[ f1 ];

    if( !file1.stat )
    continue;

    sameNameRecord = [ file1 ];
    sameContentRecord = [ file1 ];
    linkedRecord = [ file1 ];

    for( var f2 = f1 + 1 ; f2 < result.unique.length ; f2++ )
    {

      var file2 = result.unique[ f2 ];

      if( !file2.stat )
      continue;

      checkName();

      if( checkLink() )
      {
        result.unique.splice( f2,1 );
        f2 -= 1;
      }
      else if( checkContent() )
      {
        result.unique.splice( f2,1 );
        f2 -= 1;
      }
      else
      {
        checkSimilarity();
      }

    }

    /* store */

    if( linkedRecord && linkedRecord.length > 1 )
    {
      if( !o.usingFast )
      _.assert( _.arrayCountUnique( linkedRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in linkedRecord' );
      result.linked.push( linkedRecord );
    }

    if( sameContentRecord && sameContentRecord.length > 1  )
    {
      if( !o.usingFast )
      _.assert( _.arrayCountUnique( sameContentRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in sameContentRecord' );
      result.sameContent.push( sameContentRecord );
    }

    if( sameNameRecord && sameNameRecord.length > 1 )
    {
      if( !o.usingFast )
      _.assert( _.arrayCountUnique( sameNameRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in sameNameRecord' );
      result.sameName.push( sameNameRecord );
    }

  }

  /* output format */

  if( o.outputFormat !== 'record' )
  throw _.err( 'not tested' );

  if( o.outputFormat !== 'record' )
  for( var r in result )
  {
    if( r === 'unique' )
    result[ r ] = _.entitySelect( result[ r ],'*.' + o.outputFormat );
    else
    result[ r ] = _.entitySelect( result[ r ],'*.*.' + o.outputFormat );
  }

  /* validation */

  _.accessorForbid( result,{ same : 'same' } );

  /* timing */

  if( o.usingTiming )
  logger.log( _.timeSpent( 'Spent to find same at ' + o.filePath,time ) );

  return result;
}

var defaults = filesFindSame.defaults = Object.create( filesFind.defaults );

defaults.maxSize = 1 << 22;
defaults.lattersFileSizeLimit = 1048576;
defaults.similarity = 0;

defaults.usingFast = 1;
defaults.usingContentComparing = 1;
defaults.usingTakingNameIntoAccountComparingContent = 1;
defaults.usingLinkedCollecting = 0;
defaults.usingSameNameCollecting = 0;

defaults.usingTiming = 0;

defaults.result = {};

var paths = filesFindSame.paths = Object.create( filesFind.paths );
var having = filesFindSame.having = Object.create( filesFind.having );

// --
// delete
// --

function _filesDeletePre( routine,args )
{
  var self = this;
  var args = _.arraySlice( args );
  if( args[ 1 ] === undefined )
  args[ 1 ] = null;
  var o = self._filesFindPre( routine,args );
  return o;
}

//

function _filesDeleteBody()
{
  var self = this;

  var time;
  if( o.verbosity >= 2 )
  time = _.timeNow();

  _.assert( o.resolvingTextLink === 0 || o.resolvingTextLink === false );
  _.assert( o.resolvingSoftLink === 0 || o.resolvingSoftLink === false );
  _.assert( o.outputFormat === 'record' );
  _.assert( arguments.length === 1 || arguments.length === 3 );

  /* */

  var stat = self.fileStat( o.filePath );

  if( !stat )
  return;

  if( stat.isFile() )
  return self.fileDelete
  ({
    filePath : o.filePath,
    sync : 1,
    throwing :  o.throwing,
    verbosity : o.verbosity
  });

  /* */

  var optionsForFind = _.mapScreen( self.filesFind.defaults,o );
  optionsForFind.verbosity = 0;
  self.fieldSet( 'resolvingSoftLink', 0 );
  var files = self._filesFindBody( optionsForFind );
  self.fieldReset( 'resolvingSoftLink', 0 );

  /* */

  for( var f = files.length-1 ; f >= 0 ; f-- )
  {
    var file = files[ f ];
    file.context.fileProviderEffective.fileDelete
    ({
      filePath : file.absolute,
      sync : 1,
      throwing : o.throwing,
      verbosity : o.verbosity,
    });
  }

  if( o.verbosity >= 2 )
  logger.log( _.timeSpent( 'filesDelete ' + o.result.length + ' files at ' + o.filePath + ' in',time ) );

}

var defaults = _filesDeleteBody.defaults = Object.create( filesFind.defaults );

defaults.outputFormat = 'record';
defaults.recursive = 1;
defaults.includingDirectories = 1;
defaults.includingTerminals = 1;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

defaults.verbosity = null;
defaults.throwing = null;

var paths = _filesDeleteBody.paths = Object.create( filesFind.paths );
var having = _filesDeleteBody.having = Object.create( filesFind.having );

//

function filesDelete()
{
  var self = this;
  var o = self._filesDeletePre( filesDelete,arguments );

  var time;
  if( o.verbosity >= 2 )
  time = _.timeNow();

  _.assert( o.resolvingTextLink === 0 || o.resolvingTextLink === false );
  _.assert( o.resolvingSoftLink === 0 || o.resolvingSoftLink === false );
  _.assert( o.outputFormat === 'record' );
  _.assert( arguments.length === 1 || arguments.length === 3 );

  /* */

  var optionsForFind = _.mapScreen( self.filesFind.defaults,o );
  optionsForFind.verbosity = 0;
  self.fieldSet( 'resolvingSoftLink', 0 );
  var files = self._filesFindBody( optionsForFind );
  self.fieldReset( 'resolvingSoftLink', 0 );

  /* */

  for( var f = files.length-1 ; f >= 0 ; f-- )
  {
    var file = files[ f ];
    file.context.fileProviderEffective.fileDelete
    ({
      filePath : file.absolute,
      sync : 1,
      throwing : o.throwing,
      verbosity : o.verbosity,
    });
  }

  if( o.verbosity >= 2 )
  logger.log( _.timeSpent( 'filesDelete ' + o.result.length + ' files at ' + o.filePath + ' in',time ) );

}

filesDelete.pre = _filesDeletePre;
filesDelete.body = _filesDeleteBody;

var defaults = filesDelete.defaults = Object.create( _filesDeleteBody.defaults );
var paths = filesDelete.paths = Object.create( _filesDeleteBody.paths );
var having = filesDelete.having = Object.create( _filesDeleteBody.having );

//

function filesDeleteForce( o )
{
  var self = this;

  var o = self.__filesFindOptions( arguments,0 );

  _.routineOptions( filesDeleteForce, o );

  return self.filesDelete( o );
}

var defaults = filesDeleteForce.defaults = Object.create( filesDelete.defaults );

defaults.maskAll = null;

var paths = filesDeleteForce.paths = Object.create( filesDelete.paths );
var having = filesDeleteForce.having = Object.create( filesDelete.having );

//

function filesDeleteFiles( o )
{
  var self = this;

  var o = self.__filesFindOptions( arguments,0 );

  _.routineOptions( filesDeleteFiles, o );

  return self.filesDelete( o );
}

var defaults = filesDeleteFiles.defaults = Object.create( filesDelete.defaults );

defaults.recursive = 1;
defaults.includingDirectories = 0;
defaults.includingTerminals = 1;

var paths = filesDeleteFiles.paths = Object.create( filesDelete.paths );
var having = filesDeleteFiles.having = Object.create( filesDelete.having );

//

// function filesDeleteDirs( o )
// {
//   var self = this;

//   debugger;

//   var o = self.__filesFindOptions( arguments,0 );

//   _.routineOptions( filesDeleteDirs, o );

//   return self.filesDelete( o );
// }

// var defaults = filesDeleteDirs.defaults = Object.create( filesDelete.defaults );

// defaults.recursive = 1;
// defaults.includingDirectories = 1;
// defaults.includingTerminals = 0;

// var paths = filesDeleteDirs.paths = Object.create( filesDelete.paths );
// var having = filesDeleteDirs.having = Object.create( filesDelete.having );

//

function filesDeleteEmptyDirs()
{
  var self = this;

  // _.assert( arguments.length === 1 || arguments.length === 3 );
  // var o = self.__filesFindOptions( arguments,1 );

  debugger;
  var o = self._filesDeletePre( filesDeleteEmptyDirs,arguments );
  debugger;

  /* */

  o.outputFormat = 'absolute';
  o.includingTerminals = 0;
  o.includingDirectories = 1;
  if( o.recursive === undefined )
  o.recursive = 1;

  // _.routineOptions( filesDeleteEmptyDirs, o );

  /* */

  var options = _.mapScreen( self._filesFindBody.defaults,o );

  options.onDown = _.arrayAppend( _.arrayAs( o.onDown ), function( record )
  {

    try
    {

      var sub = self.directoryRead( record.absolute );
      if( !sub )
      debugger;

      if( !sub.length )
      {
        if( self.verbosity >= 2 )
        logger.log( '- deleted :',record.absolute );
        self.fileDelete({ filePath : record.absolute, throwing : o.throwing });
      }
    }
    catch( err )
    {
      if( !o.throwing )
      throw _.err( err );
    }

  });

  debugger;
  var files = self._filesFindBody( options );
  debugger;

  // return new _.Consequence().give();
}

filesDeleteEmptyDirs.pre = _filesDeletePre;

var defaults = filesDeleteEmptyDirs.defaults = Object.create( filesDelete.defaults );

defaults.throwing = false;
defaults.verbosity = null;
defaults.outputFormat = 'absolute';
defaults.includingTerminals = 0;
defaults.includingDirectories = 1;
defaults.recursive = 1;

var paths = filesDeleteEmptyDirs.paths = Object.create( filesDelete.paths );
var having = filesDeleteEmptyDirs.having = Object.create( filesDelete.having );

// --
// other find
// --

/*

self.linksTerminate
({
  filePath : o.filePath,
  recursive : 1,
  onUp : onUp,
});

*/

function linksTerminate( o )
{
  var self = this;

  var o = self._filesFindPre( linksTerminate,arguments );

  _.assert( o.outputFormat = 'absolute' );

  // _.routineOptions( linksTerminate,o );
  // self._providerOptions( o );

  /* */

  function terminate( record )
  {
    debugger;
    if( self.fileIsHardLink( record.absolute ) && o.terminatingHardLinks )
    self.hardLinkTerminate( record.absolute );
    else if( self.fileIsSoftLink( record.absolute ) && o.terminatingSoftLinks )
    self.softLinkTerminate( record.absolute );
    else return record;
    return terminate( record );
  }

  /* */

  var optionsFind = _.mapScreen( filesFind.defaults,o );
  optionsFind.onDown = _.arrayAppend( _.arrayAs( optionsFind.onDown ), function( record )
  {
    terminate( record );
  });

  var files = self.filesFind( optionsFind );

  return;
}

var defaults = linksTerminate.defaults = Object.create( filesFind.defaults );

defaults.outputFormat = 'absolute';
defaults.terminatingHardLinks = 1;
defaults.terminatingSoftLinks = 1;
defaults.terminatingTextLinks = 0;
defaults.recursive = 1;

var paths = linksTerminate.paths = Object.create( filesFind.paths );
var having = linksTerminate.having = Object.create( filesFind.having );

//

// function filesResolve( o )
// {
//   var self = this;
//   var result = [];
//   var o = _.routineOptions( filesResolve,args );
//
//   debugger;
//   _.assert( _.strIs( o.pathLookRoot ) );
//
//   o.pathLookRoot = self.pathNormalize( o.pathLookRoot );
//
//   if( !o.pathOutputRoot )
//   o.pathOutputRoot = o.pathLookRoot;
//   else
//   o.pathOutputRoot = self.pathNormalize( o.pathOutputRoot );
//
//   if( o.usingRecord === undefined )
//   o.usingRecord = true;
//
//   var globIn = _filesResolveMakeGlob( o );
//
//   var globOptions = _.mapScreen( self.filesGlob.defaults,o );
//   globOptions.globIn = globIn;
//   globOptions.basePath = o.pathOutputRoot;
//   globOptions.outputFormat = o.outputFormat;
//
//   _.assert( self );
//
//   var result = self.filesGlob( globOptions );
//
//   return result;
// }
//
// var defaults = filesResolve.defaults = Object.create( filesGlob.defaults );
//
// defaults.recursive = 1;
// defaults.outputFormat = 'record';
//
// defaults.pathGlob = null;
// defaults.pathVirtualRoot = null;
// defaults.pathVirtualDir = null;
// defaults.pathLookRoot = null;
// defaults.pathOutputRoot = null;
//
// var paths = filesResolve.paths = Object.create( filesGlob.paths );
//
// paths.pathGlob = null;
// paths.pathVirtualRoot = null;
// paths.pathVirtualDir = null;
// paths.pathLookRoot = null;
// paths.pathOutputRoot = null;
//
// var having = filesResolve.having = Object.create( filesGlob.having );
//
// //
//
// function _filesResolveMakeGlob( options )
// {
//   var pathGlob = options.pathGlob;
//
//   _.assert( options.pathVirtualRoot === options.pathLookRoot,'not tested' );
//
// /*
//   if( options.pathVirtualRoot !== options.pathVirtualDir )
//   debugger;
// */
//
//   _.assert( _.objectIs( options ) );
//   _.assert( _.strIs( options.pathGlob ) );
//   _.assert( _.strIs( options.pathVirtualDir ) );
//   _.assert( _.strIs( options.pathLookRoot ) );
//
//   if( options.pathVirtualRoot === undefined )
//   options.pathVirtualRoot = options.pathLookRoot;
//
//   if( pathGlob[ 0 ] !== '/' )
//   {
//     pathGlob = _.pathReroot( options.pathVirtualDir,pathGlob );
//     pathGlob = _.pathRelative( options.pathVirtualRoot,pathGlob );
//   }
//
//   if( _.strBegins( pathGlob,options.pathLookRoot ) )
//   {
//     debugger;
//     _.errLog( 'probably something wrong with pathGlob :',pathGlob );
//     throw _.err( 'probably something wrong with pathGlob :',pathGlob );
//   }
//
//   var result = pathGlob;
//   result = _.pathReroot( options.pathLookRoot,pathGlob );
//
//   return result;
// }

//

function filesResolve2( o )
{
  var self = this;
  var result;
  var o = _.routineOptions( filesResolve2,arguments );

  _.assert( o.pathTranslator );

  var globPath = o.pathTranslator.realFor( o.globPath2 );
  var globOptions = _.mapScreen( self.filesGlob.defaults,o );
  globOptions.globIn = globPath;
  globOptions.basePath = o.pathTranslator.realRootPath;
  globOptions.outputFormat = o.outputFormat;

  _.assert( self );

  var result = self.filesGlob( globOptions );

  return result;
}

var defaults = filesResolve2.defaults = Object.create( filesGlob.defaults );

defaults.recursive = 1;
defaults.globPath2 = null;
defaults.pathTranslator = null;
defaults.outputFormat = 'record';

var paths = filesResolve2.paths = Object.create( filesGlob.paths );

paths.globPath2 = null;

var having = filesResolve2.having = Object.create( filesGlob.having );

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

  // details

  recordsOrder : recordsOrder,
  _filesFindMasksSupplement : _filesFindMasksSupplement,

  __filesFindOptions : __filesFindOptions,
  _filesFindPre : _filesFindPre,
  _filesFindGlobAdjust : _filesFindGlobAdjust,
  _filesFindMasksAdjust : _filesFindMasksAdjust,
  _filesFilterForm : _filesFilterForm,


  // find

  _filesFindFast : _filesFindFast,
  _filesFindBody : _filesFindBody,
  filesFind : filesFind,
  filesFindRecursive : filesFindRecursive,
  filesGlob : filesGlob,


  // difference

  filesFindDifference : filesFindDifference,
  filesCopy : filesCopy,


  // move

  _filesMovePre : _filesMovePre,
  _filesMoveFastBody : _filesMoveFastBody,
  filesMoveFast : filesMoveFast,
  _filesMoveBody : _filesMoveBody,
  filesMove : filesMove,


  // same

  filesFindSame : filesFindSame,


  // delete

  _filesDeletePre : _filesDeletePre,
  _filesDeleteBody : _filesDeleteBody,
  filesDelete : filesDelete,

  filesDeleteForce : filesDeleteForce,
  filesDeleteFiles : filesDeleteFiles,
  // filesDeleteDirs : filesDeleteDirs,
  filesDeleteEmptyDirs : filesDeleteEmptyDirs,


  // other find

  linksTerminate : linksTerminate,
  // filesResolve : filesResolve,
  // _filesResolveMakeGlob : _filesResolveMakeGlob,
  filesResolve2 : filesResolve2,


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

  name : 'wFilePorviderFindMixin',
  nameShort : 'Find',
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
