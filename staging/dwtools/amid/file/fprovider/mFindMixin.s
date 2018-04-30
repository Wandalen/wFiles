( function _mFind_s_() {

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

    debugger;
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

    // o = o || Object.create( null );
    //
    // if( args[ 0 ] !== undefined && o.filePath === undefined )
    // o.filePath = args[ 0 ];

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

  if( !o.globIn )
  return;

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( o ) );
  _.assert( _.strIs( o.globIn ) || _.arrayIs( o.globIn ) );

  o.globIn = _.pathsNormalize( o.globIn );

  if( o.filePath )
  o.filePath = _.pathNormalize( o.filePath );

  if( o.relative )
  o.relative = _.pathNormalize( o.relative );

  function pathFromGlob( globIn )
  {
    var result;
    _.assert( _.strIs( globIn ) );
    // var i = globIn.search( /[^\\\/]*?(\*\*|\?|\*)[^\\\/]*/ );
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

  if( !o.relative )
  {
    if( _.arrayIs( o.filePath ) )
    o.relative = _.pathCommon( o.filePath );
    else
    o.relative = o.filePath;
  }

  _.assert( _.strIs( o.filePath ) || _.strsIs( o.filePath ) );

  function globAdjust( globIn )
  {

    var relative = _.strAppendOnce( o.relative,'/' );
    if( !_.strBegins( globIn,relative ) )
    relative = o.relative;

    if( _.strBegins( globIn,relative ) )
    {
      globIn = globIn.substr( relative.length, globIn.length );
    }
    else
    {
      debugger;
      // logger.log( 'strBegins :', _.strBegins( globIn,relative ) );
      // throw _.err( 'not tested' );
    }

    return globIn;
  }

  if( _.arrayIs( o.globIn ) )
  o.globOut = _.entityFilter( o.globIn,( globIn ) => globAdjust( globIn ) );
  else
  o.globOut = globAdjust( o.globIn );

}

//

function _filesFindMasksAdjust( o )
{

  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o ) );
  _.assert( o.glob === undefined );

  o.maskAll = _.regexpMakeObject( o.maskAll || Object.create( null ),'includeAny' );
  o.maskTerminal = _.regexpMakeObject( o.maskTerminal || Object.create( null ),'includeAny' );
  o.maskDir = _.regexpMakeObject( o.maskDir || Object.create( null ),'includeAny' );

/*
  if( o.hasExtension )
  {
    // /(^|\/)\.(?!$|\/|\.)/,
    _.assert( _.strIs( o.hasExtension ) );
    o.hasExtension = new RegExp( '^' + _.regexpEscape( o.hasExtension ) ); xxx
    _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.hasExtension } );
    delete o.hasExtension;
  }
*/

  if( o.begins )
  {
    _.assert( _.strIs( o.begins ) );
    o.begins = new RegExp( '^' + _.regexpEscape( o.begins ) );
    o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.begins } );
    delete o.begins;
  }

  if( o.ends )
  {
    _.assert( _.strIs( o.ends ) || _.arrayIs( o.ends ) );

    if( _.strIs( o.ends ) )
    o.ends = new RegExp( _.regexpEscape( o.ends ) + '$' );
    else
    o.ends = new RegExp( '(' + _.regexpEscape( o.ends ).join( '|' ) + ')$' );

    o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.ends } );
    delete o.ends;
  }

  if( o.globOut )
  {
    // var globRegexp = _.regexpForGlob( o.globOut );
    var globRegexp = _.regexpForGlob2( o.globOut );
    o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : globRegexp } );
    delete o.globOut;
  }

  // qqq
  // if( o._globPath )
  // {
  //   var globRegexp = _regexpForGlob( o._globPath );
  //   o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : globRegexp } );
  //   delete o._globPath;
  // }

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

  begins : null,
  ends : null,
  globIn : null,
  // _globPath : null,

  notOlder : null,
  notNewer : null,
  notOlderAge : null,
  notNewerAge : null,

}

// --
//
// --

function filesFind()
{
  var self = this;

  var o = self._filesFindOptions( arguments,1 );
  _.routineOptions( filesFind,o );
  self._providerOptions( o );
  self._filesFindGlobAdjust( o );
  self._filesFindMasksAdjust( o );

  _.assert( o.filePath,'filesFind :','expects "filePath"' );

  var time;
  if( o.verbosity )
  time = _.timeNow();

  if( o.verbosity >= 2 )
  logger.log( 'filesFind',_.toStr( o,{ levels : 2 } ) );

  o.filePath = _.arrayAs( o.filePath );

  var result = o.result = o.result || [];
  var relative = o.relative;
  var orderingExclusion = _.RegexpObject.order( o.orderingExclusion || [] );

  /* add result */

  function _resultAdd( o )
  {
    var resultAdd;

    if( o.outputFormat === 'absolute' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1 );
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
      if( _.arrayLeftIndexOf( o.result,record.absolute,function( e ){ return e.absolute; } ) >= 0 )
      {
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

  var resultAdd = _resultAdd( o );

  /* */

  function forFilePath( filePath,o,isTopMost )
  {
    var dir = filePath;

    if( self.fileIsTerminal( filePath ) || self.fileIsSoftLink( filePath ) ) /* what for? */
    dir = _.pathDir( filePath );

    var recordOptions = _.FileRecordOptions.tollerantMake( o,{ dir : dir } );
    var record = self.fileRecord( filePath,recordOptions );

    forFile( record,o,isTopMost );

  }

  /* */

  function forFile( record,o,isTopMost )
  {
    if( self.directoryIs( record.absolute ) )
    forDirectory( record,o,isTopMost )
    else
    forTerminal( record,o )
  }

  /* */

  function forDirectory( dirRecord,o,isTopMost )
  {

    if( !dirRecord._isDir() )
    return;
    if( !dirRecord.inclusion )
    return;

    var files = self.directoryRead( dirRecord.absolute ) || [];

    var recordOptions = _.FileRecordOptions.tollerantMake( o,{ dir : dirRecord.absolute } );
    files = self.fileRecords( files,recordOptions );

    if( o.includingDirectories )
    {
      var onUpResult = _.routinesCallUntilFalse( o,o.onUp,[ dirRecord,o ] );
      if( onUpResult[ onUpResult.length-1 ] === false )
      return;
      resultAdd( dirRecord );
    }

    /* terminals */

    if( o.recursive || isTopMost )
    if( o.includingTerminals )
    for( var f = 0 ; f < files.length ; f++ )
    {
      var fileRecord = files[ f ];
      forTerminal( fileRecord,o );
    }

    /* dirs */

    if( o.recursive || isTopMost )
    for( var f = 0 ; f < files.length ; f++ )
    {
      var subdirRecord = files[ f ];
      forDirectory( subdirRecord,o );
    }

    if( o.includingDirectories )
    _.routinesCall( o,o.onDown,[ dirRecord,o ] );

  }

  /* */

  function forTerminal( record,o )
  {

    if( !o.includingTerminals )
    return;
    if( record._isDir() )
    return;
    if( !record.inclusion )
    return;

    var onUpResult = _.routinesCallUntilFalse( o,o.onUp,[ record,o ] );
    if( onUpResult[ onUpResult.length-1 ] === false )
    return;

    resultAdd( record );
    _.routinesCall( o,o.onDown,[ record,o ] );

  }

  /* find several pathes */

  function forPathes( paths,o )
  {

    if( _.strIs( paths ) )
    paths = [ paths ];
    paths = _.arrayUnique( paths );

    _.assert( _.arrayIs( paths ),'expects string or array' );

    for( var p = 0 ; p < paths.length ; p++ )
    {
      var filePath = paths[ p ];

      // filePath = _.pathRefine( filePath );
      filePath = _.pathNormalize( filePath );

      _.assert( _.strIs( filePath ),'expects string, got ' + _.strTypeOf( filePath ) );

      /* */

      if( relative === undefined || relative === null )
      {
        o = Object.assign( Object.create( null ),o );
        o.relative = filePath;
      }

      if( o.ignoreNonexistent )
      if( !self.fileStat( filePath ) )
      continue;

      forFilePath( filePath,Object.freeze( o ),true );

    }

  }

  /* find files in order */

  if( !orderingExclusion.length )
  {
    forPathes( o.filePath,_.mapExtend( null,o ) );
  }
  else
  {
    var maskTerminal = o.maskTerminal;
    for( var e = 0 ; e < orderingExclusion.length ; e++ )
    {
      o.maskTerminal = _.RegexpObject.shrink( Object.create( null ),maskTerminal,orderingExclusion[ e ] );
      forPathes( o.filePath,_.mapExtend( null,o ) );
    }
  }

  /* sort */

  if( o.sortWithArray )
  {

    _.assert( _.arrayIs( o.sortWithArray ) );

    if( o.outputFormat === 'record' )
    result.sort( function( a,b )
    {
      return _.regexpArrayIndex( o.sortWithArray,a.relative ) - _.regexpArrayIndex( o.sortWithArray,b.relative );
    })
    else
    result.sort( function( a,b )
    {
      return _.regexpArrayIndex( o.sortWithArray,a ) - _.regexpArrayIndex( o.sortWithArray,b );
    });

  }

  /* timing */

  if( o.verbosity )
  logger.log( _.timeSpent( 'At ' + o.filePath + ' found ' + result.length + ' in',time ) );

  return result;
}

filesFind.defaults =
{

  filePath : null,
  relative : null,

  recursive : 0,
  ignoreNonexistent : 0,
  includingTerminals : 1,
  includingDirectories : 0,
  includingTopDirectory : 1,
  outputFormat : 'record',
  strict : 1,

  result : [],
  orderingExclusion : [],
  sortWithArray : null,

  verbosity : 0,

  // onRecord : [],
  onUp : [],
  onDown : [],

}

filesFind.defaults.__proto__ = _filesFindMasksAdjust.defaults;

var having = filesFind.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

function filesFindRecursive( o )
{
  var self = this;

  var o = self._filesFindOptions( arguments,1 );

  _filesFindMasksAdjust( o );

  _.routineOptions( filesFindRecursive, o );

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

  if( !o.globIn )
  o.globIn = '*';

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( o ) );
  _.assert( _.strIs( o.globIn ) || _.arrayIs( o.globIn ) );

  if( o.outputFormat === undefined )
  o.outputFormat = 'absolute';

  if( o.recursive === undefined )
  o.recursive = 1;

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

  var providerIsHub = _.FileProvider.Hub && self instanceof _.FileProvider.Hub;

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

  function _resultAdd( o )
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

  var resultAdd = _resultAdd( o );

  /* safety */

  o.dst = _.pathNormalize( o.dst );
  o.src = _.pathNormalize( o.src );

  if( o.src !== o.dst && _.strBegins( o.src,o.dst ) )
  {
    debugger;
    throw _.err( 'overwrite of itself','\nsrc :',o.src,'\ndst :',o.dst )
  }

  if( o.src !== o.dst && _.strBegins( o.dst,o.src ) )
  {
    var exclude = '^' + o.dst.substr( o.src.length+1 ) + '($|\/)';
    _.RegexpObject.shrink( o.maskAll,{ excludeAny : new RegExp( exclude ) } );
  }

  // throw _.err( 'not tested' );

  /* dst */

  var dstOptions =
  {
    dir : dst,
    relative : dst,
    fileProvider : self,
    strict : 0,
  }

  if( dstOptions.fileProvider.providerForPath )
  {
    dstOptions.fileProvider = dstOptions.fileProvider.providerForPath( dst );
    dstOptions.dir = dstOptions.fileProvider.localFromUrl( dstOptions.dir );
    dstOptions.relative = dstOptions.fileProvider.localFromUrl( dstOptions.relative );
  }

  dstOptions = _.FileRecordOptions.tollerantMake( o,dstOptions );
  // var dstOptions = _.mapScreen( FileRecord.prototype._fileRecord.defaults,o );
  // dstOptions.dir = dst;
  // dstOptions.relative = dst;
  // dstOptions.fileProvider = self;

  /* src */

  // var srcOptions = _.mapScreen( FileRecord.prototype._fileRecord.defaults,o );

  var srcOptions =
  {
    dir : src,
    relative : src,
    fileProvider : self,
    strict : 0,
  }
  if( srcOptions.fileProvider.providerForPath )
  {
    srcOptions.fileProvider = srcOptions.fileProvider.providerForPath( src );
    srcOptions.dir = srcOptions.fileProvider.localFromUrl( srcOptions.dir );
    srcOptions.relative = srcOptions.fileProvider.localFromUrl( srcOptions.relative );
  }
  srcOptions = _.FileRecordOptions.tollerantMake( o,srcOptions );
  // srcOptions.dir = src;
  // srcOptions.relative = src;
  // srcOptions.fileProvider = self;

  /* diagnostic */

  // logger.log( 'filesFindDifference' );
  // logger.log( _.toStr( o,{ levels : 4 } ) );
  // debugger;

  /* src file */

  function srcFile( dstOptions,srcOptions,file )
  {

    var srcRecord = new FileRecord( file,_.FileRecordOptions( srcOptions ) );
    srcRecord.side = 'src';

    if( srcRecord._isDir() )
    return;
    if( !srcRecord.inclusion )
    return;

    // debugger;
    var dstRecord = new FileRecord( file,_.FileRecordOptions( dstOptions ) );
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
        record.link = self.filesAreLinked( dstRecord.absolute, srcRecord.absolute );
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
    _.routinesCall( o,o.onDown,[ record ] );

  }

  /* src directory */

  function srcDir( dstOptions,srcOptions,file,recursive )
  {

    // debugger
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

      _.assert( dstOptions instanceof _.FileRecordOptions );
      _.assert( srcOptions instanceof _.FileRecordOptions );

      var dstOptionsSub = _.FileRecordOptions.tollerantMake( dstOptions,{ dir : dstRecord.absolute } );
      var srcOptionsSub = _.FileRecordOptions.tollerantMake( srcOptions,{ dir : srcRecord.absolute } );

      filesFindDifferenceAct( dstOptionsSub,srcOptionsSub );
    }

    if( o.includingDirectories )
    _.routinesCall( o,o.onDown,[ record ] );

  }

  /* dst file */

  function dstFile( dstOptions,srcOptions,file )
  {
    // debugger
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
    _.routinesCall( o,o.onDown,[ record ] );

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
        // outputFormat : o.outputFormat,
        outputFormat : 'record',
        recursive : 1,
        // safe : 0,
      })

      // debugger;
      _.assert( srcOptions instanceof _.FileRecordOptions );
      // srcOptions = _.mapExtend( null,srcOptions );
      // srcOptions = srcOptions.cloneData();
      // delete srcOptions.dir;
      var srcOptions = _.FileRecordOptions.tollerantMake( srcOptions,{ dir : null } );

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
        _.routinesCall( o,o.onDown,[ found[ fo ] ] );
      }

    }

    if( record )
    _.routinesCall( o,o.onDown,[ record ] );

  }

  /* act */

  function filesFindDifferenceAct( dstOptions,srcOptions )
  {

    /* dst */

    var dstRecord = new FileRecord( dstOptions.dir,dstOptions );
    if( o.investigateDestination )
    if( dstRecord.stat && dstRecord.stat.isDirectory() )
    {

      var files = self.directoryRead( providerIsHub ? dstRecord.full : dstRecord.real );
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

      var files = self.directoryRead( providerIsHub ? srcRecord.full : srcRecord.real );
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
  if( o.removeSource && ( !o.allowWrite || !o.allowRewrite ) )
  throw _.err( 'not safe removeSource:1 with allowWrite:0 or allowRewrite:0' );

  /* make dir */

  var dirname = _.pathDir( o.dst );

  if( self.safe )
  if( !_.pathIsSafe( dirname ) )
  throw _.err( dirname,'Unsafe to use :',dirname );

  var recordDir = self.fileRecord( dirname );
  // var recordDir = new _.FileRecord( dirname,_.FileRecordOptions({ fileProvider : self }) );
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

    // logger.log( 'filesCopy.up :',record.dst.absolute );
    // debugger;

    /* same */

    if( o.tryingPreserve )
    if( record.same && record.link == o.usingLinking )
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
        if( o.preserveTime )
        {
          if( providerIsHub )
          self.fileTimeSet( record.dst.full, record.src.stat.atime, record.src.stat.mtime );
          else
          self.fileTimeSet( record.dst.absolute, record.src.stat.atime, record.src.stat.mtime );
        }
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
        if( providerIsHub )
        self.directoryMake({ filePath : record.dst.full, force : 1 });
        else
        self.directoryMake({ filePath : record.dst.real, force : 1 });

        if( o.preserveTime )
        {
          if( providerIsHub )
          self.fileTimeSet( record.dst.full, record.src.stat.atime, record.src.stat.mtime );
          else
          self.fileTimeSet( record.dst.absolute, record.src.stat.atime, record.src.stat.mtime );
        }
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
          // debugger
          if( providerIsHub )
          self.directoryMake( record.dst.fileProvider.urlFromLocal( record.dst.dir ) );
          else
          self.directoryMake( record.dst.dir );

          if( o.preserveTime )
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
      //debugger;
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

      if( o.usingLinking )
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
          logger.log( '+ ' + record.action + ' :',record.dst.real );

          // debugger
          if( providerIsHub )
          self.fileCopy( record.dst.full,record.src.full );
          else
          self.fileCopy( record.dst.real,record.src.real );

          if( o.preserveTime )
          {
            if( providerIsHub )
            self.fileTimeSet( record.dst.full, record.src.stat.atime, record.src.stat.mtime );
            else
            self.fileTimeSet( record.dst.real, record.src.stat.atime, record.src.stat.mtime );
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
    return false;

    _.routinesCallUntilFalse( o,onUp,[ record ] );

  }

  /* on down */

  function handleDown( record )
  {

    if( record.action === 'linked' && record.del )
    throw _.err( 'unexpected' );

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

    var removeSource = false;
    removeSource = removeSource || o.removeSource;
    removeSource = removeSource || ( o.removeSourceFiles && !record.src._isDir() );

    if( removeSource && record.src.stat && record.src.inclusion )
    {
      if( o.verbosity )
      logger.log( '- removed-source :',record.src.real );
      self.fileDelete( record.src.real );
      delete record.src.stat;
    }

    /* callback */

    if( !includingDirectories && record.src._isDir() )
    return;

    _.routinesCall( o,onDown,[ record ] );

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
  usingLinking : 0,
  resolvingSoftLink : 0,
  resolvingTextLink : 0,

  removeSource : 0,
  removeSourceFiles : 0,

  recursive : 1,
  /*usingDelete : 0,*/
  allowDelete : 0,
  allowWrite : 0,
  allowRewrite : 1,
  allowRewriteFileByDir : 0,

  tryingPreserve : 1,
  silentPreserve : 1,
  preserveTime : 1,

  // safe : 1,

  /*onCopy : null,*/

}

filesCopy.defaults.__proto__ = filesFindDifference.defaults;

var having = filesCopy.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.bare = 0;

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

    if( self.filesAreLinked( file1.absolute,file2.absolute ) )
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
  self._providerOptions( o );

  // console.log( 'filesDelete',o ); debugger;

  o.filePath = _.pathNormalize( o.filePath );

  /* */

  self.fieldSet( 'resolvingSoftLink', 0 );
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
  globOptions.relative = options.pathOutputRoot;
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
  globOptions.relative = o.pathTranslator.realRootPath;
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

  filesFind : filesFind,
  filesFindRecursive : filesFindRecursive,
  filesGlob : filesGlob,

  // difference

  filesFindDifference : filesFindDifference,
  filesCopy : filesCopy,

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
