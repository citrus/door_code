// Global variables

var keypad;
var form;
var display;
var displayLed;

var validKeys;
var invalidKeys;
var backspace;
var one;
var two;
var three;
var four;
var five;
var six;
var seven;
var eight;
var nine;

var interval;
var code;
var codeLength;

var defaultClass = 'green';
var successClass = 'blue';
var failureClass = 'red';

// jQuery

$(document).ready(function(){
  
  // First things first, fetch the code length
  $.ajax({
    type: "GET",
    url: "/",
    dataType: "text",
    success: function(data, textStatus, jqXHR){
      codeLength = parseInt(data);
    }
  });
  
  keypad = $('#keypad');
  display = $('#display');
  displayLed = display.find('.led');

  validKeys = [ 48,49,50,51,52,53,54,55,56,57,
                96,97,98,99,100,101,102,103,104,105 ];
                
  invalidKeys = [ 65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,
                  0,32,61,107,108,109,110,111,186,187,188,189,190,191,192,219,220,221,222 ];
  
  backspace = 8;
  zero  = [48,96];
  one   = [49,97];
  two   = [50,98];
  three = [51,99];
  four  = [52,100];
  five  = [53,101];
  six   = [54,102];
  seven = [55,103];
  eight = [56,104];
  nine  = [57,105];
  
  // Map clicking on the keys to showing the number in the display
  $('a').click(function(e){
    e.preventDefault();
    if ($('.clone').length < codeLength) {
      var num = $(this).attr('rel');
      if (num === 'clear' || num === 'help') {
        if (num === 'clear') { reset(); } else
        if (num === 'help') { showHelp(); }
      } else {
        displayNum(num);
      }
    }
  });

  // Disable the backspace key and
  // map keyboard number keys to showing the number in the display
  $(document).keydown(function(e) {
    var charCode = (e.which) ? e.which : e.keyCode;
    if (charCode === backspace) { e.preventDefault(); }
    if (charCode === backspace && $('.clone').length > 0) {
      $('.clone').last().remove();
    } else if (validKeys.indexOf(charCode) >= 0 && $('.clone').length < codeLength) {
      var n = charCode;
      var num = '';
      if (zero.indexOf(n) >= 0)       { num = 'zero' }
      else if (one.indexOf(n) >= 0)   { num = 'one' }
      else if (two.indexOf(n) >= 0)   { num = 'two' }
      else if (three.indexOf(n) >= 0) { num = 'three' }
      else if (four.indexOf(n) >= 0)  { num = 'four' }
      else if (five.indexOf(n) >= 0)  { num = 'five' }
      else if (six.indexOf(n) >= 0)   { num = 'six' }
      else if (seven.indexOf(n) >= 0) { num = 'seven' }
      else if (eight.indexOf(n) >= 0) { num = 'eight' }
      else if (nine.indexOf(n) >= 0)  { num = 'nine' }
      if (num !== '') {
        $('#keys a[rel=' + num + ']').addClass('active');
        displayNum(num);
      }
    }
  });
  
  $(document).keyup(function(e){ $('#keys a').removeClass('active'); });

  // Pause before checking the code
  $(document).bindStop('keydown', function(e) { checkCode(); }, 500);
  
});  

// Global functions

function displayNum(num) {
  var anchor = $('#keys a[rel=' + num + ']');
  if (!keypad.hasClass(successClass) && !keypad.hasClass(failureClass)) {
    var led = display.find('.' + num + ':not(.clone)');
    led.clone().addClass('clone').appendTo(displayLed).show();
  }  
}

function checkCode() {
  // Check that the code is the correct length, and check it via ajax
  if ($('.clone').length == codeLength) {
    // Now we need to manually build the code based on the digits on display
    code = '';
    $('.clone').each(function(){
      code += $(this).attr('rel');
    });
    ajax();
  }
}

function ajax() {
  $.ajax({
    type: "POST",
    url: "/",
    data: "code=" + code,
    dataType: "text",
    success: function(data, textStatus, jqXHR){
      if (data === 'success') { showSuccess(); } else
      if (data === 'failure') { showError(); }
    }
  });
}

function showSuccess() {
  // Go blue, show SUCCESS
  $('.clone').remove();
  keypad.addClass(successClass);
  setTimeout('window.location.reload()', 1000);
}

function showError() {
  // Go red, show ERROR
  $('.clone').remove();
  keypad.addClass(failureClass);
  setTimeout('reset()', 1000);
}

function reset() {
  // Go green, clear display, restart interval
  $('.clone').remove();
  keypad.removeClass(failureClass).removeClass(successClass).addClass(defaultClass);
}

function showHelp() {
  console.log('You called for help!')
}