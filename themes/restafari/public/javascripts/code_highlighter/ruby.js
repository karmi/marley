CodeHighlighter.addStyle("ruby",{
	comment : {
		exp  : /#[^\n]+/
	},
	brackets : {
		exp  : /\(|\)/
	},
	string : {
		exp  : /'[^']*'|"[^"]*"/
	},
	keywords : {
		exp  : /\b(do|end|self|class|def|if|module|yield|then|else|for|until|unless|while|elsif|case|when|break|retry|redo|rescue|require|raise|new|private|protected)\b/
	},
	/* Added by Shelly Fisher (shelly@agileevolved.com) */
	symbol : {
	  exp : /([^:])(:[A-Za-z0-9_!?]+)/
	},
	/* Added by Karel Minarik (karmi@karmi.cz) */
	rails : {
		exp  : /\b(render|redirect_to|link_to|url_to|layout|map)\b/
	},
	object : {
		exp  : /[A-Z][a-z]+[\.|:]/
	},
	commands : {
		exp  : /\b(print|puts|open)\b/
	}
});