// Relies on gotoB.js

c.ready(function() {
    function die(msg) {
        throw msg;
    };
    function capitalize(str) {
        return str[0].toUpperCase() + str.slice(1);
    };

    var constSheetId = c.get("#sheetId", 'value').value;

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
    // Take the excel-style coloumn designator, and turn it into a number
    function alphaToNum(alpha) {
        var letters = alpha.toUpperCase();
        var sum = 0;
        for (var i = 0; i < letters.length; i++) {
            sum *= 26;
            sum += (letters.charCodeAt(i) - ("A".charCodeAt(0) - 1));
        }
        return sum;
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
                ["font-style", "italic"]
            ]
        };
    };

    function rowHeader(idx) {
        return {
            input: "",
            output: idx.toString(),
            attr: {isUserReadOnly: true},
            styles: [
                ["font-style", "italic"]
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
        var cellAddr = path[path.length - 1];
        var val = getCell(path).input;
        if(teishi.stop('textbox', [ 
           ['path', path, 'array'],
        ])) return false;

        var evts = [
            ["onchange", 'cell.change', ['*'], {rawArgs: ['value', JSON.stringify(path)] }],
            ["onkeyup", 'cell.keyup', ['*'], {rawArgs: ['event.keyCode', 'value']} ]
        ];
        return ['input', 
                B.ev({
                    id: "active-input",
                    type: 'text',
                    value: val,
                    opaque: true,
                }, evts)];
    };

    function formattedCell(path, cellAddr) {
        var cell = B.get(path) ||  {
                input: "",
                output: "", 
                attr: {},
                style: [],
        };
        var evts = [
            ["onmousedown", 'cell.focusSingle', ['*'], {rawArgs: [JSON.stringify(path)]}]
        ];
        return ['td', B.ev({id: "cell-" + cellAddr}, evts), cell.output];
    }
    function getCell(path) {
        return B.get(path) || {
            input: "",
            output: "",
            attr: {},
            style: [],
        };
    }

    var cellView = function(x, path) {
        // Get the address of the cell here.
        var cellAddr = path[path.length - 1];
        // Get with a default
        var cell = getCell(path);
        var currentFocus = B.get(['State', 'sheet', 'selection']);
        if (cellAddr === currentFocus) {
            return ['td', {id: 'cell-' + cellAddr}, cellBox(path)];
        }
        return formattedCell(path, cellAddr);
    }

    var appEvents = [ 
        ['cell.change', ['*'], function(x, value, path) {
            B.do('set', path.concat('input'), value);
        }],
        ['cell.keyup', ['*'], function(x, keyCode, value) {
            B.do('set', ['State', 'scratch', 'focusVal'], value);
        }],
        ['cell.focusSingle', ['*'], function(x, path) {
            var prevCellAddr = B.get(['State', 'sheet', 'selection']);
            if (prevCellAddr) {
                var prevCell = getCell(['State', 'sheet', 'cells'].concat(prevCellAddr))
                var scratchVal = B.get(['State', 'scratch', 'focusVal']);
                prevCell.input = scratchVal || "";
                prevCell.output = scratchVal || "";
                B.set(['State', 'sheet', 'cells', prevCellAddr], prevCell);
                // If we have a non-empty cell
                if (prevCell.input.length > 0) {
                    B.do('ajax', 'saveCell', prevCellAddr, prevCell);
                }
            }
            var cell = getCell(path);
            var cellAddr = path[path.length - 1];
            B.set(['State', 'scratch', 'focusVal'], cell.input);
            // Don't allow the user to focus on presentation-only cells
            if (cell.attr.isUserReadOnly) return;
            B.set(['State', 'sheet', 'selection'], cellAddr)
            B.do('change', ['State', 'sheet']);
            setTimeout(function() {
                var el = c("#active-input");
                el.focus();
            }, 0);
        }],
        ['ajax', 'loadCells', function(x, toLoad) {
            var lCells=  toLoad.cells;
            dale.do(lCells, function(v, k) {
                B.set(['State', 'sheet', 'cells', k.replace(":", "_")], v);
            });
            B.do('change', ['State', 'sheet', 'cells']);
        }],
        ['ajax', 'saveCell', function(x, cellAddr, value) {

            var addrBits = cellAddr.split("_");
            var col = alphaToNum(addrBits[0]);
            var row = Number.parseInt(addrBits[1]);
            console.log(value);
            var data = {
                cells: [{
                    row: row,
                    col: col,
                    input: value.input,
                    attrs: value.attr,
                }]
            };

            c.ajax('POST', '/sheet/api/data/' + constSheetId, {}, data,
            function(err, resp){
                if (err) console.log(err);
                // TODO: Add in logic for patching cells here.
                else console.log(resp);
            });
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

        var extents = { rowMax:20, colMax:10 };
        sheetCells["@_0"] = {};
        dale.do(dale.times(extents.rowMax), function(idx) {
            sheetCells["@_" + idx] = rowHeader(idx);
        });
        dale.do(dale.times(extents.colMax), function(idx) {
            sheetCells[numToAlpha(idx) + "_0"] = colHeader(idx);
        });

        return B.view(
            ['State', 'sheet'], 
            {listen:appEvents},
            function(x) {
                // By default, try a 20x10
                return ['table', {'class': "speadSheet"}, [
                    // for 20 rows
                     dale.do(dale.times(20, 0), function(rowIdx) {
                        return [ 'tr',
                        // for 20 columns
                            dale.do(dale.times(10, 0), function(colIdx) {
                                var cellAddr = numToAlpha(colIdx) + "_" + rowIdx;
                                return cellView(x, ['State', 'sheet', 'cells', cellAddr]);
                            })
                        ];
                    })
                ]];
            }
        );
    };

    B.mount('#sheetApp', sheetView());
    B.do('change', ['State', 'sheet', 'cells']);
    c.ajax('GET', '/sheet/api/data/' + constSheetId, {}, {}, function(err, resp) {
        if (err) {console.log(err); }
        else {
            B.do('ajax', 'loadCells', resp.body);
        }

    });
});

