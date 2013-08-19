minispec = require('./uspec')

describe      = minispec.describe
assert        = minispec.assert
assert_throws = minispec.assert_throws
pending       = minispec.pending
run           = minispec.run
summary       = minispec.summary


describe 'AssertionError',
    'should be exported': ->
        assert -> typeof minispec.AssertionError isnt 'undefined'
    'should take a message': ->
        assert -> (new minispec.AssertionError 'foo').message == 'foo'
    'should render as an error string': ->
        str = (new minispec.AssertionError 'foo').toString()
        assert -> str == "AssertionError: foo"


describe 'PendingError',
    'should be exported': ->
        assert -> typeof minispec.PendingError isnt 'undefined'
    'should take a message': ->
        assert -> (new minispec.PendingError 'foo').message == 'foo'
    'should render as an error string': ->
        str = (new minispec.PendingError 'foo').toString()
        assert -> str == "PendingError: foo"


describe 'pending',
    'should be exported': ->
        assert -> typeof minispec.pending isnt 'undefined'

    'should throw a PendingError containing a blank message': ->
        try
            pending()
        catch e
            assert -> e instanceof minispec.PendingError
            assert -> e.message == ''

    'should throw a PendingError containing a message': ->
        try
            pending('foo')
        catch e
            assert -> e instanceof minispec.PendingError
            assert -> e.message == 'foo'


describe 'assert',
    'should be exported': ->
        assert -> typeof minispec.assert isnt 'undefined'

    'should pass without throwing when assertion returns true': ->
        do ->
            minispec.assert -> true

    'should throw AssertionError when assertion does not return true': ->
        try
            minispec.assert -> false
        catch e
            unless e instanceof minispec.AssertionError
                throw new AssertionError

    'should rethrow exception when assertion throws an exception': ->
        try
            minispec.assert -> throw new Error 'foo'
        catch e
            unless e instanceof Error
                throw new AssertionError
            unless e.message == 'foo'
                throw new AssertionError


describe 'assert_throws',
    'should be exported': ->
        assert -> typeof minispec.assert_throws isnt 'undefined'

    'should pass when block throws the expected exception': ->
        class FooError
        do ->
            minispec.assert_throws FooError, -> throw new FooError

    'should throw AssertionError when block does not throw any exception': ->
        class FooError
        try
            minispec.assert_throws FooError, -> 42
        catch e
            assert -> e instanceof minispec.AssertionError

    'should rethrow exception when block throws an unexpected exception': ->
        class FooError
        class BarError
        try
            minispec.assert_throws FooError, -> throw new BarError
        catch e
            assert -> e instanceof BarError

describe 'describe',
    'should be exported': ->
        assert -> typeof minispec.describe isnt 'undefined'

describe 'run',
    'should be exported': ->
        assert -> typeof minispec.run isnt 'undefined'

results = run()
rc = if summary(results) then 0 else 1

phantom.exit(rc) unless typeof phantom is 'undefined'
process.exit(rc) unless typeof process is 'undefined'
