interface { name = "someinterface",
    methods = {
        foo = {
            resulttype = "double",
            args = {{
                direction = "in",
                type = "double"
            }, {
                direction = "in",
                type = "string"
            }, {
                direction = "out",
                type = "string"
            }, {
                direction = "in",
                type = "double"
            }}
        },
        bar = {
            resulttype = "void",
            args = {{
                direction = "inout",
                type = "double"
            }}
        }
    }
}
