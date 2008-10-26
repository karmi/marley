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
    
    if (this.Utils.isIE6()) return false; // :)
    
    Application.Utils.preloadImages( [
    ])

    Application.Page.About.initialize()
    Application.Comments.Thanks.initialize()

    Application.Code.initialize()
    
    // # Debug
    log.debug(this)
  },

  Page : {

    About : {
      initialize : function() {
        this.a = $$('#about h2 a').first()
        this.content_box = $$('#about .content').first()
        if (!this.a || !this.content_box) return false
        this.content_box.hide()
        var zis = this
        this.a.observe( 'click', function(event) { zis.toggle(); Event.stop(event) } )
      },
      toggle : function() {
        var zis = this
        new Effect.toggle(this.content_box, 'blind', 
                          { duration : 0.5//, 
                            // afterFinish : function(){ zis.a.up().toggleClassName('expanded') }
                          }
        )
        if (zis.a.up()) zis.a.up().toggleClassName('expanded')
      }
    }

  },

  Comments : {

    Thanks : {
      initialize : function() {
        var o = $('comment_added_thanks')
        if (o) {
          o.hide()
          new Effect.Appear(o, {delay:0.2})
        }
      }
    }

  },
  
  Code : {
    initialize : function() {
      this.make_code_default_as_ruby()
    },
    make_code_default_as_ruby: function() {
      $$('#article code').invoke('addClassName', 'ruby')
  	}
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