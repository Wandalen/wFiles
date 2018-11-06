( function _FindMixin_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = _global_.wTools;
  if( !_.FileProvider )
  require( '../UseMid.s' );

}

let _global = _global_;
let _ = _global_.wTools;
let FileRecord = _.FileRecord;

//

let Parent = null;
let Self = function wFileProviderFind( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Find';

// // let debugPath = '/file.a';
//
// //
//
// function onMixin( mixinDescriptor, dstClass )
// {
//
//   let dstPrototype = dstClass.prototype;
//
//   _.assert( arguments.length === 2, 'Expects exactly two arguments' );
//   _.assert( _.routineIs( dstClass ) );
//
//   _.mixinApply( this, dstPrototype );
//
// }

// --
// etc
// --

function recordsOrder( records,orderingExclusion )
{

  _.assert( _.arrayIs( records ) );
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  if( !orderingExclusion.length )
  return records;

  orderingExclusion = _.RegexpObject.order( orderingExclusion || [] );

  let removed = [];
  let result = [];
  let e = 0;
  for( ; e < orderingExclusion.length ; e++ )
  result[ e ] = [];

  for( let r = 0 ; r < records.length ; r++ )
  {
    let record = records[ r ];
    for( let e = 0 ; e < orderingExclusion.length ; e++ )
    {
      let mask = orderingExclusion[ e ];
      let match = mask.test( record.relative );
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

function _filesFilterMasksSupplement( dst,src )
{
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  _.mapSupplement( dst,src );

  dst.maskDirectory = _.RegexpObject.And( null, dst.maskDirectory || Object.create( null ), src.maskDirectory || Object.create( null ) );
  dst.maskTerminal = _.RegexpObject.And( null, dst.maskTerminal || Object.create( null ), src.maskTerminal || Object.create( null ) );
  dst.maskAll = _.RegexpObject.And( null, dst.maskAll || Object.create( null ), src.maskAll || Object.create( null ) );

  return dst;
}

// --
// files find
// --

function _filesFindOptions( args, safe )
{
  let o;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  // _.assert( 1 <= args.length && args.length <= 3 );
  _.assert( 1 === args.length );

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

    // if( args[ 1 ] !== undefined && o.maskTerminal === undefined )
    // o.maskTerminal = args[ 1 ];

  }

  if( o.maskPreset )
  {
    o.filter = o.filter || Object.create( null );
    if( Object.keys( o.filter ).length === 0 )
    o.filter.maskAll = _.files.regexpMakeSafe();
  }

  return o;
}

//

function _filesFilterForm( o )
{
  let self = this;

  _.assert( !o.filter || !o.filter.formed <= 3, 'Filter is already formed, but should not be!' )
  _.assert( arguments.length === 1, 'Expects single argument' );

  o.filter = o.filter || Object.create( null );
  if( o.filter )
  o.filter = self.fileRecordFilter( o.filter );

  // o.filter.hubFileProvider = o.filter.hubFileProvider || self.hub || self;
  // if( self !== self.hub && self.hub )
  // o.filter.effectiveFileProvider = o.filter.effectiveFileProvider || self;

  o.filter.inFilePath = o.filePath;

  o.filter.form();

  o.filePath = o.filter.branchPath;

  _.assert( !self.hub || o.filter.hubFileProvider === self.hub );
  _.assert( !!o.filter.effectiveFileProvider );

  return o;
}

_.assert( _.objectIs( _.FileRecordFilter.prototype.Composes ) );
_filesFilterForm.defaults = Object.create( _.FileRecordFilter.prototype.Composes );

//

function __filesFind_pre( routine, args, safe )
{
  let self = this;
  let path = self.path;
  let o = self._filesFindOptions( args, safe );

  _.routineOptions( routine,o );

  if( o.filePath )
  o.filePath = path.s.normalize( o.filePath );

  if( Config.debug )
  {

    _.assert( arguments.length === 3 );
    _.assert( 1 <= args.length && args.length <= 3 );
    _.assert( o.basePath === undefined );
    _.assert( o.prefixPath === undefined );
    _.assert( o.postfixPath === undefined );

  }

  self._filesFilterForm( o );

  return o;
}

//

function _filesFindSingle_pre( routine, args )
{
  let self = this;
  let path = self.path;
  let o = self.__filesFind_pre( routine, args, 1 );

  return o;
}

//

function _filesFindSingle_body( o )
{
  let self = this;
  let path = self.path;

  o.filter.effectiveFileProvider._providerOptions( o ); /* !!! */

  _.assert( _.objectIs( o.filter.effectiveFileProvider ) );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( _filesFindSingle_body, o );
  _.assert( _.routineIs( o.onUp ) || _.arrayIs( o.onUp ) );
  _.assert( _.routineIs( o.onDown ) || _.arrayIs( o.onDown ) );
  _.assert( path.isNormalized( o.filePath ) );
  _.assert( path.isAbsolute( o.filePath ), 'Expects absolute path {-o.filePath-}' );
  _.assert( !!o.filter.formed, 'Expects formed filter' );
  _.assert( _.mapIs( o.filter.basePath ), 'Expects absolute path {-o.filter.basePath-}' );

  _.assert( o.filter.effectiveFileProvider instanceof _.FileProvider.Abstract );
  _.assert( o.filter.hubFileProvider === o.filter.effectiveFileProvider || o.filter.hubFileProvider instanceof _.FileProvider.Hub );

  /* handler */

  if( _.arrayIs( o.onUp ) )
  if( o.onUp.length === 0 )
  o.onUp = function( record ){ return record };
  else
  o.onUp = _.routinesComposeAllReturningLast( o.onUp );

  if( _.arrayIs( o.onDown ) )
  o.onDown = _.routinesCompose( o.onDown );

  _.assert( _.routineIs( o.onUp ) );
  _.assert( _.routineIs( o.onDown ) );

  /* */

  let recordAdd = recordAdd_functor( o );
  let result = o.result = o.result || [];

  Object.freeze( o );

  // o.filter.effectiveFileProvider.claimBegin({ filePath : o.filePath });
  try
  {

    if( o.ignoringNonexistent )
    if( !o.filter.effectiveFileProvider.fileStat( o.filePath ) )
    return result;

    let o2 =
    {
      // fileProvider : self, /* xxx */
      // effectiveFileProvider : o.filter.effectiveFileProvider,
      branchPath : o.filePath,
      basePath : o.filter.basePath[ o.filePath ],
    };

    _.assert( _.strDefined( o2.basePath ), 'No base path for', o.filePath );

    let recordFactory = _.FileRecordFactory.TollerantMake( o, o2 ).form();

    _.assert( recordFactory.basePath === o.filter.basePath[ o.filePath ] )

    let record = recordFactory.fileRecord( o.filePath );

    _.assert( recordFactory.dirPath === null );
    _.assert( record.isBranch === true );
    _.assert( recordFactory.effectiveFileProvider === o.filter.effectiveFileProvider );
    _.assert( recordFactory.fileProvider === o.filter.hubFileProvider );

    forFile( record, o );

    // forPath( o.filePath, o, true );

  }
  finally
  {
    // o.filter.effectiveFileProvider.claimEnd({ filePath : o.filePath });
  }

  return result;

  /* */

  function handleUp( record, op )
  {
    _.assert( arguments.length === 2 );

    record = op.onUp.call( self, record, op );

    return record;
  }

  /* */

  function handleDown( record, op )
  {
    _.assert( arguments.length === 2 );

    record = op.onDown.call( self, record, op );

    return record;
  }

  /* add result */

  function recordAdd_functor( o )
  {
    let recordAdd;

    if( o.outputFormat === 'absolute' )
    recordAdd = function( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      o.result.push( record.absolute );
    }
    else if( o.outputFormat === 'relative' )
    recordAdd = function( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      o.result.push( record.relative );
    }
    else if( o.outputFormat === 'record' )
    recordAdd = function( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      o.result.push( record );
    }
    else if( o.outputFormat === 'nothing' )
    recordAdd = function( record )
    {
    }
    else _.assert( 0,'unexpected output format :',o.outputFormat );

    return recordAdd;
  }

  /* */

  // function forPath( filePath, o )
  // {
  //
  //   let o2 =
  //   {
  //     fileProvider : self,
  //     effectiveFileProvider : o.filter.effectiveFileProvider,
  //     branchPath : filePath,
  //     basePath : o.filter.basePath[ filePath ],
  //   };
  //
  //   _.assert( _.strDefined( o2.basePath ), 'No base path for', filePath );
  //
  //   let recordFactory = _.FileRecordFactory.TollerantMake( o, o2 ).form();
  //   let record = recordFactory.fileRecord( filePath );
  //
  //   _.assert( recordFactory.dirPath === null );
  //   _.assert( record.isBranch === true );
  //
  //   forFile( record, o );
  // }

  /* */

  function forFile( record, o )
  {
    if( record.isDir )
    forDirectory( record, o )
    else
    forTerminal( record, o )
  }

  /* */

  function forDirectory( r, o )
  {

    if( !r.isDir )
    return;
    if( !r.isTransient && !r.isActual )
    return;

    let or = r;
    let isTransient = r.isTransient;
    let includingTransient = ( o.includingTransient && r.isTransient && o.includingDirectories );
    let includingActual = ( o.includingActual && r.isActual && o.includingDirectories );
    let including = !!r.stat;
    including = including && ( includingTransient || includingActual );
    including = including && ( o.includingBase || !r.isBranch );

    /* up */

    if( including )
    {
      r = handleUp( r, o );

      _.assert( r === false || r === _.dont || _.objectIs( r ) );
      // _.assert( r === false || _.objectIs( r ) );

      if( r === false || r === _.dont )
      return false;

      recordAdd( r );
    }

    /* read */

    if( isTransient )
    if( o.recursive || or.isBranch )
    {

      let files = o.filter.effectiveFileProvider.directoryRead({ filePath : or.absolute, outputFormat : 'absolute' });

      if( o.ignoringNonexistent )
      if( files === null )
      files = [];

      files = or.context.fileRecords( files );

      /* terminals */

      if( o.includingTerminals )
      for( let f = 0 ; f < files.length ; f++ )
      {
        let file = files[ f ];
        forTerminal( file, o );
      }

      /* dirs */

      for( let f = 0 ; f < files.length ; f++ )
      {
        let file = files[ f ];
        forDirectory( file, o );
      }

    }

    /* down */

    if( including )
    handleDown( r, o );

  }

  /* */

  function forTerminal( r, o )
  {

    if( r.isDir )
    return;
    if( !r.isTransient && !r.isActual )
    return;

    let or = r;
    let includingTransient = ( o.includingTransient && r.isTransient && o.includingTerminals );
    let includingActual = ( o.includingActual && r.isActual && o.includingTerminals );
    let including = !!r.stat;
    including = including && ( includingTransient || includingActual );
    including = including && ( o.includingBase || !or.isBranch );

    if( !including )
    return;

    r = handleUp( r, o );

    _.assert( r === false || r === _.dont || _.objectIs( r ) );

    if( r === false || r === _.dont )
    return false;

    recordAdd( r );

    handleDown( r, o );
  }

}

_filesFindSingle_body.defaults =
{

  filePath : null,

  ignoringNonexistent : 0,
  maskPreset : 1,

  includingTerminals : 1,
  includingDirectories : 0,
  includingActual : 1,
  includingTransient : 0,
  includingBase : 1,

  recursive : 0,
  resolvingSoftLink : 1,
  resolvingTextLink : 0,

  outputFormat : 'record',
  result : [],

  onUp : [],
  onDown : [],

  filter : null,

}

_filesFindSingle_body.paths =
{
  filePath : null,
}

var having = _filesFindSingle_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

let filesFindSingle = _.routineFromPreAndBody( _filesFindSingle_pre, _filesFindSingle_body );

//

function _filesFind_pre( routine, args )
{
  let self = this;
  let path = self.path;
  return self.__filesFind_pre( routine, args, 1 )
}

//

function _filesFind_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!o.filePath, 'filesFind expects {-o.filePath-} or {-o.glob-}' );

  let time;
  if( o.verbosity >= 2 )
  time = _.timeNow();

  if( o.verbosity >= 3 )
  logger.log( 'filesFind',_.toStr( o,{ levels : 2 } ) );

  o.filePath = _.arrayAs( o.filePath );

  o.result = o.result || [];

  /* find */

  _.assert( !o.orderingExclusion.length || o.orderingExclusion.length === 0 || o.outputFormat === 'record' );

  forPaths( o.filePath,_.mapExtend( null,o ) );

  /* order */

  o.result = self.recordsOrder( o.result, o.orderingExclusion );

  // let orderingExclusion = _.RegexpObject.order( o.orderingExclusion || [] );
  // if( !orderingExclusion.length )
  // {
  //   forPaths( o.filePath,_.mapExtend( null,o ) );
  // }
  // else
  // {
  //   let maskTerminal = o.maskTerminal;
  //   for( let e = 0 ; e < orderingExclusion.length ; e++ )
  //   {
  //     o.maskTerminal = _.RegexpObject.And( Object.create( null ),maskTerminal,orderingExclusion[ e ] );
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

  /* mandatory */

  if( o.mandatory )
  if( !o.result.length )
  {
    debugger;
    throw _.err( 'No file found at ' + ( o.filter.inFilePath || o.filePath ) );
  }

  /* timing */

  if( o.verbosity >= 2 )
  logger.log( _.timeSpent( 'filesFind ' + o.result.length + ' files at ' + o.filePath + ' in',time ) );

  return o.result;

  /* find for several paths */

  function forPaths( paths,o )
  {

    if( _.strIs( paths ) )
    paths = [ paths ];
    paths = _.arrayUnique( paths );

    _.assert( _.arrayIs( paths ), 'Expects path or array of paths' );

    for( let p = 0 ; p < paths.length ; p++ )
    {
      let filePath = paths[ p ];
      let options = Object.assign( Object.create( null ), o );

      // delete options.prefixPath;
      // delete options.postfixPath;
      delete options.mandatory;
      delete options.orderingExclusion;
      delete options.sortingWithArray;
      delete options.verbosity;
      options.filePath = filePath;

      self.filesFindSingle.body.call( self, options );
    }

  }

}

_.routineExtend( _filesFind_body, filesFindSingle.body );

var defaults = _filesFind_body.defaults;

// defaults.prefixPath = null;
// defaults.postfixPath = null;

defaults.orderingExclusion = [];
defaults.sortingWithArray = null;
defaults.verbosity = null;
defaults.mandatory = 0;

// _.mapExtend( defaults, _filesFilterForm.defaults );
// _.assert( defaults.maskAll !== undefined );
_.assert( defaults.maskAll === undefined );
_.assert( defaults.glob === undefined );

let filesFind = _.routineFromPreAndBody( _filesFind_pre, _filesFind_body );

filesFind.having.aspect = 'entry';

//

function filesFindRecursive( o )
{
  let self = this;

  o = self.filesFindRecursive.pre.call( self, self.filesFindRecursive, arguments );

  if( o.filePath === null )
  {
    debugger;
    _.assert( 0, 'not tested' );
    o.filePath = '/';
  }

  return self.filesFind.body.call( self, o );
}

_.routineExtend( filesFindRecursive, filesFind );

var defaults = filesFindRecursive.defaults;

defaults.filePath = null;
defaults.recursive = 1;
defaults.includingTransient = 0;
defaults.includingDirectories = 1;
defaults.includingTerminals = 1;

//

function filesGlob( o )
{
  let self = this;

  if( _.strIs( o ) )
  o = { filePath : o }

  if( o.recursive === undefined )
  o.recursive = 1;

  o.filter = o.filter || Object.create( null );

  // if( !o.filter.filePath )
  if( o.filePath )
  {
    // o.filter.filePath = o.filePath;
    // o.filePath = null;
  }
  else
  {
    o.filePath = o.recursive ? '**' : '*';
  }

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.objectIs( o ) );
  // _.assert( _.strIs( o.filter.filePath ) || _.arrayIs( o.filter.filePath ) || _.mapIs( o.filter.filePath ) );

  let result = self.filesFind( o );

  return result;
}

_.routineExtend( filesGlob, filesFind );

var defaults = filesGlob.defaults;

defaults.outputFormat = 'absolute';
defaults.recursive = 1;
defaults.includingTerminals = 1;
defaults.includingDirectories = 1;
defaults.includingTransient = 0;

//

function filesFinder_functor( routine )
{

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( routine ) );
  _.routineExtend( finder, routine );
  return finder;

  function finder()
  {
    let self = this;
    let op0 = self._filesFindOptions( arguments, 1 );
    _.assertMapHasOnly( op0, finder.defaults );
    return er;

    function er()
    {
      let o = _.mapExtend( null, op0 );
      o.filter = self.fileRecordFilter( o.filter );

      for( let a = 0 ; a < arguments.length ; a++ )
      {
        let op2 = arguments[ a ];

        if( !_.objectIs( op2 ) )
        op2 = { filePath : op2 }

        op2.filter = op2.filter || Object.create( null );

        o.filter.and( op2.filter );
        o.filter.pathsJoin( op2.filter );
        o.filePath = self.path.s.joinIfDefined( o.filePath, op2.filePath );

        op2.filter = o.filter;
        op2.filePath = o.filePath;

        _.mapExtend( o, op2 );

      }

      return routine.call( self, o );
    }

  }

}

let filesFinder = filesFinder_functor( filesFind );
let filesGlober = filesFinder_functor( filesGlob );

//
// _.routineExtend( filesCopyOld, filesFindDifference );
//
// var defaults = filesCopyOld.defaults;
//
// defaults.verbosity = 1;
// defaults.linking = 0;
// defaults.resolvingSoftLink = 0;
// defaults.resolvingTextLink = 0;
//
// defaults.removingSource = 0;
// defaults.removingSourceTerminals = 0;
//
// defaults.recursive = 1;
// defaults.allowDelete = 0;
// defaults.allowWrite = 0;
// defaults.allowRewrite = 1;
// defaults.allowRewriteFileByDir = 0;
//
// defaults.tryingPreserve = 1;
// defaults.silentPreserve = 1;
// defaults.preservingTime = 1;

//

function filesCopyWithAdapter( o )
{
  let self = this;

  if( arguments.length === 2 )
  o = { dst : arguments[ 0 ] , src : arguments[ 1 ] }

  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( !o.allowDelete && o.investigateDestination === undefined )
  o.investigateDestination = 0;

  if( o.allowRewrite === undefined )
  o.allowRewrite = filesCopyWithAdapter.defaults.allowRewrite;

  if( o.allowRewrite && o.allowWrite === undefined )
  o.allowWrite = 1;

  if( o.allowRewrite && o.allowRewriteFileByDir === undefined  )
  o.allowRewriteFileByDir = true;

  _.routineOptions( filesCopyWithAdapter,o );
  self._providerOptions( o );

  /* safe */

  if( self.safe )
  if( o.removingSource && ( !o.allowWrite || !o.allowRewrite ) )
  throw _.err( 'not safe removingSource:1 with allowWrite:0 or allowRewrite:0' );

  o.src = self.path.normalize( o.src );
  o.dst = self.path.normalize( o.dst );

  let options = Object.create( null );
  _.mapExtend( options, _.mapOnly( o, filesReflect.defaults ) );

  /*
    'investigateDestination',
    'verbosity',
    'silentPreserve?',
    'resolvingSoftLink',
    'resolvingTextLink',
    'allowDelete',
    'allowWrite',
    'allowRewrite',
    'allowRewriteFileByDir',
    'removingSourceTerminals',
    'removingSource',
    'tryingPreserve',
    'ext?',
    'maxSize?',
    'usingTime?',
  */

  options.linking = options.linking ? 'hardlink' : 'fileCopy';
  options.srcDeleting = o.removingSource || o.removingSourceTerminals; // check it
  options.dstDeleting = o.allowDelete;
  options.writing = o.allowWrite;
  options.dstRewriting = o.allowRewrite;
  options.dstRewritingByDistinct = o.allowRewriteFileByDir; // check it
  options.preservingTime = o.preservingTime;
  options.preservingSame = o.tryingPreserve; // check it
  options.includingDst = o.investigateDestination;

  options.resolvingSrcSoftLink = o.resolvingSoftLink;
  options.resolvingDstSoftLink = o.resolvingSoftLink;
  options.resolvingSrcTextLink = o.resolvingTextLink;
  options.resolvingDstTextLink = o.resolvingTextLink;

  options.onWriteDstUp = o.onUp;
  options.onWriteDstDown = o.onDown;

  delete options.onUp;
  delete options.onDown;

  options.reflectMap = Object.create( null );
  options.reflectMap[ o.src ] = o.dst;

  // options.srcProvider = self;
  // options.dstProvider = self;

  if( !options.filter )
  options.filter = Object.create( null );

  if( options.filter instanceof _.FileRecordFilter )
  {
    options.srcFilter = options.filter.clone();
    // options.dstFilter = options.filter.clone();
  }
  else
  {
    options.srcFilter = self.fileRecordFilter( options.filter );
    // options.dstFilter = self.fileRecordFilter( options.filter );
  }

  options.filter = null;

  options.srcFilter.effectiveFileProvider = self;
  // options.dstFilter.effectiveFileProvider = self;

  if( o.ext )
  {
    _.assert( _.strIs( o.ext ) );
    _.assert( !o.onDstName, 'o.ext is not compatible with o.onDstName' );
    let ext = o.ext;
    options.onDstName = function( relative, dstRecordFactory, op, o, srcRecord )
    {
      if( !srcRecord.isDir )
      return self.path.changeExt( relative,ext );
      return relative;
    }
  }

  let result = self.filesReflect( options );

  result.forEach( ( r ) =>
  {

    if( !r.relative )
    r.relative = r.effective.relative;

    if( r.action === 'directoryMake' )
    if( r.preserve )
    r.action = 'directory preserved';
    else
    r.action = 'directory new';

    if( r.action === 'fileCopy' )
    if( r.preserve )
    r.action = 'same';
    else
    r.action = 'copied'

  })

  return result;
}

filesCopyWithAdapter.defaults =
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

// filesCopyWithAdapter.defaults.__proto__ = _filesFindMasksAdjust.defaults

var paths = filesCopyWithAdapter.paths = Object.create( null );

paths.src = null;
paths.dst = null;

var having = filesCopyWithAdapter.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

// _.routineExtend( filesCopyWithAdapter, filesFindDifference );

var defaults = filesCopyWithAdapter.defaults;

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


//

function _filesPrepareFilters( routine, o )
{
  let self = this;
  let hub = self.hub || self;

  _.assert( arguments.length === 2 );

  /* */

  o.srcFilter = hub.fileRecordFilter( o.srcFilter );
  o.dstFilter = hub.fileRecordFilter( o.dstFilter );

  if( o.filter )
  {
    o.srcFilter.and( o.filter ).pathsJoin( o.filter );
    o.dstFilter.and( o.filter ).pathsJoin( o.filter );
  }

  /* */

  _.assert( _.objectIs( o.srcFilter ) );
  _.assert( _.objectIs( o.dstFilter ) );

  _.assert( !o.srcFilter.formed );
  _.assert( !o.dstFilter.formed );

  _.assert( _.objectIs( o.srcFilter.hubFileProvider ) );
  _.assert( _.objectIs( o.dstFilter.hubFileProvider ) );

  _.assert( !( o.srcFilter.effectiveFileProvider instanceof _.FileProvider.Hub ) );
  _.assert( !( o.dstFilter.effectiveFileProvider instanceof _.FileProvider.Hub ) );

  _.assert( o.srcProvider === undefined );
  _.assert( o.dstProvider === undefined );

}

//

function _filesReflectEvaluate_pre( routine, args )
{
  let self = this;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2 );

  let o = args[ 0 ]
  if( args.length === 2 )
  o = { dstPath : args[ 0 ] , srcPath : args[ 1 ] }

  _.routineOptions( routine,o );
  self._providerOptions( o );

  // if( !_.arrayIs( o.onUp ) )
  // o.onUp = o.onUp ? [ o.onUp ] : [];
  // if( !_.arrayIs( o.onDown ) )
  // o.onDown = o.onDown ? [ o.onDown ] : [];

  o.onUp = _.routinesComposeAll( o.onUp );
  o.onDown = _.routinesCompose( o.onDown );

  if( o.result === null )
  o.result = [];

  if( o.includingDst === null || o.includingDst === undefined )
  o.includingDst = o.dstDeleting;

  self._filesPrepareFilters( routine, o );

  _.assert( _.boolLike( o.includingDst ) );
  _.assert( _.boolLike( o.dstDeleting ) );
  _.assert( !o.dstDeleting || o.includingDst );
  _.assert( o.onDstName === null || _.routineIs( o.onDstName ) );
  _.assert( _.arrayIs( o.result ) );
  _.assert( !o.srcFilter.formed );
  _.assert( !o.dstFilter.formed );
  _.assert( _.arrayHas( [ 'fileCopy', 'hardlink', 'hardlinkMaybe', 'softlink', 'softlinkMaybe', 'nop' ], o.linking ), 'unknown kind of linking', o.linking );
  _.assert( o.srcFilter.formed === 0 );
  _.assert( o.dstFilter.formed === 0 );
  _.assert( o.outputFormat === 'record', 'not implemented' );

  return o;
}

//

function _filesReflectEvaluate_body( o )
{
  let self = this;
  let actionMap = Object.create( null );
  let touchMap = Object.create( null );
  let recordAdd = recordAdd_functor( o );
  let recordRemove = recordRemove_functor( o );

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.boolLike( o.includingDst ) );
  _.assert( _.arrayIs( o.result ) );
  _.assert( _.routineIs( o.onUp ) );
  _.assert( _.routineIs( o.onDown ) );
  _.assert( o.srcFilter.formed <= 3 );
  _.assert( o.dstFilter.formed <= 3 );
  _.assertRoutineOptions( _filesReflectEvaluate_body, o );

  let srcOptions = srcOptionsForm();
  let dstOptions = dstOptionsForm();
  let dstRecordFactory = dstFactoryForm();
  let dst = o.dstFilter.effectiveFileProvider;
  let src = o.srcFilter.effectiveFileProvider;

  _.assert( o.dstFilter.effectiveFileProvider === dstRecordFactory.effectiveFileProvider );
  _.assert( o.dstFilter.hubFileProvider === dstRecordFactory.fileProvider );
  _.assert( o.dstFilter.effectiveFileProvider instanceof _.FileProvider.Abstract );
  _.assert( o.dstFilter.hubFileProvider === o.dstFilter.effectiveFileProvider || o.dstFilter.hubFileProvider instanceof _.FileProvider.Hub );
  _.assert( o.srcFilter.effectiveFileProvider instanceof _.FileProvider.Abstract );
  _.assert( o.srcFilter.hubFileProvider === o.srcFilter.effectiveFileProvider || o.srcFilter.hubFileProvider instanceof _.FileProvider.Hub );
  _.assert( src.path.s.allAreNormalized( o.srcPath ) );
  _.assert( dst.path.isNormalized( o.dstPath ) );

  /* find */

  debugger;
  let found = self.filesFind( srcOptions );
  debugger;

  /* post */

  _.assert( o.mandatory === undefined );
  // if( o.mandatory )
  // if( !o.result.length )
  // {
  //   debugger;
  //   throw _.err( 'No file moved', o.srcPath, '->', o.dstPath );
  // }

  return o.result;

  /* src options */

  function srcOptionsForm()
  {

    o.srcFilter.inFilePath = o.srcPath;
    o.srcFilter.hubFileProvider = o.srcFilter.hubFileProvider || self;
    o.srcFilter._formBasePath();

    o.srcFilter.hubFileProvider = o.srcFilter.hubFileProvider || self;
    _.assert( !!o.srcFilter.hubFileProvider );

    let srcOptions = _.mapOnly( o, self.filesFindSingle.defaults );
    srcOptions.includingBase = 1;
    srcOptions.includingTransient = 1;
    srcOptions.filter = o.srcFilter;
    srcOptions.filePath = o.srcPath;
    srcOptions.result = null;
    srcOptions.onUp = [ handleSrcUp ];
    srcOptions.onDown = [ handleSrcDown ];
    srcOptions.resolvingSoftLink = 0;

    _.mapSupplement( srcOptions, self.filesFindSingle.defaults );

    return srcOptions;
  }

  /* dst options */

  function dstOptionsForm()
  {

    o.dstFilter.inFilePath = o.dstPath;
    o.dstFilter.hubFileProvider = o.dstFilter.hubFileProvider || self;
    o.dstFilter.form();
    o.dstPath = o.dstFilter.branchPath;

    _.assert( _.strIs( o.dstPath ) );
    _.assert( _.objectIs( o.dstFilter.basePath ) );
    _.assert( o.dstFilter.branchPath === o.dstPath );
    _.assert( !!o.dstFilter.effectiveFileProvider );
    _.assert( !!o.dstFilter.hubFileProvider );

    let dstOptions = _.mapExtend( null, srcOptions );
    dstOptions.filter = o.dstFilter;
    dstOptions.filePath = o.dstPath;
    dstOptions.includingBase = 1;
    dstOptions.recursive = 1;
    dstOptions.result = null;
    dstOptions.onUp = [];
    dstOptions.onDown = [ handleDstDown ];
    dstOptions.resolvingSoftLink = 0;

    return dstOptions;
  }

  /* dst factory */

  function dstFactoryForm()
  {

    let dstOp =
    {
      basePath : o.dstFilter.basePath[ o.dstPath ],
      branchPath : o.dstPath,
      resolvingSoftLink : 0,
      // fileProvider : self,
      filter : o.dstFilter,
    }

    // debugger;
    let dstRecordFactory = _.FileRecordFactory.TollerantMake( o, dstOp ).form();
    // debugger;

    _.assert( _.strIs( dstOp.basePath ) );
    _.assert( dstRecordFactory.basePath === _.uri.parse( o.dstFilter.basePath[ o.dstPath ] ).localPath );

    return dstRecordFactory;
  }

  /* add record to result array */

  function recordAdd_functor( o )
  {
    let routine;

    if( o.outputFormat === 'src.absolute' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
      o.result.push( record.src.absolute );
    }
    else if( o.outputFormat === 'src.relative' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
      o.result.push( record.src.relative );
    }
    else if( o.outputFormat === 'dst.absolute' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
      o.result.push( record.dst.absolute );
    }
    else if( o.outputFormat === 'dst.relative' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
      o.result.push( record.dst.relative );
    }
    else if( o.outputFormat === 'record' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
      o.result.push( record );
    }
    else if( o.outputFormat === 'nothing' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
    }
    else _.assert( 0,'unexpected output format :',o.outputFormat );

    return routine;
  }

  /* remove record from result array */

  function recordRemove_functor( o )
  {
    let routine;

    if( o.outputFormat === 'src.absolute' )
    routine = function remove( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.arrayRemoveElementOnceStrictly( o.result, record.src.absolute );
    }
    else if( o.outputFormat === 'src.relative' )
    routine = function remove( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.arrayRemoveElementOnceStrictly( o.result, record.src.relative );
    }
    else if( o.outputFormat === 'dst.absolute' )
    routine = function remove( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.arrayRemoveElementOnceStrictly( o.result, record.dst.absolute );
    }
    else if( o.outputFormat === 'dst.relative' )
    routine = function remove( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.arrayRemoveElementOnceStrictly( o.result, record.dst.relative );
    }
    else if( o.outputFormat === 'record' )
    routine = function remove( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.arrayRemoveElementOnceStrictly( o.result, record );
    }
    else if( o.outputFormat === 'nothing' )
    routine = function remove( record )
    {
    }
    else _.assert( 0, 'unexpected output format :', o.outputFormat );

    return routine;
  }

  /* */

  function recordMake( dstRecord, srcRecord, effectiveRecord )
  {
    _.assert( dstRecord === effectiveRecord || srcRecord === effectiveRecord );
    let record = Object.create( null );
    record.dst = dstRecord;
    record.src = srcRecord;
    record.effective = effectiveRecord;
    record.goingUp = true;
    record.upToDate = false;
    record.srcAction = null;
    record.srcAllow = true;
    record.reason = null;
    record.action = null;
    record.allow = true;
    record.preserve = false;
    record.deleteFirst = false;
    record.touch = false;
    record.include = true;
    return record;
  }

  /* */

  function handleUp( record, op )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( !record.src.isActual && !record.dst.isActual )
    {
      if( !record.src.isDir && !record.dst.isDir )
      return end( false );
    }

    if( !o.includingDst && record.effective === record.dst )
    return end( record );

    if( !o.includingDirectories && record.effective.isDir )
    return end( record );

    if( !o.includingTerminals && !record.effective.isDir )
    return end( record );

    // _.assert( _.arrayIs( o.onUp ) );
    _.assert( _.routineIs( o.onUp ) );
    _.assert( arguments.length === 2 );

    handleUp2.call( self, record, o );

    let result = true;
    let r = o.onUp.call( self, record, o );
    if( r === _.dont )
    return end( false );

    // for( let i = 0 ; i < o.onUp.length ; i++ )
    // {
    //   let routine = o.onUp[ i ];
    //   result = routine.call( self, record, o ) && result;
    //   _.assert( result !== undefined );
    //   if( r === false || r === _.dont )
    //   return end( false );
    // }

    return end( record );

    function end( result )
    {
      if( result && record.include && ( o.includingNonAllowed || record.allow ) )
      {
        recordAdd( record );
      }
      else
      {
        record.include = false;
      }
      return result;
    }
  }

  /* */

  function handleDown( record, op )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( touchMap[ record.dst.absolute ] )
    touch( record, touchMap[ record.dst.absolute ] );
    _.assert( touchMap[ record.dst.absolute ] === record.touch || !record.touch );

    let srcExists = !!record.src.stat;
    let dstExists = !!record.dst.stat;

    // _.assert( _.arrayIs( o.onDown ) );
    _.assert( !!record.dst && !!record.src );
    _.assert( arguments.length === 2 );

    if( !record.include )
    return end( false );

    if( !o.includingDst && record.effective === record.dst )
    return end( record );

    if( !o.includingDirectories && record.effective.isDir )
    return end( record );

    if( !o.includingTerminals && !record.effective.isDir )
    return end( record );

    handleDown2.call( self, record, o );
    // _.routinesCall( self, o.onDown, [ record,o ] );
    let r = o.onDown.call( self, record, o );
    _.assert( r !== _.dont );
    // if( r === _.dont )
    // return end( false );

    _.assert( record.include === true );
    _.assert( record.action !== 'exclude' || record.touch === false )

    if( touchMap[ record.dst.absolute ] )
    touch( record, touchMap[ record.dst.absolute ] );
    _.assert( touchMap[ record.dst.absolute ] === record.touch || !record.touch );

    if( !srcExists && record.reason === 'srcLooking' )
    return end( false );

    if( !record.src.isActual && !record.dst.isActual && !record.touch )
    return end( false );

    if( !o.includingNonAllowed && !record.allow )
    return end( false );

    return end( record.touch );

    function end( result )
    {
      if( result === false )
      {
        if( record.include )
        recordRemove( record );
        record.include = false;
      }
      return result;
    }
  }

  /* */

  function handleDstUp( srcContext, reason, dstFilter, dstRecord, op )
  {

    _.assert( arguments.length === 5 );
    _.assert( _.strIs( reason ) );
    let srcRecord = srcContext.fileRecord( dstRecord.relative );
    let record = recordMake( dstRecord, srcRecord, dstRecord );
    record.reason = reason;

    if( handleUp( record, op ) === false )
    record.include = false;

    return record;
  }

  /* */

  function handleDstDown( record, op )
  {
    handleDown( record, op );
    return record;
  }

  /* */

  function handleSrcUp( srcRecord, op )
  {
    let relative = srcRecord.relative;
    if( o.onDstName )
    relative = o.onDstName.call( self, relative, dstRecordFactory, op, o, srcRecord );

    let dstRecord = dstRecordFactory.fileRecord( relative );
    let record = recordMake( dstRecord, srcRecord, srcRecord );
    record.reason = 'srcLooking';

    if( o.filesGraph )
    {
      if( record.dst.absolute === o.dstPath )
      {
        o.filesGraph.dstPath = o.dstPath;
        o.filesGraph.srcPath = o.srcPath;
        o.filesGraph.actionBegin( o.dstPath + ' <- ' + o.srcPath );
      }
      if( !record.src.isDir )
      {
        o.filesGraph.filesUpdate( record.dst );
        o.filesGraph.filesUpdate( record.src );
        if( o.filesGraph.fileIsUpToDate( record.dst ) )
        record.upToDate = true;
      }
    }

    /* */

    handleUp( record, op );

    if( o.includingDst && record.include && record.src.isActual && record.src.stat )
    if( record.dst.isDir && !record.src.isDir )
    {
      /* src is terminal, dst is dir */

      _.assert( _.strIs( record.dst.context.basePath ) );
      let dstOptions2 = _.mapExtend( null,dstOptions );
      dstOptions2.filePath = record.dst.absolute;
      let filter2 = self.fileRecordFilter
      ({
        effectiveFileProvider : dstOptions.filter.effectiveFileProvider,
        hubFileProvider : dstOptions.filter.hubFileProvider,
      });
      filter2.inFilePath = null;
      filter2.basePath = record.dst.context.basePath;
      dstOptions2.filter = filter2;
      dstOptions2.includingBase = 0;
      dstOptions2.onUp = [ _.routineJoin( undefined, handleDstUp, [ srcRecord.context, 'dstRewriting', filter2 ] ) ];

      let found = self.filesFind( dstOptions2 );

    }

    /* */

    if( record.include && record.goingUp )
    return record;
    else
    return _.dont;
  }

  /* */

  function handleSrcDown( record, op )
  {

    if( o.filesGraph && !record.src.isDir && !record.upToDate )
    {
      record.dst.reval();
      o.filesGraph.dependencyAdd( record.dst, record.src );
    }

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( o.includingDst )
    if( record.dst.isDir && record.src.isDir )
    {
      _.assert( _.strIs( record.dst.context.basePath ) );
      _.assert( _.strIs( record.src.context.basePath ) );

      let dstFiles = record.dst.context.effectiveFileProvider.directoryRead({ filePath : record.dst.absolute, outputFormat : 'absolute' });
      let dstRecords = record.dst.context.fileRecords( dstFiles );
      let srcFiles = record.src.context.effectiveFileProvider.directoryRead({ filePath : record.src.absolute, outputFormat : 'absolute' });
      let srcRecords = record.src.context.fileRecords( srcFiles );

      for( let f = dstRecords.length-1 ; f >= 0 ; f-- )
      {
        let dstRecord = dstRecords[ f ];

        // if( _.strEnds( dstRecord.absolute, debugPath ) )
        // debugger;

        let srcRecord = _.arrayLeft( srcRecords, dstRecord, ( r ) => r.relative ).element;
        if( !srcRecord )
        continue;
        if( /*dstRecord.isActual &&*/ dstRecord.isDir && !srcRecord.isActual )
        continue;
        dstRecords.splice( f, 1 );
      }

      for( let f = 0 ; f < dstRecords.length ; f++ )
      {
        // if( _.strEnds( dstRecords[ f ].absolute, debugPath ) )
        // debugger;

        let dstOptions2 = _.mapExtend( null,dstOptions );
        dstOptions2.filePath = dst.path.join( record.dst.context.basePath, dstRecords[ f ].absolute );
        dstOptions2.filter = dstOptions2.filter.clone();
        dstOptions2.filter.inFilePath = null;
        dstOptions2.filter.basePath = record.dst.context.basePath;
        dstOptions2.onUp = [ _.routineJoin( null, handleDstUp, [ record.src.context, 'dstDeleting', null ] ) ];
        let found = self.filesFind( dstOptions2 );
      }
    }

    handleDown( record, op );

    if( o.filesGraph )
    {
      if( record.dst.absolute === o.dstPath )
      o.filesGraph.actionEnd();
    }

    return record;
  }

  /* */

  function handleUp2( record, op )
  {

    let a = actionMap[ record.dst.absolute ];
    let t = touchMap[ record.dst.absolute ];

    if( !o.writing )
    record.allow = false;

    /* workaround : ignore link to file that does not exist */

    if( record.src.isLink )
    if( !record.src.context.effectiveFileProvider.fileStat( record.src.real ) )
    record.allow = false;

    if( record.reason !== 'srcLooking' && a )
    {
      record.include = false;
      return record
    }

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    _.assert( arguments.length === 2 );
    _.assert( t === undefined || a );

    if( !record.src.stat )
    {
      /* src does not exist or is not actual */

      if( record.reason === 'dstDeleting' && !record.dst.isActual )
      {}
      else if( record.reason === 'srcLooking' && record.dst.isActual && record.dst.isDir && !record.src.isActual && record.src.stat )
      record.include = false;
      else if( ( !record.dst.stat && !record.src.isDir ) || ( record.dst.isTerminal && !record.dst.isActual ) )
      {
        debugger;
        record.include = false;
      }

    }
    else if( record.src.isDir )
    {

      if( !record.dst.stat )
      {
        /* src is dir, dst does not exist */

      }
      else if( record.dst.isDir )
      {
        /* both src and dst are dir */

        if( record.reason === 'srcLooking' && record.dst.isActual && !record.src.isActual )
        if( !record.dst.isBranch )
        record.include = false;

      }
      else
      {
        /* src is dir, dst is terminal */

        if( !record.dst.isActual )
        record.include = false;

        if( !record.src.isActual && record.dst.isActual )
        {
        }
        else if( !record.dst.isActual )
        {
          record.goingUp = false;
          ignore( record );
        }
        else if( !o.dstRewriting || !o.dstRewritingByDistinct )
        {
          record.goingUp = false;
          record.allow = false;
          dirMake( record );
          preserve( record );
        }
        else
        {
          record.deleteFirst = true;
          dirMake( record );
        }

      }

    }
    else
    {

      if( !record.dst.stat )
      {
        /* src is terminal, dst does not exist */
        link( record );

      }
      else if( record.dst.isDir )
      {
        /* src is terminal, dst is dir */

        if( !record.src.isActual && record.reason !== 'dstDeleting' )
        {
          record.include = false;
        }
        else if( record.src.isActual )
        {
          // touch( record, 'destructive' );
          record.deleteFirst = true;
        }

      }
      else
      {
        /* both src and dst are terminals */

        if( record.src.isActual )
        {

          if( shouldPreserve( record ) )
          record.preserve = true;

          if( !o.writing || !o.dstRewriting )
          record.allow = false;

          if( !record.preserve )
          record.deleteFirst = true;

          link( record );

        }
        else
        {

          if( o.dstDeleting )
          fileDelete( record );
          else
          record.include = false;

        }

      }

    }

    return record;
  }

  /* */

  function handleDown2( record, op )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    _.assert( arguments.length === 2 );
    _.assert( !!record.touch === !!touchMap[ record.dst.absolute ] );

    // if( !record.src.stat || ( !record.src.isActual && record.touch !== 'constructive' && !record.action ) )
    if( !record.src.stat )
    {
      /* src does not exist */

      if( record.reason === 'dstRewriting' )
      {
        /* if dst rewriting and src is included */
        if( !o.dstRewriting && record.src.isActual )
        record.allow = false;
      }
      else if( record.reason === 'dstDeleting' )
      {
        /* if dst deleting or src is not included then treat as src does not exist */
        if( !o.dstDeleting )
        record.allow = false;
      }
      else if( !record.src.isActual )
      {
        /* if dst deleting or src is not included then treat as src does not exist */
        if( !o.dstDeleting )
        record.allow = false;

      }

      _.assert( !record.action );
      _.assert( !record.srcAction );
      _.assert( !!record.reason );

      if( record.reason === 'dstDeleting' && !record.dst.isActual && !record.touch )
      {
        ignore( record );
      }
      else if( record.reason !== 'dstDeleting' && ( !record.dst.isActual || !record.dst.stat ) && !record.touch )
      {
        record.allow = false;
        action( record, 'exclude' );
      }
      else
      {
        dirDeleteOrPreserve( record, 'ignore' );
      }

    }
    else if( record.src.isDir )
    {

      if( !record.dst.stat )
      {
        /* src is dir, dst does not exist */

        if( !record.src.isActual )
        {
          if( record.touch === 'constructive' )
          dirMake( record );
          else
          action( record, 'exclude' );
        }
        else
        {
          dirMake( record );
        }

      }
      else if( record.dst.isDir )
      {
        /* both src and dst are dir */

        if( !record.src.isActual )
        {
          if( record.reason === 'srcLooking' && record.dst.isBranch )
          {
            dirMake( record );
            preserve( record );
          }
          else
          {
            // if( !o.dstDeleting ) // xxx
            // record.allow = false;
            dirDeleteOrPreserve( record );
          }
        }
        else
        {
          dirMake( record );
          // action( record, 'directoryMake' );
          // preserve( record );
        }

      }
      else
      {
        /* src is dir, dst is terminal */

        if( o.dstRewritingPreserving )
        if( o.writing && o.dstRewriting && o.dstRewritingByDistinct )
        throw _.err( 'Can\'t rewrite terminal ' + record.dst.absolute + ' by directory ' + record.src.absolute + ', dstRewritingPreserving is enabled' );

        if( !record.src.isActual && record.dst.isActual )
        if( record.touch === 'constructive' )
        {
          record.deleteFirst = true;
          dirMake( record );
          // action( record, 'directoryMake' );
          // touch( record, 'constructive' );
        }
        else
        {
          fileDelete( record );
        }

        _.assert( !record.src.isActual || !!record.touch );

      }

    }
    else
    {

      if( !record.dst.stat )
      {
        /* src is terminal file and dst does not exists */
        // _.assert( record.action === o.linking );
      }
      else if( record.dst.isDir )
      {
        /* src is terminal, dst is dir */

        if( !o.writing || !o.dstRewriting || !o.dstRewritingByDistinct )
        {
          record.allow = false;
        }
        else if( o.dstRewritingPreserving )
        {
          if( self.filesHasTerminal( record.dst.hubAbsolute ) )
          throw _.err( 'Can\'t rewrite directory ' + _.strQuote( record.dst.absolute ) + ' by terminal ' + _.strQuote( record.src.absolute ) + ', directory has terminal(s)' );
        }

        if( record.touch === 'constructive' )
        {
          // action( record, 'directoryMake' );
          record.preserve = true;
          dirMake( record );
        }
        else
        {
          if( record.src.isActual )
          {
            record.deleteFirst = true;
            link( record );
          }
          else
          {
            // record.deleteFirst = false;
            _.assert( record.deleteFirst === false );
            if( !o.dstDeleting )
            record.allow = false;
            if( !record.dst.isActual && record.touch !== 'destructive' )
            record.allow = false;
            dirDeleteOrPreserve( record );
            // if( record.dst.isActual ) // xxx
            // fileDelete( record );
          }
        }

      }
      else
      {
        /* both src and dst are terminals */

        if( o.writing && o.dstRewriting && o.dstRewritingPreserving )
        if( !self.filesAreSame( record.src, record.dst ) )
        throw _.err( 'Can\'t rewrite terminal ' + _.strQuote( record.dst.absolute ) + ' by terminal ' + _.strQuote( record.src.absolute ) + ', terminals have different content' );
      }

    }

    _.assert( !!record.reason );
    _.assert( !record.srcAction );
    _.assert( _.strIs( record.action ), () => 'Action for record ' + _.strQuote( record.src.relative ) + ' was not defined' );

    srcDeleteMaybe( record );

    return record;
  }

  /* touch */

  function action( record, action )
  {

    _.assert( _.strIs( o.dstPath ) );
    _.assert( arguments.length === 2 );
    _.assert( _.arrayHas( [ 'exclude', 'ignore', 'fileDelete', 'directoryMake', 'fileCopy', 'softlink', 'hardlink', 'nop' ], action ) );

    let absolutePath = record.dst.absolute;
    let result = actionMap[ absolutePath ] === action;

    _.assert( record.action === null );
    record.action = action;

    if( action === 'exclude' || action === 'ignore' )
    {
      _.assert( actionMap[ absolutePath ] === undefined );
      return result;
    }

    actionMap[ absolutePath ] = action;

    return result
  }

  /* touch */

  function touch( record, kind )
  {

    kind = kind || 'constructive';

    _.assert( _.strIs( o.dstPath ) );
    _.assert( arguments.length === 2 );
    _.assert( _.arrayHas( [ 'src', 'constructive', 'destructive' ], kind ) );

    let absolutePath = record.dst.absolute;
    touchAct( absolutePath, kind );

    if( Config.debug && kind === 'destructive' )
    {
      for( let m in touchMap )
      if( _.strBegins( m, absolutePath ) && touchMap[ m ] !== 'destructive' )
      {
        debugger;
        touchMap[ m ] = 'destructive';
      }
    }

    record.touch = kind;

    if( kind === 'src' )
    return;

    if( absolutePath === o.dstPath || absolutePath === '/' )
    return;

    do
    {
      absolutePath = dst.path.dir( absolutePath );
      touchAct( absolutePath, kind );
    }
    while( absolutePath !== o.dstPath && absolutePath !== '/' );
  }

  /* touchAct */

  function touchAct( absolutePath, kind )
  {

    if( kind === 'src' && touchMap[ absolutePath ] )
    return;

    if( kind === 'destructive' && touchMap[ absolutePath ] === 'constructive' )
    return;

    touchMap[ absolutePath ] = kind;

  }

  /* */

  function dirHaveFiles( record )
  {
    if( !record.dst.isDir )
    return false;
    if( touchMap[ record.dst.absolute ] === 'constructive' )
    return true;
    let files = record.dst.context.effectiveFileProvider.directoryRead({ filePath : record.dst.absolute, outputFormat : 'absolute' });
    files = files.filter( ( file ) => actionMap[ file ] !== 'fileDelete' );
    return !!files.length;
  }

  /* */

  function shouldPreserve( record )
  {

    if( !o.preservingSame )
    return false;

    if( record.upToDate )
    return true;

    if( o.linking === 'fileCopy' )
    {
      if( self.filesAreSame( record.dst, record.src ) )
      return true;
    }

    return false;
  }

  /* */

  function dirDeleteOrPreserve( record, preserveAction )
  {
    _.assert( !record.action );
    if( !preserveAction )
    preserveAction = 'directoryMake';

    if( dirHaveFiles( record ) )
    {
      /* preserve dir if it has filtered out files */
      // touch( record, 'constructive' );
      if( preserveAction === 'directoryMake' )
      {
        dirMake( record );
        // action( record, preserveAction );
        // preserve( record );
        _.assert( record.preserve === true );
      }
      else
      ignore( record );
    }
    else
    {
      if( !o.writing )
      record.allow = false;

      if( !o.dstDeletingCleanedDirs )
      if( record.dst.isDir && !record.dst.isActual )
      return ignore( record );

      fileDelete( record );
    }

    return record;
  }

  /* */

  function preserve( record )
  {
    _.assert( _.strIs( record.action ) );
    record.preserve = true;
    touch( record, 'constructive' );
    return record;
  }

  /* */

  function link( record )
  {
    _.assert( !record.action );
    _.assert( !record.upToDate );

    if( !record.src.isActual )
    {
      record.include = false;
      return;
    }

    // debugger;
    let linking = o.linking;
    if( _.strHas( linking, 'Maybe' ) )
    {
      // debugger; xxx
      if( src === dst )
      linking = _.strRemoveEnd( linking, 'Maybe' );
      else
      linking = 'fileCopy';
    }

    action( record, linking );
    touch( record, 'constructive' );

    return record;
  }

  /* */

  function dirMake( record )
  {
    _.assert( !record.action );

    if( record.dst.isDir || actionMap[ record.dst.absolute ] === 'directoryMake' )
    record.preserve = true;

    action( record, 'directoryMake' );
    touch( record, 'constructive' );

    return record;
  }

  /* */

  function ignore( record )
  {
    _.assert( !record.action );
    touch( record, 'constructive' );
    action( record, 'ignore' );
    record.preserve = true;
    record.allow = false;
    return record;
  }

  /* */

  function fileDelete( record )
  {
    _.assert( !record.action );

    if( record.reason === 'dstDeleting' && !o.dstDeleting )
    record.allow = false;

    action( record, 'fileDelete' );
    touch( record, 'destructive' );
  }

  /* */

  function srcDeleteMaybe( record )
  {

    if( !o.srcDeleting )
    return false;
    if( !record.src.isActual )
    return false;
    if( !record.allow )
    return false;
    if( !record.include )
    return false;

    srcDelete( record );
  }

  /* delete src */

  function srcDelete( record )
  {

    /* record.dst.isActual could be false */

    _.assert( !!record.src.isActual );
    _.assert( !!record.include );
    _.assert( !!record.allow );
    _.assert( !!record.action );
    _.assert( !!o.srcDeleting );

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( record.allow )
    if( !record.src.stat )
    {
    }
    else if( record.src.isDir )
    {
      _.assert( record.action === 'directoryMake' || record.action === 'fileDelete' );
      record.srcAction = 'fileDelete';
      record.srcAllow = !!o.writing;
      touch( record, 'src' )
    }
    else
    {
      record.srcAction = 'fileDelete';
      record.srcAllow = !!o.writing;
      touch( record, 'src' )
    }

  }

}

let filesReflectSingleDefaults = Object.create( null );
var defaults = filesReflectSingleDefaults;

defaults.filesGraph = null;
defaults.filter = null;
defaults.srcFilter = null;
defaults.dstFilter = null;

defaults.result = null;
defaults.outputFormat = 'record';
// defaults.mandatory = 0;

defaults.ignoringNonexistent = 0;
defaults.includingTerminals = 1;
defaults.includingDirectories = 1;
defaults.includingNonAllowed = 1;
// defaults.includingTransient = 1;
// defaults.includingBase = 1;
defaults.includingDst = null;

defaults.recursive = 1;
// defaults.resolvingSoftLink = 0;
// defaults.resolvingTextLink = 0;

defaults.linking = 'fileCopy';
defaults.writing = 1;
defaults.srcDeleting = 0;
defaults.dstDeleting = 0;
defaults.dstDeletingCleanedDirs = 1;
defaults.dstRewriting = 1;
defaults.dstRewritingByDistinct = 1;
defaults.dstRewritingPreserving = 0;
defaults.preservingTime = 0;
defaults.preservingSame = 0;

defaults.onUp = null;
defaults.onDown = null;
defaults.onDstName = null;

var defaults = _filesReflectEvaluate_body.defaults = Object.create( filesReflectSingleDefaults );

defaults.srcPath = null;
defaults.dstPath = null;

var paths = _filesReflectEvaluate_body.paths = Object.create( null );

paths.srcPath = null;
paths.dstPath = null;

var having = _filesReflectEvaluate_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

let filesReflectEvaluate = _.routineFromPreAndBody( _filesReflectEvaluate_pre, _filesReflectEvaluate_body );

filesReflectEvaluate.having.aspect = 'entry';

//

function _filesReflectSingle_pre( routine, args )
{
  let self = this;

  let o = self.filesReflectEvaluate.pre.call( self, routine, args );

  o.onWriteDstUp = _.routinesCompose( o.onWriteDstUp );
  o.onWriteDstDown = _.routinesCompose( o.onWriteDstDown );
  o.onWriteSrcUp = _.routinesCompose( o.onWriteSrcUp );
  o.onWriteSrcDown = _.routinesCompose( o.onWriteSrcDown );

  return o;
}

//

function _filesReflectSingle_body( o )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( _filesReflectSingle_body, o );
  _.assert( o.mandatory === undefined )

  let o2 = _.mapOnly( o, self.filesReflectEvaluate.body.defaults );
  o2.outputFormat = 'record';
  _.assert( _.arrayIs( o2.result ) );
  self.filesReflectEvaluate.body.call( self, o2 );
  _.assert( o2.result === o.result );

  let hub = self.hub || self;
  let src = o.srcFilter.effectiveFileProvider;
  let dst = o.dstFilter.effectiveFileProvider;

  /* */

  if( o.writing )
  {
    forEach( writeDstUp, writeDstDown );
  }

  /* */

  if( o.writing && o.srcDeleting )
  {
    forEach( writeSrcUp, writeSrcDown );
  }

  /* */

  return o.result;

  /* - */

  function forEach( up, down )
  {
    let filesStack = [];

    for( let r = 0 ; r < o.result.length ; r++ )
    {
      let record = o.result[ r ];

      while( filesStack.length && !_.strBegins( record.dst.absolute, filesStack[ filesStack.length-1 ].dst.absolute ) )
      down( filesStack.pop() );
      filesStack.push( record );

      up( record );
    }

    while( filesStack.length )
    down( filesStack.pop() );

  }

  /*  */

  function writeDstUp( record )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    let onr = o.onWriteDstUp.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr );
    _.assert( _.boolIs( onr ) );

    /* */

    if( !onr )
    return onr;

    if( record.deleteFirst )
    dstDelete( record );

    if( _.arrayHas( [ 'fileCopy', 'softlink', 'hardlink', 'nop' ], record.action ) )
    link( record );
    else if( record.action === 'fileDelete' )
    dstDelete( record );
    else if( record.action === 'directoryMake' )
    dstDirectoryMake( record );
    else if( record.action === 'ignore' )
    {}
    else _.assert( 0, 'Not implemented action ' + record.action );

    return onr;
  }

  /* */

  function writeDstDown( record )
  {
    let onr = o.onWriteDstDown.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr );
    _.assert( _.boolIs( onr ) );
    return onr;
  }

  function writeSrcUp( record )
  {
    // console.log( 'writeSrcUp', record.dst.absolute );
    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;
    // debugger;

    let onr = o.onWriteDstUp.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr );
    _.assert( _.boolIs( onr ) );

    /* */

    if( !onr )
    return onr;

    return onr;
  }

  /* */

  function writeSrcDown( record )
  {
    // console.log( 'writeSrcDown', record.dst.absolute );
    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;
    // debugger;

    srcDeleteMaybe( record );

    let onr = o.onWriteSrcDown.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr );
    _.assert( _.boolIs( onr ) );
    return onr;
  }

  /* */

  function dstDirectoryMake( record )
  {

    if( !record.allow )
    return;
    if( record.preserve )
    return;

    _.assert( !record.upToDate );
    _.assert( !!record.src.isActual || !!record.touch );
    _.assert( !!record.touch );
    _.assert( !!record.action );

    record.dst.context.effectiveFileProvider.directoryMake
    ({
      recursive : 1,
      rewritingTerminal : 0,
      filePath : record.dst.absolute,
    });

  }

  /* */

  function dstDelete( record )
  {
    if( !record.allow )
    return;
    if( record.dst.absolute === record.src.absolute )
    return;
    record.dst.context.effectiveFileProvider.filesDelete( record.dst.absolute );
  }

  /* */

  function link( record )
  {
    _.assert( !record.upToDate );
    _.assert( !!record.src.isActual );
    _.assert( !!record.touch );
    _.assert( !!record.action );

    if( !record.allow || record.preserve )
    return;

    if( record.action === 'hardlink' )
    {
      /* qqq : should not change time of file if it is already linked */
      // debugger;
      dst.linkHard
      ({
        dstPath : record.dst.absolute,
        srcPath : record.src.absolute,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }
    else if( record.action === 'softlink' )
    {
      /* qqq : should not change time of file if it is already linked */
      hub.linkSoft
      ({
        dstPath : record.dst.hubAbsolute,
        srcPath : record.src.hubAbsolute,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
        allowMissing : 1,
      });
    }
    else if( record.action === 'fileCopy' )
    {
      hub.fileCopy
      ({
        dstPath : record.dst.hubAbsolute,
        srcPath : record.src.hubAbsolute,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }
    else if( record.action === 'nop' )
    {
    }
    else _.assert( 0 );

  }

  /* */

  function srcDeleteMaybe( record )
  {
    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( !record.srcAllow || !record.srcAction )
    return false;

    srcDelete( record );
  }

  /* delete src */

  function srcDelete( record )
  {

    /* record.dst.isActual could be false */

    _.assert( !!record.src.isActual );
    _.assert( !!record.include );
    _.assert( !!record.allow );
    _.assert( !!record.action );
    _.assert( !!o.srcDeleting );
    _.assert( record.srcAction === 'fileDelete' );

    // debugger;
    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( record.allow )
    if( !record.src.stat || !record.src.isActual )
    {
      debugger; xxx
    }
    else if( record.src.isDir )
    {
      _.assert( record.action === 'directoryMake' || record.action === 'fileDelete' );
      if( !record.src.context.effectiveFileProvider.directoryRead( record.src.absolute ).length )
      {
        record.src.context.effectiveFileProvider.fileDelete( record.src.absolute );
      }
      else
      {
        record.srcAllow = false;
      }
    }
    else
    {
      _.assert( record.action === 'fileCopy' || record.action === 'hardlink' || record.action === 'softlink' || record.action === 'nop' );
      record.src.context.effectiveFileProvider.fileDelete( record.src.absolute );
    }

  }

}

var defaults = _filesReflectSingle_body.defaults = Object.create( filesReflectSingleDefaults );

defaults.srcPath = null;
defaults.dstPath = null;

defaults.onWriteDstUp = null;
defaults.onWriteDstDown = null;
defaults.onWriteSrcUp = null;
defaults.onWriteSrcDown = null;

defaults.breakingSrcHardLink = null;
defaults.resolvingSrcSoftLink = null;
defaults.resolvingSrcTextLink = null;
defaults.breakingDstHardLink = null;
defaults.resolvingDstSoftLink = null;
defaults.resolvingDstTextLink = null;

var paths = _filesReflectSingle_body.paths = Object.create( null );

paths.srcPath = null;
paths.dstPath = null;

var having = _filesReflectSingle_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

let filesReflectSingle = _.routineFromPreAndBody( _filesReflectSingle_pre, _filesReflectSingle_body );

filesReflectSingle.having.aspect = 'entry';

//

function _filesReflect_pre( routine, args )
{
  let self = this;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2 );

  let o = args[ 0 ]
  if( args.length === 2 )
  o = { reflectMap : { [ args[ 1 ] ] : args[ 0 ] } }

  self.filesReflectSingle.pre.call( self, routine, args );

  if( _.strIs( o.reflectMap ) )
  o.reflectMap = { [ o.reflectMap ] : true }

  _.assert( _.mapIs( o.reflectMap ) );
  _.assert( o.dstPath === undefined );
  _.assert( o.srcPath === undefined );

  return o;
}

//

function _filesReflect_body( o )
{
  let self = this;
  let path = self.path;
  let cons = [];

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( _filesReflect_body, o );

  o.reflectMap = path.globMapExtend( null, o.reflectMap );
  let groupedGlobMap = path.globMapGroupByDst( o.reflectMap );
  _.assert( _.all( o.reflectMap, ( e, k ) => k === false || path.is( k ) ) );

  /* */

  for( let dstPath in groupedGlobMap )
  {

    let o2 = _.mapOnly( o, self.filesReflectSingle.body.defaults );
    o2.dstPath = dstPath;
    o2.srcPath = groupedGlobMap[ dstPath ];
    o2.srcFilter = o2.srcFilter.clone();
    o2.dstFilter = o2.dstFilter.clone();
    o2.result = [];
    _.assert( _.arrayIs( o2.result ) );

    o2.srcFilter.inFilePath = groupedGlobMap[ dstPath ];
    o2.srcFilter._formBasePath();

    o2.dstFilter.inFilePath = dstPath;
    o2.dstFilter._formBasePath();

    let src = o2.srcFilter.effectiveFileProvider;
    cons.push( src.filesReflectSingle.body.call( src, o2 ) );
    _.arrayAppendArray( o.result, o2.result );

  }

  debugger;
  if( _.any( cons, ( con ) => _.consequenceIs( con ) ) )
  {
    debugger;
    let con = new _.Consequence().give().andThen( cons );
    con.ifNoErrorThen( end );
    return con;
  }

  return end();

  /* */

  function end()
  {

    debugger;
    if( o.mandatory )
    if( !o.result.length )
    {
      debugger;
      throw _.err( 'No file moved\n', _.toStr( o.reflectMap, { levels : 2, multiline : 1, wrap : 0 } ) );
    }

    return o.result;
  }

}

var defaults = _filesReflect_body.defaults = Object.create( filesReflectSingleDefaults );

defaults.reflectMap = null;
defaults.mandatory = 0;

defaults.onWriteDstUp = null;
defaults.onWriteDstDown = null;
defaults.onWriteSrcUp = null;
defaults.onWriteSrcDown = null;

defaults.breakingSrcHardLink = null;
defaults.resolvingSrcSoftLink = null;
defaults.resolvingSrcTextLink = null;
defaults.breakingDstHardLink = null;
defaults.resolvingDstSoftLink = null;
defaults.resolvingDstTextLink = null;

let filesReflect = _.routineFromPreAndBody( _filesReflect_pre, _filesReflect_body );

//

function filesReflector_functor( routine )
{

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( routine ) );
  _.routineExtend( reflector, routine );
  return reflector;

  function reflector()
  {
    let self = this;
    let op0 = self._filesFindOptions( arguments, 1 );
    _.assertMapHasOnly( op0, reflector.defaults );
    return er;

    function er()
    {
      let o = _.mapExtend( null, op0 );
      o.filter = self.fileRecordFilter( o.filter );
      o.srcFilter = self.fileRecordFilter( o.srcFilter );
      o.dstFilter = self.fileRecordFilter( o.dstFilter );

      for( let a = 0 ; a < arguments.length ; a++ )
      {
        let op2 = arguments[ a ];

        if( _.strIs( op2 ) )
        op2 = { reflectMap : { [ op2 ] : true } }

        op2.filter = op2.filter || Object.create( null );
        op2.srcFilter = op2.srcFilter || Object.create( null );
        op2.dstFilter = op2.dstFilter || Object.create( null );

        o.filter.and( op2.filter );
        o.filter.pathsJoin( op2.filter );
        o.srcFilter.and( op2.srcFilter );
        o.srcFilter.pathsJoin( op2.srcFilter );
        o.dstFilter.and( op2.dstFilter );
        o.dstFilter.pathsJoin( op2.dstFilter );

        if( op2.reflectMap )
        {
          if( _.strIs( o.reflectMap ) )
          o.reflectMap = { [ o.reflectMap ] : true }
          if( _.strIs( op2.reflectMap ) )
          op2.reflectMap = { [ op2.reflectMap ] : true }
          o.reflectMap = _.mapExtend( o.reflectMap || null, op2.reflectMap );
        }

        op2.reflectMap = o.reflectMap;
        op2.filter = o.filter;
        op2.srcFilter = o.srcFilter;
        op2.dstFilter = o.dstFilter;

        _.mapExtend( o, op2 );
      }

      return routine.call( self, o );
    }

  }

}

let filesReflector = filesReflector_functor( filesReflect );

//

function _filesFindSame_body( o )
{
  let self = this;
  let logger = self.logger;
  let r = o.result = o.result || Object.create( null );

  /* result */

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( r ) );
  _.assert( _.strIs( o.filePath ) );
  _.assert( o.outputFormat === 'record' );

  /* time */

  let time;
  if( o.usingTiming )
  time = _.timeNow();

  /* find */

  let findOptions = _.mapOnly( o, filesFind.defaults );
  findOptions.outputFormat = 'record';
  findOptions.result = [];
  r.unique = self.filesFind.body.call( self, findOptions );

  /* adjust found */

  for( let f1 = 0 ; f1 < r.unique.length ; f1++ )
  {
    let file1 = r.unique[ f1 ];

    if( !file1.stat )
    {
      r.unique.splice( f1, 1 );
      f1 -= 1;
      continue;
    }

    if( file1.isDir )
    {
      r.unique.splice( f1, 1 );
      f1 -= 1;
      continue;
    }

    if( !file1.stat.size > o.maxSize )
    {
      r.unique.splice( f1, 1 );
      f1 -= 1;
      continue;
    }

  }

  /* compare */

  r.similarArray = [];
  r.similarMaps = Object.create( null );
  r.similarGroupsArray = [];
  r.similarGroupsMap = Object.create( null );
  r.similarFilesInTotal = 0;
  r.linkedFilesMap = Object.create( null );
  r.linkGroupsArray = [];

  /* */

  for( let f1 = 0 ; f1 < r.unique.length ; f1++ )
  {
    let file1 = r.unique[ f1 ]
    let path1 = o.relativePaths ? file1.relative : file1.absolute;

    for( let f2 = f1 + 1 ; f2 < r.unique.length ; f2++ )
    {

      let file2 = r.unique[ f2 ];
      let path2 = o.relativePaths ? file2.relative : file2.absolute;
      let minSize = Math.min( file1.stat.size, file2.stat.size );
      let maxSize = Math.max( file1.stat.size, file2.stat.size );

      if( _.fileStatsCouldBeLinked( file1.stat, file2.stat ) )
      {
        // console.log( 'linked :', file1.absolute, file2.absolute );
        // if( _.strHas( file1.absolute, 'fonts/icons' ) )
        // debugger;
        linkAdd();
        continue;
      }

      if( minSize / maxSize < o.similarityLimit )
      continue;

      if( !file1.stat.hash )
      file1.stat.hash = _.strLattersSpectre( self.fileRead( file1.absolute ) );
      if( !file2.stat.hash )
      file2.stat.hash = _.strLattersSpectre( self.fileRead( file2.absolute ) );

      if( self.verbosity >= 4 )
      logger.log( '. strLattersSpectresSimilarity', path1, path2 );
      let similarity = _.strLattersSpectresSimilarity( file1.stat.hash, file2.stat.hash );

      if( similarity < o.similarityLimit )
      continue;

      similarityAdd( similarity );

    }

  }

  /* */

  similarGroupsRefine();
  linkGroupsRefine();

  return o.result;

  /* */

  function similarityAdd( similarity )
  {

    let d = Object.create( null );
    d.path1 = path1;
    d.path2 = path2;
    d.similarity = similarity;
    d.id = r.similarArray.length;
    r.similarArray.push( d );

    let similarMap = r.similarMaps[ path1 ] = r.similarMaps[ path1 ] || Object.create( null );
    similarMap[ path2 ] = d;
    similarMap = r.similarMaps[ path2 ] = r.similarMaps[ path2 ] || Object.create( null );
    similarMap[ path1 ] = d;

    let group1 = r.similarGroupsMap[ path1 ];
    let group2 = r.similarGroupsMap[ path2 ];

    if( !group1 )
    r.similarFilesInTotal += 1;

    if( !group2 )
    r.similarFilesInTotal += 1;

    if( group1 && group2 )
    {
      if( group1 === group2 )
      return;
      groupMove( group1, group2 );
    }

    let group = group1 || group2;

    if( !group )
    {
      group = Object.create( null );
      group.paths = [];
      group.paths.push( path1 );
      group.paths.push( path2 );
      r.similarGroupsArray.push( group );
    }
    else if( !group1 )
    {
      _.arrayAppendOnceStrictly( group.paths, path1 );
    }
    else if( !group2 )
    {
      _.arrayAppendOnceStrictly( group.paths, path2 );
    }

    r.similarGroupsMap[ path1 ] = group;
    r.similarGroupsMap[ path2 ] = group;

    // if( r.similarGroupsMap[ path2 ] )
    // {
    //   debugger;
    //   if( r.similarGroupsMap[ similarGroup1 ] )
    //   similarGroup1 = groupMove( path2, similarGroup1 );
    // }
    // else
    // {
    //   r.similarFilesInTotal += 1;
    //
    //   if( !r.similarGroupsMap[ similarGroup1 ] )
    //   {
    //     _.arrayAppendOnceStrictly( r.similarGroupsArray, similarGroup1 );
    //     r.similarGroupsMap[ similarGroup1 ] = [];
    //     r.similarFilesInTotal += 1;
    //   }
    //
    //   let group = r.similarGroupsMap[ similarGroup1 ]
    //   _.arrayAppendOnce( group, path1 );
    //   _.arrayAppendOnce( group, path2 );
    //
    // }

  }

  /* */

  function groupMove( dst, src )
  {
    debugger;

    _.arrayAppendArrayOnceStrictly( dst.paths, src.paths );
    _.arrayRemoveElementOnceStrictly( r.similarGroupsArray, src );

    // if( _.strIs( r.similarGroupsMap[ dst ] ) )
    // debugger;
    // if( _.strIs( r.similarGroupsMap[ dst ] ) )
    // dst = r.similarGroupsMap[ dst ];
    // _.assert( _.arrayIs( r.similarGroupsMap[ src ] ) );
    // _.assert( _.arrayIs( r.similarGroupsMap[ dst ] ) );
    // for( let i = 0 ; i < r.similarGroupsMap[ src ].length ; i++ )
    // {
    //   debugger;
    //   let srcElement = r.similarGroupsMap[ src ][ i ];
    //   _.assert( _.strIs( r.similarGroupsMap[ srcElement ] ) || srcElement === src );
    //   _.arrayAppendOnceStrictly( r.similarGroupsMap[ dst ], srcElement );
    //   r.similarGroupsMap[ srcElement ] = dst;
    // }
    // _.arrayRemoveElementOnceStrictly( r.similarGroupsArray, src );

    return dst;
  }

  /* */

  function similarGroupsRefine()
  {
    for( let g in r.similarGroupsMap )
    {
      let group = r.similarGroupsMap[ g ];
      group.id = r.similarGroupsArray.indexOf( group );
      r.similarGroupsMap[ g ] = group.id;
    }
  }

  /* */

  function linkAdd()
  {
    let d1 = r.linkedFilesMap[ path1 ];
    let d2 = r.linkedFilesMap[ path2 ];
    _.assert( !d1 || !d2, 'Two link descriptors for the same instance of linked file', path1, path2 );
    let d = d1 || d2;
    if( !d )
    {
      d = Object.create( null );
      d.paths = [];
      d.paths.push( path1 );
      d.paths.push( path2 );
      r.linkGroupsArray.push( d );
    }
    else if( !d1 )
    {
      _.arrayAppendOnceStrictly( d.paths, path1 );
    }
    else
    {
      _.arrayAppendOnceStrictly( d.paths, path2 );
    }
    r.linkedFilesMap[ path1 ] = d;
    r.linkedFilesMap[ path2 ] = d;
  }

  /* */

  function linkGroupsRefine()
  {
    for( let f in r.linkedFilesMap )
    {
      let d = r.linkedFilesMap[ f ];
      d.id = r.linkGroupsArray.indexOf( d )
      r.linkedFilesMap[ f ] = d.id;
    }
  }

}

_.routineExtend( _filesFindSame_body, filesFindRecursive );

var defaults = _filesFindSame_body.defaults;

defaults.maxSize = 1 << 22;
// defaults.lattersFileSizeLimit = 1048576;
defaults.similarityLimit = 0.95;

// defaults.usingFast = 1;
// defaults.usingContentComparing = 1;
// defaults.usingTakingNameIntoAccountComparingContent = 1;
// defaults.usingLinkedCollecting = 0;
// defaults.usingSameNameCollecting = 0;

defaults.investigatingLinking = 1;
defaults.investigatingSimilarity = 1;
defaults.usingTiming = 0;
defaults.relativePaths = 0;

defaults.result = null;

let filesFindSame = _.routineFromPreAndBody( filesFind.pre, _filesFindSame_body );

filesFindSame.having.aspect = 'entry';

// --
// delete
// --

function _filesDelete_pre( routine,args )
{
  let self = this;
  args = _.longSlice( args );
  let o = self.__filesFind_pre( routine, args, 0 );
  return o;
}

//

function _filesDelete_body( o )
{
  let self = this;

  let time;
  if( o.verbosity >= 2 )
  time = _.timeNow();

  _.assert( !o.includingTransient, 'Transient files should not be included' );
  _.assert( o.resolvingTextLink === 0 || o.resolvingTextLink === false );
  _.assert( o.resolvingSoftLink === 0 || o.resolvingSoftLink === false );
  _.assert( o.outputFormat === 'record' );
  _.assert( arguments.length === 1 );

  /* */

  // _.each( o.filePath, () =>

  let exists = self.fileExists( o.filePath );
  // let stat = self.fileStat( o.filePath );
  // let stat = self.fileExists( o.filePath );

  if( !exists )
  return;

  let stat = self.fileStat({ filePath : o.filePath, throwing : 1, resolvingSoftLink : 0 });

  if( stat.isFile() )
  return self.fileDelete
  ({
    filePath : o.filePath,
    sync : 1,
    throwing :  o.throwing,
    verbosity : o.verbosity
  });

  /* */

  // debugger;
  let optionsForFind = _.mapOnly( o, self.filesFind.defaults );
  optionsForFind.verbosity = 0;
  self.fieldSet( 'resolvingSoftLink', 0 );
  // debugger;
  let files = self.filesFind.body.call( self, optionsForFind );
  // debugger;
  self.fieldReset( 'resolvingSoftLink', 0 );
  // debugger;

  /* */

  for( let f = files.length-1 ; f >= 0 ; f-- )
  {
    let file = files[ f ];
    file.context.effectiveFileProvider.fileDelete
    ({
      filePath : file.absolute,
      sync : 1,
      throwing : o.throwing,
      verbosity : o.verbosity-1,
    });
  }

  if( o.verbosity >= 2 )
  logger.log( _.timeSpent( 'filesDelete ' + o.result.length + ' files at ' + o.filePath + ' in', time ) );

}

_.routineExtend( _filesDelete_body, filesFind );

var defaults = _filesDelete_body.defaults;

defaults.outputFormat = 'record';
defaults.recursive = 1;
defaults.includingTransient = 0;
defaults.includingDirectories = 1;
defaults.includingTerminals = 1;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;
defaults.verbosity = null;
defaults.maskPreset = 0;

defaults.throwing = null;

//

let filesDelete = _.routineFromPreAndBody( _filesDelete_pre, _filesDelete_body );

filesDelete.having.aspect = 'entry';

var defaults = filesDelete.defaults;
var paths = filesDelete.paths;
var having = filesDelete.having;

_.assert( !!defaults );
_.assert( !!paths );
_.assert( !!having );

//

function filesDeleteForce( o )
{
  let self = this;

  o = self._filesFindOptions( arguments,0 );

  _.routineOptions( filesDeleteForce, o );

  return self.filesDelete( o );
}

_.routineExtend( filesDeleteForce, filesDelete );

var defaults = filesDeleteForce.defaults;

//

function filesDeleteFiles( o )
{
  let self = this;

  o = self._filesFindOptions( arguments,0 );

  _.routineOptions( filesDeleteFiles, o );

  _.assert( o.includingTerminals );
  _.assert( !o.includingDirectories );
  _.assert( !o.includingTransient );

  _.assert( 0, 'not tested' ); // qqq

  return self.filesDelete( o );
}

_.routineExtend( filesDeleteFiles, filesDelete );

defaults.recursive = 1;
defaults.includingTerminals = 1;
defaults.includingDirectories = 0;
defaults.includingTransient = 0;

//

/*
qqq : add test coverage, extract pre and body, please
*/

function filesDeleteEmptyDirs()
{
  let self = this;

  // _.assert( arguments.length === 1 || arguments.length === 3 );
  // let o = self._filesFindOptions( arguments,1 );

  debugger;
  let o = filesDeleteEmptyDirs.pre.call( self,filesDeleteEmptyDirs, arguments );
  debugger;

  /* */

  // _.assert( 0, 'not tested' ); // qqq

  //o.outputFormat = 'absolute'; // qqq
  // o.includingTerminals = 0;
  // o.includingTransient = 1;

  _.assert( !o.includingTerminals );
  _.assert( o.includingDirectories );
  _.assert( !o.includingTransient );

  if( o.recursive === undefined )
  o.recursive = 1;

  // _.routineOptions( filesDeleteEmptyDirs, o );

  /* */

  let options = _.mapOnly( o, self.filesFind.defaults );

  options.onDown = _.arrayAppendElement( _.arrayAs( o.onDown ), function( record )
  {

    try
    {

      let sub = self.directoryRead( record.absolute );
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

    return record;
  });

  debugger;
  let files = self.filesFind.body.call( self, options );
  debugger;

  // return new _.Consequence().give();

  return files;
}

_.routineExtend( filesDeleteEmptyDirs, filesDelete );

var defaults = filesDeleteEmptyDirs.defaults;

defaults.throwing = false;
defaults.verbosity = null;
defaults.outputFormat = 'absolute';
defaults.includingTerminals = 0;
defaults.includingDirectories = 1;
defaults.includingTransient = 0;
defaults.recursive = 1;

// --
// other find
// --

function softLinksBreak( o )
{
  let self = this;

  o = self.filesFind.pre.call( self, softLinksBreak, arguments );

  _.assert( o.outputFormat === 'record' );

  /* */

  let optionsFind = _.mapOnly( o, filesFind.defaults );
  optionsFind.onDown = _.arrayAppendElement( _.arrayAs( optionsFind.onDown ), function( record )
  {

    debugger;
    throw _.err( 'not tested' );

    if( o.breakingSoftLink && record.isSoftLink )
    self.softLinkBreak( record.absolute );
    if( o.breakingTextLink && record.isTextLink )
    self.softLinkBreak( record.absolute );

  });

  let files = self.filesFind.body.call( self,optionsFind );

  return files;
}

_.routineExtend( softLinksBreak, filesFind );

var defaults = softLinksBreak.defaults;

defaults.outputFormat = 'record';
defaults.breakingSoftLink = 1;
defaults.breakingTextLink = 0;
defaults.recursive = 1;

//

function softLinksRebase( o )
{
  let self = this;
  o = self.filesFind.pre.call( self, softLinksRebase, arguments );

  _.assert( o.outputFormat === 'record' );
  _.assert( !o.resolvingSoftLink );

  /* */

  let optionsFind = _.mapOnly( o, filesFind.defaults );
  optionsFind.onDown = _.arrayAppendElement( _.arrayAs( optionsFind.onDown ), function( record )
  {
    if( !record.isSoftLink )
    return;

    record.isSoftLink;
    let resolvedPath = self.pathResolveSoftLink( record.hubAbsolute );
    let rebasedPath = self.path.rebase( resolvedPath, o.oldPath, o.newPath );
    self.fileDelete({ filePath : record.hubAbsolute, verbosity : 0 });
    self.linkSoft
    ({
      dstPath : record.hubAbsolute,
      srcPath : rebasedPath,
      allowMissing : 1,
    });
    _.assert( !!self.fileStat({ filePath : record.hubAbsolute, resolvingSoftLink : 0 }) );
  });

  let files = self.filesFind.body.call( self,optionsFind );

  return files;
}

_.routineExtend( softLinksRebase, filesFind );

var defaults = softLinksRebase.defaults;

defaults.outputFormat = 'record';
defaults.oldPath = null;
defaults.newPath = null;
defaults.recursive = 1;
defaults.resolvingSoftLink = 0;

//

function filesHasTerminal( filePath )
{
  var self = this;
  _.assert( arguments.length === 1 );

  let terminal = false;

  self.filesFind
  ({
    filePath : filePath,
    includingBase : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    onUp : onUp,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
    recursive : 1
  })

  return terminal;

  /* */

  function onUp( record )
  {
    if( terminal )
    return false;
    if( record.stat && !record.isDir )
    terminal = record;
    return record;
  }
}

// --
// resolver
// --

function filesResolve( o )
{
  let self = this;
  let result;
  var o = _.routineOptions( filesResolve,arguments );

  _.assert( _.objectIs( o.translator ) );

  let globPath = o.translator.realFor( o.globPath );
  let globOptions = _.mapOnly( o, self.filesGlob.defaults );

  globOptions.filter = globOptions.filter || Object.create( null );
  globOptions.filePath = globPath;
  globOptions.filter.basePath = o.translator.realRootPath;
  globOptions.outputFormat = o.outputFormat;

  _.assert( !!self );

  result = self.filesGlob( globOptions );

  return result;
}

_.routineExtend( filesResolve, filesGlob );

var defaults = filesResolve.defaults;

defaults.recursive = 1;
defaults.globPath = null;
defaults.translator = null;
defaults.outputFormat = 'record';

var paths = filesResolve.paths;

paths.globPath = null;

// --
// relationship
// --

let Composes =
{
}

let Aggregates =
{
}

let Associates =
{
}

let Restricts =
{
}

// --
// declare
// --

let Supplement =
{

  // etc

  recordsOrder : recordsOrder,
  _filesFilterMasksSupplement : _filesFilterMasksSupplement,

  // find

  _filesFindOptions : _filesFindOptions,
  _filesFilterForm : _filesFilterForm,
  __filesFind_pre : __filesFind_pre,

  filesFindSingle : filesFindSingle,
  filesFind : filesFind,
  filesFindRecursive : filesFindRecursive,
  filesGlob : filesGlob,

  filesFinder_functor : filesFinder_functor,
  filesFinder : filesFinder,
  filesGlober : filesGlober,

  // reflect

  filesCopyWithAdapter : filesCopyWithAdapter,

  _filesPrepareFilters : _filesPrepareFilters,

  filesReflectEvaluate : filesReflectEvaluate,
  filesReflectSingle : filesReflectSingle,
  filesReflect : filesReflect,

  filesReflector_functor : filesReflector_functor,
  filesReflector : filesReflector,

  // same

  filesFindSame : filesFindSame,

  // delete

  filesDelete : filesDelete,

  filesDeleteForce : filesDeleteForce,
  filesDeleteFiles : filesDeleteFiles,
  filesDeleteEmptyDirs : filesDeleteEmptyDirs,

  // other find

  softLinksBreak : softLinksBreak,
  softLinksRebase : softLinksRebase,
  filesHasTerminal : filesHasTerminal,

  // resolver

  filesResolve : filesResolve,

  //

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.classDeclare
({
  cls : Self,
  supplement : Supplement,
  withMixin : true,
  withClass : true,
});

_.FileProvider = _.FileProvider || Object.create( null );
_.FileProvider[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
{ /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
