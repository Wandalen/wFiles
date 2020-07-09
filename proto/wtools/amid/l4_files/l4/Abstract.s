( function _Abstract_s_() {

'use strict';

var _global = _global_;
var _ = _global_.wTools;
var FileRecord = _.FileRecord;
var FileRecordFilter = _.FileRecordFilter;
var FileRecordFactory = _.FileRecordFactory;

_.assert( !_.FileProvider.Abstract );
_.assert( _.routineIs( _.FileRecord ) );
_.assert( _.routineIs( FileRecordFilter ) );
_.assert( _.routineIs( FileRecordFactory ) );

/**
 * @class wFileProviderAbstract
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
*/

var Parent = null;
var Self = function wFileProviderAbstract( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Abstract';

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
  RecordFactory : FileRecordFactory,
}

// --
// declare
// --

var Extension =
{

  init,

  // relations

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extension,
});

//

_.FileProvider = _.FileProvider || Object.create( null );
_.FileProvider[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
