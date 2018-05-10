( function _mFindMixin_s_() {

'use strict'; /*ggg*/

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

function _filesFindOptions( args,safe )
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

function _filesFindGlobAdjust( o )
{
  var self = this;

  _.assert( o.glob === undefined );
  _.assert( !o.globOut );

  if( !o.globIn )
  return;

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( o ) );
  _.assert( _.strIs( o.globIn ) || _.arrayIs( o.globIn ) );
  _.assert( o.relative === undefined );

  o.globIn = _.pathsNormalize( o.globIn );

  if( o.filePath )
  o.filePath = _.pathNormalize( o.filePath );

  if( o.basePath )
  o.basePath = _.pathNormalize( o.basePath );

  function pathFromGlob( globIn )
  {
    var result;
    _.assert( _.strIs( globIn ) );
    var i = globIn.search( /[^\\\/]*?(\*\*|\?|\*|\[.*\]|\{.*\}+(?![^[]*\]))[^\\\/]*/ );
    if( i === -1 )
    result = globIn;
    else
    result = globIn.substr( 0,i );
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

  this._filesFindGlobAdjust( o );

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

  maskAll : null,
  maskTerminal : null,
  maskDir : null,

  hasExtension : null,
  begins : null,
  ends : null,
  globIn : null,

  notOlder : null,
  notNewer : null,
  notOlderAge : null,
  notNewerAge : null,

}

// --
//
// --

function _filesFind( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assertMapHasAll( o,_filesFind.defaults );
  _.assertMapHasOnly( o,_filesFind.defaults );
  _.assert( _.strIs( o.filePath ),'expects string { filePath }' );
  _.assert( _.arrayIs( o.onUp ) );
  _.assert( _.arrayIs( o.onDown ) );

  var result = o.result = o.result || [];

  o.filePath = _.pathNormalize( o.filePath );

  if( o.basePath === undefined || o.basePath === null )
  o.basePath = o.filePath;

  Object.freeze( o );

  // if( o.filePath === '/C/pro/web/Dave/app/server/include/dwtools/abase/layer3' )
  // debugger;

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
      if( record instanceof _.FileRecord )
      if( _.arrayLeftIndexOf( o.result,record.absolute ) >= 0 )
      {
        debugger;
        return;
      }
      o.result.push( record.absolute );
    }
    else if( o.outputFormat === 'relative' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1 );
      if( record instanceof _.FileRecord )
      if( _.arrayLeftIndexOf( o.result,record.relative ) >= 0 )
      {
        debugger;
        return;
      }
      o.result.push( record.relative );
    }
    else if( o.outputFormat === 'record' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1 );
      if( record instanceof _.FileRecord )
      if( _.arrayLeftIndexOf( o.result,record.absolute,function( e ){ return e.absolute; } ) >= 0 )
      {
        debugger;
        return;
      }
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
    var recordContext = _.FileRecordContext.tollerantMake( o );
    _.assert( recordContext.dir === null );
    var record = self.fileRecord( filePath,recordContext );

    forFile( record,o,isBase );
  }

  /* */

  function forFile( record,o,isBase )
  {
    // if( self.directoryIs( record.absolute ) )
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

    // var files = self.directoryRead({ filePath : dirRecord.absolute, outputFormat : 'absolute' });
    var files = self.directoryRead({ filePath : dirRecord.real, outputFormat : 'absolute' });

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

_filesFind.defaults =
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

}

_filesFind.defaults.__proto__ = _filesFindMasksAdjust.defaults;

var having = _filesFind.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

function filesFind()
{
  var self = this;

  var o = self._filesFindOptions( arguments,1 );

  if( !o.filePath )
  _.assert( o.globIn );

  _.routineOptions( filesFind,o );
  self._providerOptions( o );
  self._filesFindMasksAdjust( o );

  if( !_.arrayIs( o.onUp ) )
  o.onUp = o.onUp ? [ o.onUp ] : [];
  if( !_.arrayIs( o.onDown ) )
  o.onDown = o.onDown ? [ o.onDown ] : [];

  _.assert( o.filePath,'filesFind :','expects "filePath"' );

  var time;
  if( self.verbosity > 1 )
  time = _.timeNow();

  if( self.verbosity > 2 )
  logger.log( 'filesFind',_.toStr( o,{ levels : 2 } ) );

  o.filePath = _.arrayAs( o.filePath );

  var result = o.result = o.result || [];
  var orderingExclusion = _.RegexpObject.order( o.orderingExclusion || [] );

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
      options.filePath = filePath;

      self._filesFind( options );
    }

  }

  /* find files in order */

  if( !orderingExclusion.length )
  {
    forPaths( o.filePath,_.mapExtend( null,o ) );
  }
  else
  {
    var maskTerminal = o.maskTerminal;
    for( var e = 0 ; e < orderingExclusion.length ; e++ )
    {
      o.maskTerminal = _.RegexpObject.shrink( Object.create( null ),maskTerminal,orderingExclusion[ e ] );
      forPaths( o.filePath,_.mapExtend( null,o ) );
    }
  }

  /* sort */

  if( o.sortingWithArray )
  {

    _.assert( _.arrayIs( o.sortingWithArray ) );

    if( o.outputFormat === 'record' )
    result.sort( function( a,b )
    {
      return _.regexpArrayIndex( o.sortingWithArray,a.relative ) - _.regexpArrayIndex( o.sortingWithArray,b.relative );
    })
    else
    result.sort( function( a,b )
    {
      return _.regexpArrayIndex( o.sortingWithArray,a ) - _.regexpArrayIndex( o.sortingWithArray,b );
    });

  }

  /* timing */

  if( self.verbosity > 1 )
  logger.log( _.timeSpent( 'At ' + o.filePath + ' found ' + result.length + ' in',time ) );

  return result;
}

var defaults = filesFind.defaults = Object.create( _filesFind.defaults );
defaults.orderingExclusion = [];
defaults.sortingWithArray = null;

var having = filesFind.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

function filesFindRecursive( o )
{
  var self = this;

  var o = self._filesFindOptions( arguments,1 );
  _.routineOptions( filesFindRecursive,o );

  return self.filesFind( o );
}

filesFindRecursive.defaults =
{
  filePath : '/',
  recursive : 1,
  includingDirectories : 1,
  includingTerminals : 1,
}

filesFindRecursive.defaults.__proto__ = filesFind.defaults;

var having = filesFindRecursive.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

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

filesGlob.defaults = {};
filesGlob.defaults.__proto__ = filesFind.defaults;

var having = filesGlob.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

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
  self._filesFindMasksAdjust( o );
  _.strIs( o.dst );
  _.strIs( o.src );

  var ext = o.ext;
  var result = o.result = o.result || [];

  if( o.read !== undefined || o.hash !== undefined || o.latters !== undefined )
  throw _.err( 'filesFind :','o are deprecated',_.toStr( o ) );

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

  o.dst = _.pathNormalize( o.dst );
  o.src = _.pathNormalize( o.src );

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

      var files = self.directoryRead( dstRecord.effective );
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

      var files = self.directoryRead( srcRecord.effective );
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

  result : null,
  src : null,
  dst : null,

  onUp : [],
  onDown : [],
}

filesFindDifference.defaults.__proto__ = _filesFindMasksAdjust.defaults

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

  var recordDir = self.fileRecord( dirname );
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
        self.fileTimeSet( record.dst.effective, record.src.stat.atime, record.src.stat.mtime );
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
        self.directoryMake({ filePath : record.dst.effective, force : 1 });
        if( o.preservingTime )
        self.fileTimeSet( record.dst.effective, record.src.stat.atime, record.src.stat.mtime );
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
            self.fileTimeSet( record.dst.fileProvider.urlFromLocal( record.dst.dir ), record.src.stat.atime, record.src.stat.mtime );
            else
            self.fileTimeSet( record.dst.dir, record.src.stat.atime, record.src.stat.mtime );
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

          self.fileCopy( record.dst.effective,record.src.effective );

          if( o.preservingTime )
          {
            self.fileTimeSet( record.dst.effective, record.src.stat.atime, record.src.stat.mtime );
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

filesCopy.defaults =
{

  verbosity : 1,
  linking : 0,
  resolvingSoftLink : 0,
  resolvingTextLink : 0,

  removingSource : 0,
  removingSourceTerminals : 0,

  recursive : 1,
  allowDelete : 0,
  allowWrite : 0,
  allowRewrite : 1,
  allowRewriteFileByDir : 0,

  tryingPreserve : 1,
  silentPreserve : 1,
  preservingTime : 1,

}

filesCopy.defaults.__proto__ = filesFindDifference.defaults;

var having = filesCopy.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.bare = 0;

//

function _filesMoveOptions( routine,args )
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

  // self._filesFindOptions( o );
  // self._filesFindGlobAdjust( o );
  // self._filesFindMasksAdjust( o );

  return o;
}

//

function _filesMove( o )
{
  var self = this;
  var o = self._filesMoveOptions( _filesMove,arguments );

  o.srcPath = _.pathNormalize( o.srcPath );
  o.dstPath = _.pathNormalize( o.dstPath );

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
    return record;
  }

  /* */

  function handleUp( record,isDst )
  {
    _.assert( _.arrayIs( o.onUp ) );

    if( !o.includingDst && isDst )
    return record;

    if( !o.includingDirectories && record.effective._isDir() )
    return record;

    if( !o.includingTerminals && !record.effective._isDir() )
    return record;

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
    record = handleUp( record,1 );
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
    record = handleUp( record,1 );
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

  function handleSrcUp( srcRecord,t )
  {
    var dstRecord = self.fileRecord( srcRecord.relative,dstRecordContext );
    var record = recordMake( dstRecord,srcRecord,srcRecord );

    if( dstRecord._isDir() && record.src._isDir() )
    record._srcFiles = [];

    record = handleUp( record,0 );
    if( record === false )
    return false;
    resultAdd( record );

    if( o.includingDst )
    if( record.dst._isDir() && !record.src._isDir() )
    {
      var dstOptions2 = _.mapExtend( null,dstOptions );
      dstOptions2.filePath = record.dst.absolute;
      dstOptions2.onUp = [ handleDstUpRewriting ];
      // dstOptions2.onUp = _.arrayPrepend( dstOptions2.onUp.slice(),handleDstUpRewriting );
      self.filesFind( dstOptions2 );
    }

    return record;
  }

  /* */

  function handleSrcDown( record,t )
  {

    if( o.includingDst )
    if( record.dst._isDir() && record.src._isDir() )
    {
      var dstFiles = self.directoryRead({ filePath : record.dst.absolute, basePath : dstOptions.basePath });
      var srcFiles = self.directoryRead({ filePath : record.src.absolute, basePath : srcOptions.basePath });
      _.arrayRemoveArrayOnce( dstFiles,srcFiles );
      for( var f = 0 ; f < dstFiles.length ; f++ )
      {
        var dstOptions2 = _.mapExtend( null,dstOptions );
        dstOptions2.filePath = dstFiles[ f ];
        dstOptions2.onUp = [ handleDstUpDeleting ];
        // dstOptions2.onUp = _.arrayPrepend( dstOptions2.onUp.slice(),handleDstUpDeleting );
        self.filesFind( dstOptions2 );
      }
    }

    record._srcFiles = null;

    handleDown( record,0 );
  }

  /* */

  var srcRecordContext = _.FileRecordContext.tollerantMake( o,{ basePath : o.srcPath } );
  var srcOptions = _.mapScreen( self.filesFind.defaults,o );
  srcOptions.filePath = o.srcPath;
  if( !srcOptions.basePath )
  srcOptions.basePath = srcOptions.filePath;
  srcOptions.basePath = o.srcPath;
  srcOptions.result = null;
  _.mapSupplement( srcOptions,self._filesFind.defaults );

  /* */

  var dstRecordContext = _.FileRecordContext.tollerantMake( o,{ basePath : o.dstPath } );
  var dstOptions = _.mapExtend( null,srcOptions );
  dstOptions.filePath = o.dstPath;
  if( !dstOptions.basePath )
  dstOptions.basePath = dstOptions.filePath;
  dstOptions.basePath = o.dstPath;
  dstOptions.includingBase = 0;
  dstOptions.includingTerminals = 1;
  dstOptions.includingDirectories = 1;
  dstOptions.includingBase = 1;
  dstOptions.recursive = 1;

  /* */

  // srcOptions.onDown = _.arrayPrepend( srcOptions.onDown.slice(),handleSrcDown );
  // srcOptions.onUp = _.arrayPrepend( srcOptions.onUp.slice(),handleSrcUp );
  // dstOptions.onDown = _.arrayPrepend( dstOptions.onDown.slice(),handleDstDown );

  srcOptions.onDown = [ handleSrcDown ];
  srcOptions.onUp = [ handleSrcUp ];
  dstOptions.onDown = [ handleDstDown ];

  /* */

  self._filesFind( srcOptions );

  return o.result;
}

_filesMove.defaults =
{

  srcPath : null,
  dstPath : null,

  result : null,
  outputFormat : 'record',

  ignoringNonexistent : 0,
  includingTerminals : 1,
  includingDirectories : 1,
  includingBase : 1,
  includingDst : null,

  recursive : 1,
  resolvingSoftLink : 0,
  resolvingTextLink : 0,

  onUp : null,
  onDown : null,

}

//

function filesMove( o )
{
  var self = this;
  var o = self._filesMoveOptions( filesMove,arguments );

  if( o.includingDst === null || o.includingDst === undefined )
  o.includingDst = o.dstDeleting;

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( !o.dstDeleting || o.includingDst );

  /* */

  function notAllowed( record )
  {
    _.assert( !record.action );
    record.action = 'notAllowed';
    return false;
  }

  /* */

  function link( record )
  {
    _.assert( !record.action );
    if( o.linking )
    {
      self.linkHard( record.dst.absolute,record.src.absolute );
      record.action = 'linkHard';
    }
    else
    {
      self.fileCopy( record.dst.absolute,record.src.absolute );
      record.action = 'fileCopy';
    }
  }

  /* */

  function handleUp( record,op )
  {

    // if( record.dst.absolute === '/dst/dir1' )
    // debugger;

    if( !record.src.stat )
    {
      return record;
    }
    else if( record.src._isDir() )
    {

      if( !record.dst.stat )
      {
        if( !o.dstWriting )
        {
          notAllowed( record );
          return record;
        }
        self.directoryMake( record.dst.absolute );
        record.action = 'directoryMake';
      }
      else if( record.dst._isDir() )
      {
        record.action = 'directoryPreserve';
      }
      else
      {
        if( !o.dstRewritingByDistinct || !o.dstRewriting || !o.dstWriting )
        return notAllowed( record );
        self.fileDelete( record.dst.absolute );
        self.directoryMake( record.dst.absolute );
        record.action = 'directoryMake';
      }

    }
    else
    {

      if( !record.dst.stat )
      {
        if( !o.dstWriting )
        return notAllowed( record );
        link( record );
      }
      else if( record.dst._isDir() )
      {
        if( !o.dstRewritingByDistinct || !o.dstRewriting || !o.dstWriting )
        return notAllowed( record );
        return record;
      }
      else
      {
        if( !o.dstWriting || !o.dstRewriting )
        return notAllowed( record );
        self.fileDelete( record.dst.absolute );
        link( record );
      }

    }

    if( o.preservingTime )
    self.fileTimeSet( record.dst.effective, record.src.stat.atime, record.src.stat.mtime );

    return record;
  }

  /* */

  function handleDown( record,op )
  {

    // if( record.dstAction )
    // debugger;

    if( !record.src.stat )
    {
      _.assert( record.dst.stat );

      if( !o.dstWriting )
      return record;
      if( record.dstAction === 'deleting' && !o.dstDeleting )
      return record;
      if( record.dstAction === 'rewriting' && !o.dstRewriting )
      return record;

      record.dstAction = null;
      record.action = 'fileDelete';
      self.fileDelete( record.dst.absolute );

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

        if( !o.dstRewritingByDistinct || !o.dstRewriting || !o.dstWriting )
        return false;

        record.dstAction = null;

        if( o.includingDst )
        self.fileDelete( record.dst.absolute );
        else
        self.filesDelete( record.dst.absolute );

        link( record );

      }
      else
      {
      }

    }

    _.assert( !record.dstAction );
    _.assert( record.action );

    if( o.srcDeleting && o.dstWriting )
    {

      if( !record.src.stat )
      {
      }
      else if( record.src._isDir() )
      {
        if( record.action === 'directoryMake' || record.action === 'directoryPreserve' )
        if( !self.directoryRead( record.src.absolute ).length )
        self.fileDelete( record.src.absolute );
      }
      else
      {
        if( record.action === 'linkHard' || record.action === 'fileCopy' )
        self.fileDelete( record.src.absolute );
      }

    }

    return record;
  }

  /* */

  o.onUp = _.arrayPrepend( o.onUp || [],handleUp );
  o.onDown = _.arrayPrepend( o.onDown || [],handleDown );

  var result = self._filesMove( _.mapScreen( self._filesMove.defaults,o ) );

  return result;
}

var defaults = filesMove.defaults = Object.create( _filesMove.defaults );

defaults.linking = 0;
defaults.srcDeleting = 0;
defaults.dstDeleting = 0;
defaults.dstWriting = 1;
defaults.dstRewriting = 1;
defaults.dstRewritingByDistinct = 1;
defaults.preservingTime = 0;

// --
// same
// --

function filesFindSame()
{
  var self = this;

  var o = self._filesFindOptions( arguments,1 );
  _filesFindMasksAdjust( o );

  _.routineOptions( filesFindSame,o );
  self._providerOptions( o );

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

filesFindSame.defaults =
{

  maxSize : 1 << 22,
  lattersFileSizeLimit : 1048576,
  similarity : 0,

  usingFast : 1,
  usingContentComparing : 1,
  usingTakingNameIntoAccountComparingContent : 1,
  usingLinkedCollecting : 0,
  usingSameNameCollecting : 0,

  usingTiming : 0,

  result : {},

}

filesFindSame.defaults.__proto__ = filesFind.defaults;

var having = filesFindSame.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

// --
// delete
// --

function filesDelete()
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 3 );

  var args = _.arraySlice( arguments );
  if( args[ 1 ] === undefined )
  args[ 1 ] = null;
  var o = self._filesFindOptions( args,1 );
  o.outputFormat = 'absolute';

  _.routineOptions( filesDelete,o );
  self.fieldSet( 'resolvingSoftLink', 0 );
  self._providerOptions( o );

  _.assert( o.resolvingSoftLink === 0 || o.resolvingSoftLink === false );

  // console.log( 'filesDelete',o ); debugger;

  o.filePath = _.pathNormalize( o.filePath );

  /* */

  var optionsForFind = _.mapScreen( self.filesFind.defaults,o );
  var files = self.filesFind( optionsForFind );
  self.fieldReset( 'resolvingSoftLink', 0 );

  /* */

  // debugger;
  for( var f = files.length-1 ; f >= 0 ; f-- ) try
  {
    var file = files[ f ];

    self.fileDelete({ filePath : file, throwing : o.throwing });
    if( o.verbosity )
    logger.log( '- deleted :',file )

  }
  catch( err )
  {
    if( o.throwing )
    throw _.err( err );
  }

  return new _.Consequence().give();
}

var defaults = filesDelete.defaults = Object.create( filesFind.defaults );

defaults.verbosity = 0;
defaults.throwing = 1;
defaults.recursive = 1;
defaults.includingDirectories = 1;
defaults.includingTerminals = 1;
defaults.resolvingSoftLink = null;

var having = filesDelete.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.bare = 0;

//

function filesDeleteForce( o )
{
  var self = this;

  var o = self._filesFindOptions( arguments,0 );
  _.mapComplement( o,filesDeleteForce.defaults );

  return self.filesDelete( o );
}


var defaults = filesDeleteForce.defaults = Object.create( filesDelete.defaults );

defaults.maskAll = null;

var having = filesDeleteForce.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.bare = 0;

//

function filesDeleteFiles( o )
{
  var self = this;

  var o = self._filesFindOptions( arguments,1 );
  _.mapComplement( o,filesDeleteFiles.defaults );

  return self.filesDelete( o );
}

filesDeleteFiles.defaults =
{
  recursive : 1,
  includingDirectories : 0,
  includingTerminals : 1,
}

var having = filesDeleteFiles.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.bare = 0;

//

function filesDeleteDirs( o )
{
  var self = this;

  var o = self._filesFindOptions( arguments,1 );
  _.routineOptions( filesDeleteDirs,o );

  return self.filesDelete( o );
}

filesDeleteDirs.defaults =
{
  recursive : 1,
  includingDirectories : 1,
  includingTerminals : 1,
}

filesDeleteDirs.defaults.__proto__ = filesDelete.defaults;

var having = filesDeleteDirs.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.bare = 0;

//

function filesDeleteEmptyDirs()
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 3 );
  var o = self._filesFindOptions( arguments,1 );

  /* */

  o.outputFormat = 'absolute';
  o.includingTerminals = 0;
  o.includingDirectories = 1;
  if( o.recursive === undefined )
  o.recursive = 1;

  _.mapComplement( o,filesDeleteEmptyDirs.defaults );

  /* */

  var o = _.mapBut( o,filesDeleteEmptyDirs.defaults );
  o.onDown = _.arrayAppend( _.arrayAs( o.onDown ), function( record )
  {

    try
    {

      var sub = self.directoryRead( record.absolute );
      if( !sub )
      debugger;

      if( !sub.length )
      {
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

  var files = self.filesFind( o );

  return new _.Consequence().give();
}

filesDeleteEmptyDirs.defaults =
{
  throwing : false,
  verbosity : false,
}

var having = filesDeleteEmptyDirs.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.bare = 0;

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

  _.assert( arguments.length === 1 || arguments.length === 3 );
  var o = self._filesFindOptions( arguments,1 );
  o.outputFormat = 'absolute';
  _.routineOptions( linksTerminate,o );
  self._providerOptions( o );

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

linksTerminate.defaults =
{
  terminatingHardLinks : 1,
  terminatingSoftLinks : 1,
  terminatingTextLinks : 0,
  recursive : 1,
}

linksTerminate.defaults.__proto__ = filesFind.defaults;

var having = filesDeleteEmptyDirs.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.bare = 0;

//

function filesResolve( options )
{
  var self = this;
  var result = [];

  _.assertMapHasOnly( options,filesResolve.defaults );
  _.assert( _.objectIs( options ) );
  _.assert( _.strIs( options.pathLookRoot ) );

  options.pathLookRoot = _.pathNormalize( options.pathLookRoot );

  if( !options.pathOutputRoot )
  options.pathOutputRoot = options.pathLookRoot;
  else
  options.pathOutputRoot = _.pathNormalize( options.pathOutputRoot );

  if( options.usingRecord === undefined )
  options.usingRecord = true;

  var globIn = _filesResolveMakeGlob( options );

  var globOptions = _.mapScreen( self.filesGlob.defaults,options );
  globOptions.globIn = globIn;
  globOptions.basePath = options.pathOutputRoot;
  globOptions.outputFormat = options.outputFormat;

  _.assert( self );
  var result = self.filesGlob( globOptions );

  return result;
}

filesResolve.defaults =
{
  pathGlob : null,
  pathVirtualRoot : null,
  pathVirtualDir : null,
  pathLookRoot : null,
  pathOutputRoot : null,
  outputFormat : 'record',
}

filesResolve.defaults.__proto__ = filesGlob.defaults;
/*filesResolve.defaults.__proto__ = _filesFindMasksAdjust.defaults;*/

var having = filesResolve.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

function _filesResolveMakeGlob( options )
{
  var pathGlob = options.pathGlob;

  _.assert( options.pathVirtualRoot === options.pathLookRoot,'not tested' );

/*
  if( options.pathVirtualRoot !== options.pathVirtualDir )
  debugger;
*/

  _.assert( _.objectIs( options ) );
  _.assert( _.strIs( options.pathGlob ) );
  _.assert( _.strIs( options.pathVirtualDir ) );
  _.assert( _.strIs( options.pathLookRoot ) );

  if( options.pathVirtualRoot === undefined )
  options.pathVirtualRoot = options.pathLookRoot;

  if( pathGlob[ 0 ] !== '/' )
  {
    pathGlob = _.pathReroot( options.pathVirtualDir,pathGlob );
    pathGlob = _.pathRelative( options.pathVirtualRoot,pathGlob );
  }

  if( _.strBegins( pathGlob,options.pathLookRoot ) )
  {
    debugger;
    _.errLog( 'probably something wrong with pathGlob :',pathGlob );
    throw _.err( 'probably something wrong with pathGlob :',pathGlob );
  }

  var result = pathGlob;
  result = _.pathReroot( options.pathLookRoot,pathGlob );

  return result;
}

//

function filesResolve2( o )
{
  var self = this;
  var result;

  _.assertMapHasOnly( o,filesResolve2.defaults );
  _.assert( _.objectIs( o ) );
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

filesResolve2.defaults =
{
  globPath2 : null,
  pathTranslator : null,
  outputFormat : 'record',
}

filesResolve2.defaults.__proto__ = filesGlob.defaults;

var having = filesResolve2.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

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

  _filesFindMasksSupplement : _filesFindMasksSupplement,
  _filesFindOptions : _filesFindOptions,
  _filesFindGlobAdjust : _filesFindGlobAdjust,
  _filesFindMasksAdjust : _filesFindMasksAdjust,

  // find

  _filesFind : _filesFind,
  filesFind : filesFind,
  filesFindRecursive : filesFindRecursive,
  filesGlob : filesGlob,

  // difference

  filesFindDifference : filesFindDifference,
  filesCopy : filesCopy,

  // move

  _filesMoveOptions : _filesMoveOptions,
  _filesMove : _filesMove,
  filesMove : filesMove,

  // same

  filesFindSame : filesFindSame,

  // delete

  filesDelete : filesDelete,
  filesDeleteForce : filesDeleteForce,
  filesDeleteFiles : filesDeleteFiles,
  filesDeleteDirs : filesDeleteDirs,
  filesDeleteEmptyDirs : filesDeleteEmptyDirs,

  // other find

  linksTerminate : linksTerminate,
  filesResolve : filesResolve,
  _filesResolveMakeGlob : _filesResolveMakeGlob,
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
