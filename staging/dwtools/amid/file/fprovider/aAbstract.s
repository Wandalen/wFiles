( function _Abstract_s_() {

'use strict'; /**/

var _global = _global_;
var _ = _global_.wTools;
var FileRecord = _.FileRecord;
var FileRecordFilter = _.FileRecordFilter;
var FileRecordContext = _.FileRecordContext;

_.assert( !_.FileProvider.wFileProviderAbstract );
_.assert( FileRecord );
_.assert( FileRecordFilter );
_.assert( FileRecordContext );

var Parent = null;
var Self = function wFileProviderAbstract( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'Abstract';

//

function init( o )
{
}

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

var Statics =
{
  Record : FileRecord,
  RecordFilter : FileRecordFilter,
  RecordContext : FileRecordContext,
}

// --
// define class
// --

var Proto =
{

  init : init,

  // relationships

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

_.FileProvider = _.FileProvider || Object.create( null );
_.FileProvider[ Self.nameShort ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
