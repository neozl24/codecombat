require '../common'

describe 'LevelComponent', ->

  component =
    name:'BashesEverything'
    description:'Makes the unit uncontrollably bash anything bashable, using the bash system.'
    code: 'bash();'
    language: 'coffeescript'
    permissions:simplePermissions
    propertyDocumentation: []
    system: 'ai'
    dependencies: []

  components = {}

  url = getURL('/db/level.component')

  it 'preparing test : clears things first.', (done) ->
    clearModels [Level, LevelComponent], (err) ->
      expect(err).toBeNull()
      done()

  it 'can\'t be created by ordinary users.', (done) ->
    loginJoe ->
      request.post {uri:url, json:component}, (err, res, body) ->
        expect(res.statusCode).toBe(403)
        done()

  it 'can be created by an admin.', (done) ->
    loginAdmin ->
      request.post {uri:url, json:component}, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        expect(body._id).toBeDefined()
        expect(body.name).toBe(component.name)
        expect(body.description).toBe(component.description)
        expect(body.code).toBe(component.code)
        expect(body.language).toBe(component.language)
        expect(body.__v).toBe(0)
        expect(body.creator).toBeDefined()
        expect(body.original).toBeDefined()
        expect(body.created).toBeDefined()
        expect(body.version).toBeDefined()
        expect(body.permissions).toBeDefined()
        components[0] = body
        done()

  it 'have a unique name.', (done) ->
    loginAdmin ->
      request.post {uri:url, json:component}, (err, res, body) ->
        expect(res.statusCode).toBe(409)
        done()

  it 'can be read by an admin.', (done) ->
    loginAdmin ->
      request.get {uri:url+'/'+components[0]._id}, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        body = JSON.parse(body)
        expect(body._id).toBe(components[0]._id)
        done()

  it 'can be read by ordinary users.', (done) ->
    loginJoe ->
      request.get {uri:url+'/'+components[0]._id}, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        body = JSON.parse(body)
        expect(body._id).toBe(components[0]._id)
        expect(body.name).toBe(components[0].name)
        expect(body.slug).toBeDefined()
        expect(body.description).toBe(components[0].description)
        expect(body.code).toBe(components[0].code)
        expect(body.language).toBe(components[0].language)
        expect(body.__v).toBe(0)
        expect(body.official).toBeDefined()
        expect(body.creator).toBeDefined()
        expect(body.original).toBeDefined()
        expect(body.created).toBeDefined()
        expect(body.configSchema).toBeDefined()
        expect(body.dependencies).toBeDefined()
        expect(body.propertyDocumentation).toBeDefined()
        expect(body.version.isLatestMajor).toBe(true)
        expect(body.version.isLatestMinor).toBe(true)
        expect(body.permissions).toBeDefined()
        done()

  it 'is unofficial by default', (done) ->
    loginJoe ->
      request.get {uri:url+'/'+components[0]._id}, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        body = JSON.parse(body)
        expect(body._id).toBe(components[0]._id)
        expect(body.official).toBe(false)
        done()

  it 'has system ai by default', (done) ->
    loginJoe ->
      request.get {uri:url+'/'+components[0]._id}, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        body = JSON.parse(body)
        expect(body._id).toBe(components[0]._id)
        expect(body.system).toBe("ai")
        done()

  it 'official property isn\'t editable by an ordinary user.', (done) ->
    components[0].official = true
    loginJoe ->
      request.post {uri:url, json:components[0]}, (err, res, body) ->
        expect(res.statusCode).toBe(403)
        done()

  it 'official property is editable by an admin.', (done) ->
    components[0].official = true
    loginAdmin ->
      request.post {uri:url, json:components[0]}, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        expect(body.official).toBe(true)
        expect(body.original).toBe(components[0].original)
        expect(body.version.isLatestMinor).toBe(true)
        expect(body.version.isLatestMajor).toBe(true)
        components[1] = body

        request.get {uri:url+'/'+components[0]._id}, (err, res, body) ->
          expect(res.statusCode).toBe(200)
          body = JSON.parse(body)
          expect(body._id).toBe(components[0]._id)
          expect(body.official).toBe(false)
          expect(body.version.isLatestMinor).toBe(false)
          expect(body.version.isLatestMajor).toBe(false)
          done()

  xit ' can\'t be requested with HTTP PUT method', (done) ->
    request.put {uri:url+'/'+components[0]._id}, (err, res) ->
      expect(res.statusCode).toBe(404)
      done()

  it ' can\'t be requested with HTTP HEAD method', (done) ->
    request.head {uri:url+'/'+components[0]._id}, (err, res) ->
      expect(res.statusCode).toBe(404)
      done()

  it ' can\'t be requested with HTTP DEL method', (done) ->
    request.del {uri:url+'/'+components[0]._id}, (err, res) ->
      expect(res.statusCode).toBe(404)
      done()

  it 'get schema', (done) ->
    request.get {uri:url+'/schema'}, (err, res, body) ->
      expect(res.statusCode).toBe(200)
      body = JSON.parse(body)
      expect(body.type).toBeDefined()
      done()
