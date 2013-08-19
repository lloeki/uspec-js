###
# uspec.js v0.5
# (c) 2013 Loic Nageleisen
# Licensed under 3-clause BSD
###

class Ansi
    @CSI = "\x1B["
    @END = "m"

    @BLACK   = 0
    @RED     = 1
    @GREEN   = 2
    @YELLOW  = 3
    @BLUE    = 4
    @MAGENTA = 5
    @CYAN    = 6
    @WHITE   = 7

    @FORE = 30
    @BACK = 40

    @SGR_RESET   = @CSI + @END
    @SGR_BLACK   = @CSI + (@FORE + @BLACK)   + @END
    @SGR_RED     = @CSI + (@FORE + @RED)     + @END
    @SGR_GREEN   = @CSI + (@FORE + @GREEN)   + @END
    @SGR_YELLOW  = @CSI + (@FORE + @YELLOW)  + @END
    @SGR_BLUE    = @CSI + (@FORE + @BLUE)    + @END
    @SGR_MAGENTA = @CSI + (@FORE + @MAGENTA) + @END
    @SGR_CYAN    = @CSI + (@FORE + @CYAN)    + @END
    @SGR_WHITE   = @CSI + (@FORE + @WHITE)   + @END


indent = (str, level = 0) ->
    str = indent(str, level - 1) if level > 0
    str.replace(/^/gm, '  ')


all_examples = {}


describe = (target) ->
    [setup, teardown, examples] = switch arguments.length
        when 2 then [(-> {}),       (->), arguments[1]]
        when 3 then [arguments[1],  (->), arguments[2]]
        else [arguments[1], arguments[2], arguments[3]]

    all_examples[target] =
        setup:    setup
        teardown: teardown
        examples: examples


class AssertionError
    constructor: (@message) ->
    toString: -> "AssertionError: #{@message}"


class PendingError
    constructor: (@message) ->
    toString: -> "PendingError: #{@message}"


assert = (callback) ->
    unless callback() == true
        throw new AssertionError "assertion failed:\n#{indent callback.toString()}"


assert_throws = (exception, callback) ->
    try
        callback()
    catch e
        return if e instanceof exception
        throw e
    throw new AssertionError "assertion failed:\n#{indent callback.toString()}"


pending = (message = '') ->
    throw new PendingError message


run = (log = new Log(new AnsiWriter)) ->
    for target, info of all_examples
        log.current target
        for example, test of info.examples
            try
                throw new PendingError if test.toString() == (->).toString()
                test.call(info.setup())
                info.teardown()
                log.pass example
            catch e
                if e instanceof AssertionError
                    log.fail example, e
                else if e instanceof PendingError
                    log.pending example, e
                else
                    log.fail example, e

    log.results


PASS    = 'pass'
FAIL    = 'fail'
PENDING = 'pending'


class Log
    constructor: (@writer = new NaiveWriter) ->
        @results = {}

    log: (example, status, message = '') ->
        @results[@target][example] =
            status: status
            message: message

    current: (target) ->
        @target = target
        @results[@target] = {}
        @writer.current(target)

    pass: (example) ->
        this.log(example, PASS)
        @writer.pass(example)

    fail: (example, e) ->
        this.log(example, FAIL, e.message)
        @writer.fail(example)

    pending: (example, p) ->
        this.log(example, PENDING)
        @writer.pending(example, p.message)


summary = (results) ->
    total =
        pass: 0
        fail: 0
        pending: 0
    for target, examples of results
        for example, result of examples
            switch result.status
                when PASS     then total.pass    += 1
                when FAIL     then total.fail    += 1
                when PENDING  then total.pending += 1
    total.all = total.pass + total.fail + total.pending

    console.log ''
    console.log 'Failures:\n' if total.fail > 0
    counter = 0
    for target, examples of results
        for example, result of examples
            if result.status == FAIL
                counter += 1
                console.log indent "#{counter}) #{Ansi.SGR_RED}#{target} #{example}#{Ansi.SGR_RESET}"
                unless result.message is undefined
                    console.log indent(result.message, 2) + "\n"

    console.log "#{total.all} examples, #{total.fail} failure, #{total.pending} pending"

    total.fail == 0


class AnsiWriter
    constructor: ->
    current: (target) -> console.log "\n#{target}"
    pass: (example) -> console.log "    #{Ansi.SGR_GREEN}#{example}#{Ansi.SGR_RESET}"
    fail: (example) -> console.log "    #{Ansi.SGR_RED}#{example}#{Ansi.SGR_RESET}"
    pending: (example) -> console.log "    #{Ansi.SGR_YELLOW}#{example}#{Ansi.SGR_RESET}"


class AnsiDotWriter
    current: (target) ->
    pass: (example) -> console.log "#{Ansi.SGR_GREEN}.#{Ansi.SGR_RESET}"
    fail: (example) -> console.log "#{Ansi.SGR_RED}F#{Ansi.SGR_RESET}"
    pending: (example) -> console.log "#{Ansi.SGR_YELLOW}##{Ansi.SGR_RESET}"


class DotWriter
    current: (target) ->
    pass: (example) -> console.log "."
    fail: (example) -> console.log "F"
    pending: (example) -> console.log "#"


class NaiveWriter
    current: (target) -> console.log "#{target}"
    pass: (example) -> console.log "    #{example}: pass"
    fail: (example) -> console.log "    #{example}: fail"
    pending: (example) -> console.log "    #{example}: pending"

class NullWriter
    current: ->
    pass: ->
    fail: ->
    pending: ->


exports.run                 = run
exports.describe            = describe
exports.assert              = assert
exports.assert_throws       = assert_throws
exports.pending             = pending
exports.summary             = summary
exports.AssertionError      = AssertionError
exports.PendingError        = PendingError
