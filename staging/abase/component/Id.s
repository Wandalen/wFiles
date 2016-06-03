(function(){

'use strict';

var Self = wTools;
var _ = wTools;

var _ArraySlice = Array.prototype.slice;
var _FunctionBind = Function.prototype.bind;
var _ObjectToString = Object.prototype.toString;
var _ObjectHasOwnProperty = Object.hasOwnProperty;

var _assert = _.assert;
var _arraySlice = _.arraySlice;

// --
// id
// --

var idGenerateDate = function( prefix,postfix,fast )
{

  var date = new Date;

  prefix = prefix ? prefix : '';
  postfix = postfix ? postfix : '';

  if( fast ) return prefix + date.valueOf() + postfix;

  var d =
  [
    date.getFullYear(),
    date.getMonth()+1,
    date.getDate(),
    date.getHours(),
    date.getMinutes(),
    date.getSeconds(),
    date.getMilliseconds(),
    Math.floor( 1 + Math.random()*0x100000000 ).toString(16),
  ].join( '-' );

  return prefix + d + postfix
}

//

var idGenerateGuid = (function()
{

  function s4()
  {
    return Math.floor( ( 1 + Math.random() ) * 0x10000 ).toString( 16 ).substring( 1 );
  }

  return function()
  {

    var result =
    [
      s4() + s4(),
      s4(),
      s4(),
      s4(),
      s4() + s4() + s4(),
    ].join( '-' );

    return result;
  };

})();

//

var idNumber = (function()
{

  var counter = 0;

  return function()
  {
    _assert( arguments.length === 0 );
    counter += 1;
    return counter;
  }

})();

// --
// prototype
// --

var Proto =
{

  // id

  idGenerateDate: idGenerateDate,
  idGenerateGuid: idGenerateGuid,
  idNumber: idNumber,

}

_.mapExtend( Self, Proto );

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
{
  module[ 'exports' ] = Self;
}

})();
