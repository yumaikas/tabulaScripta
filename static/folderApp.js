// Relies on gotoB.js
c.ready(function() {

    const linkTranslator = {
           "etFolder": "folder",
           "etForm": "form",
           "etSheet": "sheet",
           "etScript": "script",
    };

    function die(msg) {
        throw msg;
    };
    function capitalize(str) {
        return str[0].toUpperCase() + str.slice(1);
    };

    var link = function(folderEntry) {
        var urlPrefix = linkTranslator[folderEntry.entryType] ||  die("Unsupported folder entry type!");

        return ['div',
            ['h3', [['a', {href:("/" + urlPrefix + "/view/" + folderEntry.id)}, 
                folderEntry.name], "(" + capitalize(urlPrefix) + ")"]]
        ];
    };


    function formFromObj(obj) {
        var form = new FormData();
        dale.do(obj, function(v, k) {
            form.append(k, v);
        });
        return form;
    };

    var constFolderId = c.get('#folderId', 'value').value;

    var appEvents = [ 
        ['ajax', 'createEntry', function(x, name, type) {
            c.ajax('POST', '/create/api/'+constFolderId, {}, formFromObj({
                name: name, entryType: type
            }), function(err, resp){
                if (err) B.do('ajax', 'reportFailure', err);
                else B.do('ajax', 'entryCreated', name, type, resp.body);
            });
        }],
        ['ajax', 'entryCreated', function(x, name, type, id){
            console.log(name);
            console.log(type);
            console.log(id);
            B.do('add', ['Data', 'folders'], {
                name: name,
                entryType: type,
                id: parseInt(id, 10),
            })
        },],
        ['startCreate', '*', function(x) {
            B.do('set', ['Data', 'creating', 'active'], true);
            B.do('set', ['Data', 'creating', 'name'], "");
            B.do('set', ['Data', 'creating', 'type'], "etFolder");
        }],
        ['endCreate', '*', function(x) {
            B.do('set', ['Data', 'creating', 'active'], false);
            let name = B.get(['Data', 'creating', 'name']);
            let type = B.get(['Data', 'creating', 'type']);
            B.do('ajax', 'createEntry', name, type);
        }],
        ['creating.keyup', '*', function(x, keycode, evt) {
            if (keycode !== 13) return;
            B.do('endCreate', ['*']);
        }],
        ['ajax', 'reportFailure', function(x, err) {
            console.error(err);
        }]
    ];

    function entrySel(path) {
        return ['select', 
            B.ev(['onchange', 'set', path, {rawArgs: ['value']}]),
            dale.do(linkTranslator, function(v, k) {
                return ['option', {value: k}, capitalize(v)];
            })
        ];
    };
    function textbox(path) {
        let val = B.get(path);
        if(teishi.stop('textbox', [ 
           ['path', path, 'array'],
        ])) return false;

        let evts = [
            ["onchange", 'set', path, {rawArgs: ['value']}],
            ["onkeyup", 'creating.keyup', ['*'], {rawArgs: ['event.keyCode', 'value']} ]
        ];
        console.log(evts);

        return ['input', B.ev({type: 'text', value: val}, evts)];
    };


    var folderView = function() {
        return B.view(['Data'], 
                {listen:appEvents},
                function(x) {
                    let folders = B.get(['Data', 'folders']);
                    let isCreating = B.get(['Data', 'creating', 'active'])
                    let wipName = B.get(['Data', 'creating', 'name'])
                    var createView = ['span', B.ev({class:'action'}, ['onclick', 'startCreate', ""]), 'Create...'];
                    if (isCreating) {
                        createView = ['div', [
                                ['Create a ', entrySel(['Data', 'creating', 'type'])],
                                ' called ',
                                textbox(['Data', 'creating', 'name']), "."
                            ]
                       ];
                    }
                    return ['div', [
                        dale.do(folders, function(fl) { return link(fl); }), 
                        createView,
                    ]
                    ];
                });
    };

    B.mount('#folderapp', folderView());
    c.ajax('GET', '/folder/api/'+constFolderId, {}, '', function(_, resp) {
        // B.do('set', ['Data', 'creatingEntry'], false);
        B.do('set', ['Data', 'creatingEntry'], true);
        B.do('set', ['Data', 'folders'], resp.body);
    });
});

