assert = chai.assert

$ = Rye

ajax = Rye.require('Ajax')
escape = (v) -> v.replace /[[\]]/g, (v) -> ('[': '%5B', ']': '%5D')[v]

class Number.Countdown
    constructor: (@index = 0, @done) ->
    valueOf: -> @index
    toString: -> @index.toString()
    fire: => @done() unless --@index

suite 'Ajax', ->

    test 'get request', (done) ->
        countdown = new Number.Countdown(2, done)
        ajax.request '/echo', (data) ->
            assert.equal data, 'get no data'
            countdown.fire()

        ajax.request url: '/echo', data: {fizz: 1, bar: 2}, callback: (data) ->
            assert.equal data, 'get 2'
            countdown.fire()

    test 'post request', (done) ->
        countdown = new Number.Countdown(2, done)
        ajax.request url: '/echo', type: 'post', (data) ->
            assert.equal data, 'post no data'
            countdown.fire()

        ajax.request url: '/echo', data: {fizz: 1, bar: 2}, type: 'post', (data) ->
            assert.equal data, 'post 2'
            countdown.fire()

    test 'X-Requested-With', (done) ->
        countdown = new Number.Countdown(3, done)
        ajax.request url: '/requested-with', (data) ->
            assert.equal data, 'X-Requested-With XMLHttpRequest'
            countdown.fire()

        ajax.request method: 'post', url: '/requested-with', (data) ->
            assert.equal data, 'X-Requested-With XMLHttpRequest'
            countdown.fire()

        ajax.request crossDomain: true, url: '/requested-with', (data) ->
            assert.equal data, 'X-Requested-With undefined'
            countdown.fire()

    test 'appendQuery', ->
        assert.equal ajax.appendQuery('url', 'par=1'), 'url?par=1'
        assert.equal ajax.appendQuery('url?par=1', 'bar=2'), 'url?par=1&bar=2'
        assert.equal ajax.appendQuery('??', '?par=1'), '?par=1'

    test 'params', ->
        assert.equal ajax.param({foo: {one: 1, two: 2}}), escape 'foo[one]=1&foo[two]=2'
        assert.equal ajax.param({ids: [1,2,3]}), escape 'ids[]=1&ids[]=2&ids[]=3'
        assert.equal ajax.param({foo: 'bar', nested: {will: 'not be ignored'}}), escape 'foo=bar&nested[will]=not+be+ignored'
        assert.equal ajax.param([{name: 'foo', value: 'bar'}]), escape 'foo=bar'

