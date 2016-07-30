
tokenDefinitions = [
    ["number", "\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?"],
    ["open", "[\\(\\[\\{]|\\b(?:let|for|if|begin)\\b"],
    ["middle", "\\b(?:then|elif|else|in|do|when)\\b"],
    ["close", "[\\)\\]\\}]|\\bend\\b"],
    ["infix", "[,;\n]|[!@$%^&*|/?.:~+=<>-]+|\\b(?:and|or|not)\\b"],
    ["word", "\\w+"],
    ["string", "\"(?:[^\"]|\\\\.)*\""],
    ["comment", "#[^\n]*(?=\n|$)"]
];

function makeCustomMode(cm, defs, modeName) {
    var _re = {}
    for (var entry of defs)
        _re[entry[0]] = entry[1]

    var re = {
        number: new RegExp(_re.number || "\0"),
        string: new RegExp(_re.string || "\0"),
        word: new RegExp(_re.word || "\0"),
        infix: new RegExp(_re.infix || "\0"),
        comment: new RegExp(_re.comment || "\0"),
        open:  new RegExp(_re.open || "\0"),
        middle:  new RegExp(_re.middle || "\0"),
        close:  new RegExp(_re.close || "\0"),
        startClose:  new RegExp("^ *(?:(?:" + (_re.close || "\0") + ")|(?:" + (_re.middle || "\0") + "))"),
        keyword: new RegExp([_re.open, _re.middle, _re.close]
                            .map(x => "("+(x||"\0")+")").join("|"))
    }

    function token(stream, state) {
        stream.eatSpace();
        var m = null;
        var sc = stream.column() + stream.current().length;
        if (stream.match(re.number)) {
            state.state = null;
            return "number";
        }
        else if (stream.match(re.string)) {
            state.state = null;
            return "string";
        }
        else if (m = stream.match(re.open)) {
            state.state = "open";
            stream.eatSpace();
            var align = !stream.eol();
            state.nesting.unshift({start: sc,
                                   column: stream.column() + stream.current().length,
                                   align: align});
            return m[0].match(/\w/) ? "keyword" : null;
        }
        else if (m = stream.match(re.middle)) {
            state.state = "open";
            stream.eatSpace();
            state.nesting[0].column = stream.column() + stream.current().length,
            state.nesting[0].align = !stream.eol();
            return m[0].match(/\w/) ? "keyword" : null;
        }
        else if (m = stream.match(re.close)) {
            state.state = null;
            state.nesting.shift();
            return m[0].match(/\w/) ? "keyword" : null;
        }
        else if (m = stream.match(re.infix)) {
            state.state = "open";
            return m[0].match(/\w/) ? "keyword" : null;
        }
        else if (stream.match(re.word)) {
            state.state = null;
            return "variable"
        }
        else if (stream.match(re.comment)) {
            return "comment"
        }
        else {
            stream.next();
            return null;
        }
    }

    cm.defineMode(modeName, (config, parserConfig) => ({

        startState: () => ({
            state: null,
            nesting: [{start: 0, column: 0, align: true}]
        }),

        token: token,

        indent: function (state, line) {
            var iu = config.indentUnit;
            var n = state.nesting[0]
            if (line.match(re.startClose))
                return n.start;
            else if (n.align)
                return n.column;
            else
                return n.start + iu;
        },

        electricInput: re.startClose

    }));

}
