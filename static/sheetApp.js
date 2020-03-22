// Relies on gotoB.js

c.ready(function() {
    function die(msg) {
        throw msg;
    };
    function capitalize(str) {
        return str[0].toUpperCase() + str.slice(1);
    };

    function formFromObj(obj) {
        var form = new FormData();
        dale.do(obj, function(v, k) {
            form.append(k, v);
        });
        return form;
    };
    // Take a number and turn it into Excel-style row/column designator
    function numToAlpha(num) {
        if (num <= 26) {
            return String.fromCharCode(num + 64);
        } 
        var acc = 0;
        var retVal = "";
        // Truncating divide
        var d = ~~(acc/26);
        var rem = ~~(acc%26);
        if (rem === 0) {
            rem = 26;
            d--;
        }
        return numToAlpha(d) + numToAlpha(rem);
    };
    // TODO: Reverse the above operation

    function styleOf(pairs) {
        return dale.do(pairs, function(p) {
            return p[0] + ":" + p[1];
        }).join("; ");
    }

    function colHeader(idx) {
        return {
            input: "",
            output: numToAlpha(idx),
            attr: {isUserReadOnly: true},
            styles: [
                [ "font-style", "italic" ]
            ]
        };
    };

    function rowHeader(idx) {
        return {
            input: "",
            output: idx.toString(),
            attr: {isUserReadOnly: true},
            styles: [
                [ "font-style", "italic" ]
            ]
        };
    };
    // 
    function getSheetExtents(sheetCells) {
        var colList = dale.do(sheetCells, function(v, k) { return parseInt(k.split(':')[0],10); });
        var rowList = dale.do(sheetCells, function(v, k) { return parseInt(k.split(':')[1],10); });
        return {
            colMax: Math.max(dale.acc(colList, Math.max), 10),
            rowMax: Math.max(dale.acc(rowList, Max.max), 40),
        };
    };

    function cellBox(path) {
        //
        var toShow = B.get(path).output;
        if(teishi.stop('textbox', [ 
           ['path', path, 'array'],
        ])) return false;

        var evts = [
            ["onchange", 'set', path, {rawArgs: ['value']}],
            ["onkeyup", 'cell.keyup', ['*'], {rawArgs: ['event.keyCode', 'value']} ]
        ];

        return ['input', B.ev({type: 'text', value: val}, evts)];
    };

    function formattedCell(path) {
        var cell = B.get(path) ||  {
                input: "",
                output: "", 
                attr: {},
                style: [],
        };
        var evts = [
            ["onclick", 'cell.focusSingle', path]
        ];
        return ['div', B.ev({}, evts), cell.output];
    }

    var cellView = function(path) {
        // Get the address of the cell here.
        var cellAddr = path[path.length - 1];
        // Get with a default
        var cell = B.get(path) || {
            input: "",
            output: "",
            attr: {},
            style: [],
        };
        var cellEvents = [
            ['cell.focusSingle', path, function(x) {
                // Don't allow the user to focus on presentation-only cells
                if (cell.attr.isUserReadOnly) return;
                B.set(['State', 'sheet', 'selection'], cellAddr)
                B.do('change', path)
            }]
        ];
        function cellRender(x) {
            var currentFocus = B.get(['State', 'sheet', 'selection']);
            if (cellAddr === currentFocus) {
                return ['td', {id: 'cell-' + cellAddr}, cellBox(path)];
            }
            return ['td', {id: "cell-" cellAddr}, formattedCell(path)]
        };
        return B.view(path, {listen: cellEvents}, cellRender);
    }

    var appEvents = [ 
        ['cell.keyup', ['*'], function(x, keyCode, value) {
        }],
        ['ajax', 'reportFailure', function(x, err) {
            console.error(err);
        }]
    ];

    var sheetView = function() {
        // the k/v object of cell contents
        // The key is a "x:y" string, the values are cell contents
        var sheetCells = B.get(['State', 'sheet', 'cells']) || {};
        B.set(['State', 'sheet', 'cells'], sheetCells);

        var extents = getExtents(sheetCells);
        sheetCells["0:0"] = {isUserReadOnly: true, content : {computed: [] } };
        dale.do(dale.times(extents.rowMax), function(idx) {
            sheetCells["0:" + idx] = rowHeader(idx);
        });
        dale.do(dale.times(extents.colMax), function(idx) {
            sheetCells[idx + ":0"] = colHeader(idx);
        });

        return B.view(
            ['State', 'sheet'], 
            {listen:appEvents},
            function(x) {
                // By default, try a 20x10
                return ['table', {'class': "speadSheet"} [
                    // for 20 rows
                    dale.do(dale.times(20, 0), function(rowIdx) {
                        return [ 'tr',
                        // for 20 columns
                            dale.do(dale.times(10, 0), function(colIdx) {
                                var cellAddr = numToAlpha(colIdx) + ":" + rowIdx;
                                return cellView(['State', 'sheet', 'cellsw', cellAddr])
                            }
                        ];
                    })
                ]];
            }
        );
    };

    B.mount('#sheet', sheetView());
});

