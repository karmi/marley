// application.js

// Log wrapper
DEBUG=true
if ("undefined" == typeof console) var console = { log : function(what) {} }
log = { debug : function(msg) { if ('undefined' != typeof DEBUG && DEBUG == true) { console.log(msg) } } };

// * Add initialize() handler
document.observe("dom:loaded", function() { try {Application.initialize()} catch(e) { alert('Error when initializing application! \n' + e); } });


// * Application namespace
Application = {
  
  initialize: function(options) {
    
    this.options = options
    this.window = document.viewport.getDimensions()
        
    // # Debug
    log.debug(this)
  },

  // --------- Utils --------------------------------------------------------------------
  
  Utils : {
    
    preloadImages : function(images) {
      for( var i=0; i < images.length; i++) { img = new Image(); img.src = 'images/'+images[i]; }
    },
    
    isIE6 : function() { 
      return navigator.appVersion.include('MSIE 6');  
    }
    
  }
  
};
